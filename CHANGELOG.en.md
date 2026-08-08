# Change Log

[한국어](CHANGELOG.md)

This document records the major changes to the **LELLKI WP35 SmartThings Edge Driver**.

> Do not assume that the driver currently published to a SmartThings Edge Driver channel is always identical to the source on GitHub `main`. Channel publication should be verified separately.

---

## Unreleased

### Improvements

- Documented the exact relationship between Matter endpoints `1-5` and the actual SmartThings Component IDs:
  - Endpoint 1 → `main`
  - Endpoint 2 → `switch2`
  - Endpoint 3 → `switch3`
  - Endpoint 4 → `switch4`
  - Endpoint 5 → `switch5`
- Corrected README wording that mixed display labels with Component IDs.
- Expanded installation, re-pairing, verification, troubleshooting, logcat, and developer source-install instructions.
- Added a separate English `README.en.md` while keeping `README.md` as the Korean default document.
- Made runtime initialization idempotent so lifecycle events occurring close together do not repeatedly create Matter subscriptions and duplicate the initial endpoint reads.
- Kept the runtime-ready field intentionally non-persistent so Matter subscriptions are rebuilt after a Hub/Edge Driver restart.
- Forced endpoint mapping/subscription rebuilds when the driver is switched (`driverSwitched`).
- Added startup diagnostics that log the Matter OnOff endpoints actually reported by the device.
- Added a warning when any expected endpoint from `1-5` is missing, helping diagnose firmware or hardware-layout differences.
- Ensured manual Refresh reinstalls the endpoint mapping before reading endpoints `1-5`.

### Verification status

- The changes were prepared through static repository analysis and comparison with lifecycle/attribute-handling patterns in the official SmartThings Matter switch driver.
- The modified source still needs runtime verification on a real SmartThings Hub.

---

## v5 single-card — 2026-08-04

- Established a dedicated Matter Edge Driver that presents the LELLKI WP35 as one SmartThings device card.
- Added a Matter fingerprint for Vendor ID `0x1400` and Product ID `0x03EA`.
- Mapped endpoints `1-5` to five switch components in one Device Profile.
- Added independent On/Off control for Outlet 1-4 and USB.
- Routed Matter `OnOff` attribute reports to the corresponding SmartThings component state.
- Added an explicit endpoint read after On/Off commands for state confirmation.
- Used Matter subscriptions and Refresh for state synchronization.
- Documented SmartThings Edge Driver channel installation and re-pairing for already-registered devices.
