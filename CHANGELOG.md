# 변경 이력

[English](CHANGELOG.en.md)

이 문서는 **LELLKI WP35 SmartThings Edge Driver**의 주요 변경 사항을 기록합니다.

> SmartThings 채널에 실제 배포된 드라이버 버전과 GitHub `main`의 소스 상태는 항상 동일하다고 가정하지 않습니다. 채널 배포 여부는 별도로 확인해야 합니다.

---

## Unreleased

### 개선

- Matter Endpoint `1~5`와 실제 SmartThings Component ID의 관계를 README에 정확히 정리했습니다.
  - Endpoint 1 → `main`
  - Endpoint 2 → `switch2`
  - Endpoint 3 → `switch3`
  - Endpoint 4 → `switch4`
  - Endpoint 5 → `switch5`
- 기존 README에서 표시명과 Component ID가 혼용되던 부분을 수정했습니다.
- 설치, 기존 장치 재등록, 정상 동작 확인, 문제 해결, logcat, 개발자용 소스 설치 절차를 보강했습니다.
- 한국어 `README.md`와 별도의 영문 `README.en.md`를 제공하도록 문서 구조를 정리했습니다.
- Lifecycle 이벤트가 짧은 시간에 연속 발생할 때 `device:subscribe()`와 초기 Endpoint read가 중복 실행되는 것을 줄이기 위해 런타임 초기화를 idempotent하게 정리했습니다.
- 런타임 필드는 intentionally non-persistent로 유지하여 Hub/Edge Driver 재시작 후에는 Matter subscription이 다시 구성되도록 했습니다.
- Driver 전환(`driverSwitched`) 시에는 강제로 Endpoint mapping/subscription을 다시 구성하도록 했습니다.
- 실제 장치에서 발견된 Matter OnOff Endpoint 목록을 시작 시 로그에 출력하도록 진단 기능을 추가했습니다.
- 예상 Endpoint `1~5` 중 누락된 Endpoint가 있으면 Firmware 또는 하드웨어 구조 차이를 확인할 수 있도록 경고 로그를 추가했습니다.
- 수동 Refresh 시 Endpoint mapping을 다시 적용한 후 Endpoint `1~5` 상태를 읽도록 정리했습니다.

### 검증 상태

- 위 변경은 저장소 소스에 대한 정적 분석과 SmartThings 공식 Matter switch driver의 lifecycle/attribute handling 패턴을 참고해 정리했습니다.
- 변경된 소스의 실제 SmartThings Hub 런타임 검증은 별도로 수행해야 합니다.

---

## v5 single-card — 2026-08-04

- LELLKI WP35를 하나의 SmartThings 장치 카드로 표시하는 전용 Matter Edge Driver 구성을 정리했습니다.
- Matter Vendor ID `0x1400` / Product ID `0x03EA` fingerprint를 적용했습니다.
- Endpoint `1~5`를 하나의 Device Profile의 5개 switch component로 매핑했습니다.
- Outlet 1~4와 USB를 각각 개별 On/Off할 수 있도록 구성했습니다.
- Matter `OnOff` attribute report를 각 SmartThings component 상태에 반영했습니다.
- On/Off 명령 후 해당 Endpoint를 다시 읽어 상태를 확인하도록 했습니다.
- Matter subscription과 Refresh를 이용해 상태를 동기화하도록 했습니다.
- SmartThings Edge Driver 채널 설치 및 기존 장치 재등록 방법을 README에 정리했습니다.
