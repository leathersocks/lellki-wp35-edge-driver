-- LELLKI WP35 Matter Edge Driver v5
-- Single SmartThings card with five switch components.
--
-- Matter Vendor ID:  0x1400 (5120)
-- Matter Product ID: 0x03EA (1002)
-- Endpoint 1 -> main    (Outlet 1)
-- Endpoint 2 -> switch2 (Outlet 2)
-- Endpoint 3 -> switch3 (Outlet 3)
-- Endpoint 4 -> switch4 (Outlet 4)
-- Endpoint 5 -> switch5 (USB)

local capabilities = require "st.capabilities"
local MatterDriver = require "st.matter.driver"
local clusters = require "st.matter.clusters"
local log = require "log"

local COMPONENT_TO_ENDPOINT = {
  main = 1,
  switch2 = 2,
  switch3 = 3,
  switch4 = 4,
  switch5 = 5,
}

local ENDPOINT_TO_COMPONENT = {
  [1] = "main",
  [2] = "switch2",
  [3] = "switch3",
  [4] = "switch4",
  [5] = "switch5",
}

local ENDPOINTS = { 1, 2, 3, 4, 5 }
local RUNTIME_READY_FIELD = "wp35_runtime_ready"

local function component_to_endpoint(_, component_id)
  return COMPONENT_TO_ENDPOINT[component_id] or 1
end

local function endpoint_to_component(_, endpoint_id)
  return ENDPOINT_TO_COMPONENT[endpoint_id] or "main"
end

local function read_endpoint(device, endpoint_id)
  device:send(clusters.OnOff.attributes.OnOff:read(device, endpoint_id))
end

local function read_all_endpoints(device)
  for _, endpoint_id in ipairs(ENDPOINTS) do
    read_endpoint(device, endpoint_id)
  end
end

local function install_endpoint_mapping(device)
  device:set_component_to_endpoint_fn(component_to_endpoint)
  device:set_endpoint_to_component_fn(endpoint_to_component)
end

local function validate_expected_endpoints(device)
  local observed = {}
  local observed_set = {}

  for _, endpoint_id in ipairs(device:get_endpoints(clusters.OnOff.ID) or {}) do
    table.insert(observed, endpoint_id)
    observed_set[endpoint_id] = true
  end

  table.sort(observed)

  local observed_text = {}
  for _, endpoint_id in ipairs(observed) do
    table.insert(observed_text, tostring(endpoint_id))
  end

  device.log.info_with({ hub_logs = true }, string.format(
    "WP35 v5 OnOff endpoints observed=[%s] expected=[1,2,3,4,5]",
    table.concat(observed_text, ",")
  ))

  local missing = {}
  for _, endpoint_id in ipairs(ENDPOINTS) do
    if not observed_set[endpoint_id] then
      table.insert(missing, tostring(endpoint_id))
    end
  end

  if #missing > 0 then
    device.log.warn_with({ hub_logs = true }, string.format(
      "WP35 v5 expected OnOff endpoint(s) missing=[%s]; firmware or hardware layout may differ",
      table.concat(missing, ",")
    ))
  end
end

-- Lifecycle events can arrive close together during pairing, driver switching,
-- and configuration. Configure once per driver runtime to avoid redundant
-- Matter subscriptions and duplicate initial reads. The field is intentionally
-- non-persistent so a driver/hub restart subscribes again.
local function configure_runtime(device, reason, force)
  install_endpoint_mapping(device)

  if not force and device:get_field(RUNTIME_READY_FIELD) then
    return
  end

  validate_expected_endpoints(device)
  device:subscribe()
  read_all_endpoints(device)
  device:set_field(RUNTIME_READY_FIELD, true)

  device.log.info_with({ hub_logs = true }, string.format(
    "WP35 v5 configured: reason=%s device=%s",
    tostring(reason), tostring(device.label or device.id)
  ))
end

local function device_added(_, device)
  configure_runtime(device, "added", false)
end

local function device_init(_, device)
  configure_runtime(device, "init", false)
end

local function do_configure(_, device)
  device:try_update_metadata({ provisioning_state = "PROVISIONED" })
  configure_runtime(device, "doConfigure", false)
end

local function driver_switched(_, device)
  device:try_update_metadata({ provisioning_state = "PROVISIONED" })
  configure_runtime(device, "driverSwitched", true)
end

local function info_changed(_, device, _, _)
  -- There are currently no device preferences that require a resubscribe.
  -- Keep the endpoint mapping installed without creating duplicate subscriptions.
  configure_runtime(device, "infoChanged", false)
end

local function on_off_attribute_handler(_, device, ib, _)
  local endpoint_id = ib.endpoint_id
  local component_id = ENDPOINT_TO_COMPONENT[endpoint_id]
  local value = ib.data and ib.data.value

  if component_id == nil then
    device.log.warn_with({ hub_logs = true }, string.format(
      "WP35 v5 ignored OnOff report from unmapped endpoint=%s",
      tostring(endpoint_id)
    ))
    return
  end

  if value == nil then
    device.log.warn_with({ hub_logs = true }, string.format(
      "WP35 v5 received OnOff report without a value: endpoint=%s component=%s",
      tostring(endpoint_id), component_id
    ))
    return
  end

  local component = device.profile.components[component_id]
  if component == nil then
    device.log.error_with({ hub_logs = true }, string.format(
      "WP35 v5 profile component missing: endpoint=%s component=%s",
      tostring(endpoint_id), component_id
    ))
    return
  end

  if value then
    device:emit_component_event(component, capabilities.switch.switch.on())
  else
    device:emit_component_event(component, capabilities.switch.switch.off())
  end

  if type(device.register_native_capability_attr_handler) == "function" then
    device:register_native_capability_attr_handler("switch", "switch")
  end

  device.log.info_with({ hub_logs = true }, string.format(
    "WP35 v5 state: endpoint=%d component=%s value=%s",
    endpoint_id, component_id, tostring(value)
  ))
end

local function send_switch_command(device, command, turn_on)
  local component_id = command.component or "main"
  local endpoint_id = COMPONENT_TO_ENDPOINT[component_id]

  if endpoint_id == nil then
    device.log.error_with({ hub_logs = true }, string.format(
      "WP35 v5 command rejected: unmapped component=%s",
      tostring(component_id)
    ))
    return
  end

  if type(device.register_native_capability_cmd_handler) == "function" then
    device:register_native_capability_cmd_handler(command.capability, command.command)
  end

  if turn_on then
    device:send(clusters.OnOff.server.commands.On(device, endpoint_id))
  else
    device:send(clusters.OnOff.server.commands.Off(device, endpoint_id))
  end

  -- Queue an explicit read after the command. Matter requests sent by the driver
  -- are processed in order, so this read also acts as a state confirmation.
  read_endpoint(device, endpoint_id)

  device.log.info_with({ hub_logs = true }, string.format(
    "WP35 v5 command: endpoint=%d component=%s target=%s",
    endpoint_id, component_id, turn_on and "on" or "off"
  ))
end

local function handle_switch_on(_, device, command)
  send_switch_command(device, command, true)
end

local function handle_switch_off(_, device, command)
  send_switch_command(device, command, false)
end

local function handle_refresh(_, device, _)
  install_endpoint_mapping(device)
  read_all_endpoints(device)
  device.log.info_with({ hub_logs = true }, "WP35 v5 manual refresh requested")
end

local function fallback_handler(_, device, response_block)
  device.log.info_with({ hub_logs = true }, string.format(
    "WP35 v5 Matter fallback: %s",
    tostring(response_block)
  ))
end

local driver_template = {
  lifecycle_handlers = {
    added = device_added,
    init = device_init,
    doConfigure = do_configure,
    driverSwitched = driver_switched,
    infoChanged = info_changed,
  },
  matter_handlers = {
    attr = {
      [clusters.OnOff.ID] = {
        [clusters.OnOff.attributes.OnOff.ID] = on_off_attribute_handler,
      },
    },
    fallback = fallback_handler,
  },
  subscribed_attributes = {
    [capabilities.switch.ID] = {
      clusters.OnOff.attributes.OnOff,
    },
  },
  capability_handlers = {
    [capabilities.switch.ID] = {
      [capabilities.switch.commands.on.NAME] = handle_switch_on,
      [capabilities.switch.commands.off.NAME] = handle_switch_off,
    },
    [capabilities.refresh.ID] = {
      [capabilities.refresh.commands.refresh.NAME] = handle_refresh,
    },
  },
  supported_capabilities = {
    capabilities.switch,
    capabilities.refresh,
  },
}

local driver = MatterDriver("lellki-wp35-single-card-v5", driver_template)
log.info_with({ hub_logs = true }, "Starting LELLKI WP35 single-card driver v5")
driver:run()
