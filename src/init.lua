local MatterDriver = require "st.matter.driver"
local capabilities = require "st.capabilities"
local clusters = require "st.matter.clusters"
local log = require "log"

-- LELLKI WP35 endpoint layout confirmed from the user's SmartThings device JSON:
-- endpoint 1 = first AC outlet (main), endpoints 2-4 = remaining AC outlets,
-- endpoint 5 = USB bank.
local COMPONENT_TO_ENDPOINT = {
  main = 1,
  outlet2 = 2,
  outlet3 = 3,
  outlet4 = 4,
  usb = 5,
}

local ENDPOINT_TO_COMPONENT = {
  [1] = "main",
  [2] = "outlet2",
  [3] = "outlet3",
  [4] = "outlet4",
  [5] = "usb",
}

local function component_to_endpoint(device, component_id)
  return COMPONENT_TO_ENDPOINT[component_id] or 1
end

local function endpoint_to_component(device, endpoint_id)
  return ENDPOINT_TO_COMPONENT[endpoint_id] or "main"
end

local function device_init(driver, device)
  device:set_component_to_endpoint_fn(component_to_endpoint)
  device:set_endpoint_to_component_fn(endpoint_to_component)
  device:subscribe()
end

local function device_added(driver, device)
  device:refresh()
end

local driver_template = {
  lifecycle_handlers = {
    init = device_init,
    added = device_added,
  },

  -- SmartThings' Matter library supplies the standard On/Off command and
  -- attribute handlers. The mapping functions above route each component to
  -- the correct physical endpoint.
  subscribed_attributes = {
    [capabilities.switch.ID] = {
      clusters.OnOff.attributes.OnOff,
    },
  },

  supported_capabilities = {
    capabilities.switch,
    capabilities.refresh,
  },
}

local driver = MatterDriver("lellki-wp35-multi-outlet", driver_template)
log.info_with({ hub_logs = true }, "Starting LELLKI WP35 dedicated Matter driver")
driver:run()
