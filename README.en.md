# LELLKI WP35 SmartThings Edge Driver

[한국어](README.md)

An unofficial SmartThings Edge Driver for presenting the LELLKI WP35 Matter power strip as **one multi-component SmartThings device**, with independent control of four AC outlets and the USB output.

The driver uses a fixed mapping from Matter endpoints `1-5` to five `switch` components in a single SmartThings Device Profile. Its purpose is to avoid the layout where a generic Matter driver may expose endpoints as separate child devices, and instead keep all WP35 outputs on one device card.

---

## Supported device

The repository currently targets the following device configuration.

| Item | Value |
|---|---|
| Product | LELLKI WP35 Matter Power Strip |
| Matter Vendor ID | `5120` / `0x1400` |
| Matter Product ID | `1002` / `0x03EA` |
| Verified firmware | `1.10` |
| Outputs | 4 AC outlets + 1 USB output |
| Transport | Matter / SmartThings Hub |

> The firmware version above is the version that has been observed in testing. It is not a declared minimum or maximum supported firmware range. Different hardware revisions or firmware may expose a different endpoint layout.

---

## Matter endpoint / SmartThings component mapping

The actual driver and Device Profile use the following mapping.

| Matter Endpoint | SmartThings Component ID | Label | Physical output |
|---:|---|---|---|
| `1` | `main` | Outlet 1 | First AC outlet |
| `2` | `switch2` | Outlet 2 | Second AC outlet |
| `3` | `switch3` | Outlet 3 | Third AC outlet |
| `4` | `switch4` | Outlet 4 | Fourth AC outlet |
| `5` | `switch5` | USB | USB output |

```text
LELLKI WP35
├─ main     → Endpoint 1 → Outlet 1
├─ switch2  → Endpoint 2 → Outlet 2
├─ switch3  → Endpoint 3 → Outlet 3
├─ switch4  → Endpoint 4 → Outlet 4
└─ switch5  → Endpoint 5 → USB
```

> `Outlet 2`, `Outlet 3`, `Outlet 4`, and `USB` are display labels. Their actual SmartThings Component IDs are `switch2`, `switch3`, `switch4`, and `switch5`.

---

## Features

- Independent On/Off control for Outlet 1
- Independent On/Off control for Outlet 2
- Independent On/Off control for Outlet 3
- Independent On/Off control for Outlet 4
- Independent On/Off control for USB
- All five outputs shown on one SmartThings device
- Local Matter commands routed to the correct endpoint
- State updates from Matter `OnOff` attribute subscriptions
- State synchronization after physical control or another Matter controller changes an output
- Explicit endpoint read after each On/Off command for state confirmation
- Manual Refresh reads endpoints `1-5`
- Matter subscriptions restored when the Hub/Edge Driver runtime restarts
- Runtime diagnostics log observed OnOff endpoints and compare them with the expected `1-5` layout

---

## Installation

### SmartThings Edge Driver channel

Regular users can install the driver from the SmartThings Edge Driver channel without Git or the SmartThings CLI.

[https://bestow-regional.api.smartthings.com/invite/Kr2zLBpAKpjA](https://bestow-regional.api.smartthings.com/invite/Kr2zLBpAKpjA)

Installation steps:

1. Open the channel invitation link above.
2. Sign in with your SmartThings account.
3. Join the Edge Driver channel.
4. Select the SmartThings Hub that will manage the WP35.
5. Install the **LELLKI WP35** driver.
6. Pair the WP35 as a Matter device in the SmartThings app.

> If the WP35 was already paired before this driver was installed, it may remain assigned to a generic Matter driver. In that case, use the re-pairing procedure below.

---

## Migrating an existing WP35

An already-paired WP35 may not automatically switch to this dedicated Edge Driver after the driver is installed.

Recommended procedure:

1. Record the current device name and the purpose of each outlet.
2. Review any SmartThings routines that use the WP35.
3. Install this dedicated driver on the Hub from the channel.
4. Remove the existing WP35 from SmartThings.
5. If necessary, reset the WP35 so it can be paired again with Matter.
6. In SmartThings, choose `Add device`.
7. Pair the WP35 with its Matter QR code or setup code.
8. Verify that `Outlet 1`, `Outlet 2`, `Outlet 3`, `Outlet 4`, and `USB` appear inside one WP35 device.
9. Test each component individually and confirm the physical output mapping.
10. Reconnect your routines to the new device/components.

Removing the device can break routines associated with the old Device ID, so record the existing configuration first.

---

## Verification checklist

After pairing, verify the following:

- The WP35 appears as one SmartThings device.
- Outlet 1-4 and USB all appear in the same device.
- Each component controls the correct physical output.
- State changes from physical controls are reflected in SmartThings.
- App commands and physical output state remain synchronized.
- `Refresh` resynchronizes all five outputs.
- State updates continue after a Hub or Edge Driver restart.
- No extra child devices are created as with some generic Matter profiles.

---

## How it works

### On/Off commands

When a SmartThings switch command is received, the driver converts the Component ID into the corresponding Matter endpoint.

```text
SmartThings switch command
        ↓
Component ID
        ↓
main / switch2 / switch3 / switch4 / switch5
        ↓
Matter Endpoint 1 / 2 / 3 / 4 / 5
        ↓
OnOff cluster On / Off
        ↓
Read the same endpoint's OnOff attribute
```

### State reports

When a Matter `OnOff` attribute report is received, the endpoint is mapped back to the SmartThings component.

```text
Matter OnOff report
        ↓
Endpoint 1-5
        ↓
SmartThings Component
        ↓
switch = on / off
```

Unexpected OnOff reports from unmapped endpoints are not applied to Outlet 1 by the attribute handler; they are ignored with a warning log.

---

## Troubleshooting

### Only Outlet 1 is visible

- Confirm that this dedicated driver is installed on the Hub through the channel.
- Confirm that the WP35 was paired **after** the dedicated driver was installed.
- If the device is still using a generic Matter driver, remove and pair it again.
- Developers can verify that the profile is `lellki-wp35-single-card-v5` in logs/driver metadata.

### Physical output order does not match the labels

The current driver uses the verified layout where endpoints `1-5` correspond to Outlet 1-4 and USB.

A different firmware or hardware revision may use a different endpoint layout. Check the `OnOff endpoints observed` and individual `state` messages in logcat.

### SmartThings state does not update

1. Run `Refresh` in the SmartThings app.
2. Toggle an output physically and check whether the state report arrives.
3. Restart the Hub and test again.
4. Check logcat for Matter subscription and `WP35 v5 state` messages.

### Commands work but the displayed state is wrong

The driver explicitly reads the same endpoint's OnOff attribute immediately after each On/Off command. If the state repeatedly disagrees, inspect Matter connectivity and the actual endpoint layout.

---

## Developer logcat

Regular users do not need this. On a PC with the SmartThings CLI:

```powershell
smartthings edge:drivers
```

After identifying the driver ID:

```powershell
smartthings edge:drivers:logcat <DRIVER_ID> --hub-address <HUB_IP>
```

Typical log messages include:

```text
Starting LELLKI WP35 single-card driver v5
WP35 v5 OnOff endpoints observed=[1,2,3,4,5] expected=[1,2,3,4,5]
WP35 v5 configured: reason=...
WP35 v5 command: endpoint=... component=... target=...
WP35 v5 state: endpoint=... component=... value=...
```

If an expected endpoint is missing, the driver logs a warning similar to:

```text
WP35 v5 expected OnOff endpoint(s) missing=[...] ; firmware or hardware layout may differ
```

> Before sharing logs in an Issue, check that they do not include private network information or Matter setup codes.

---

## Developer source installation

To package the source directly instead of using the channel:

```powershell
git clone https://github.com/leathersocks/lellki-wp35-edge-driver.git
cd lellki-wp35-edge-driver
smartthings edge:drivers:package . --install
```

The current `packageKey` is intentionally kept as:

```text
x2pu.lellki.wp35.matter.single-card.v5
```

Do not change the `packageKey` casually if you want existing installations to remain update-compatible.

---

## Repository layout

```text
lellki-wp35-edge-driver/
├─ config.yml
├─ fingerprints.yml
├─ profiles/
│  └─ lellki-wp35-single-card-v5.yml
├─ src/
│  └─ init.lua
├─ README.md
├─ README.en.md
├─ CHANGELOG.md
└─ CHANGELOG.en.md
```

---

## Notes and limitations

- This project is not an official LELLKI, Uascent, or Samsung SmartThings driver.
- It is based on the verified WP35 VID/PID and endpoint layout.
- The current feature set focuses on per-endpoint `switch` On/Off control.
- Power, current, voltage, and energy metering are not included in the current Device Profile.
- Firmware or hardware revisions may expose a different endpoint layout.
- GitHub changes are not automatically published to the SmartThings Edge Driver channel. The actual driver version installed from the channel must be verified separately.
- Runtime testing on a real SmartThings Hub is recommended after source changes.

---

## Related documents

- [`CHANGELOG.en.md`](CHANGELOG.en.md) — Change history
- [`README.md`](README.md) — Korean README

For reproducible issues or support for another WP35 firmware/hardware revision, open a GitHub Issue and include the firmware version, observed endpoint behavior, and a relevant logcat excerpt when possible.
