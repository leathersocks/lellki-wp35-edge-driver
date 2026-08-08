# LELLKI WP35 SmartThings Edge Driver

[English](README.en.md)

LELLKI WP35 Matter 멀티탭을 SmartThings에서 **하나의 다중 구성요소 장치**로 표시하고, 4개의 AC 콘센트와 USB 출력을 각각 제어하기 위한 비공식 SmartThings Edge Driver입니다.

이 드라이버는 WP35의 Matter Endpoint `1~5`를 하나의 SmartThings Device Profile 안의 5개 `switch` 구성요소에 고정 매핑합니다. 기존 범용 Matter 드라이버에서 각 Endpoint가 별도 Child 장치로 보이는 구성을 피하고, 하나의 WP35 장치 카드 안에서 모든 출력을 관리하는 것이 목적입니다.

---

## 지원 기기

현재 저장소에서 대상으로 하는 장치는 다음과 같습니다.

| 항목 | 값 |
|---|---|
| 제품 | LELLKI WP35 Matter Power Strip |
| Matter Vendor ID | `5120` / `0x1400` |
| Matter Product ID | `1002` / `0x03EA` |
| 확인된 Firmware | `1.10` |
| 출력 | AC Outlet 4개 + USB 1개 |
| 통신 | Matter / SmartThings Hub |

> 위 Firmware는 실제 확인된 버전이며 지원 가능한 최소/최대 Firmware 범위를 의미하지 않습니다. 하드웨어 리비전이나 Firmware에 따라 Endpoint 구성이 다르면 일부 기능이 정상 동작하지 않을 수 있습니다.

---

## Matter Endpoint / SmartThings 구성요소 매핑

실제 드라이버와 Device Profile에서 사용하는 매핑은 다음과 같습니다.

| Matter Endpoint | SmartThings Component ID | 표시명 | 실제 출력 |
|---:|---|---|---|
| `1` | `main` | Outlet 1 | 첫 번째 AC 콘센트 |
| `2` | `switch2` | Outlet 2 | 두 번째 AC 콘센트 |
| `3` | `switch3` | Outlet 3 | 세 번째 AC 콘센트 |
| `4` | `switch4` | Outlet 4 | 네 번째 AC 콘센트 |
| `5` | `switch5` | USB | USB 출력 |

```text
LELLKI WP35
├─ main     → Endpoint 1 → Outlet 1
├─ switch2  → Endpoint 2 → Outlet 2
├─ switch3  → Endpoint 3 → Outlet 3
├─ switch4  → Endpoint 4 → Outlet 4
└─ switch5  → Endpoint 5 → USB
```

> `Outlet 2`, `Outlet 3`, `Outlet 4`, `USB`는 앱에 보이는 **label**이며 실제 Component ID는 각각 `switch2`, `switch3`, `switch4`, `switch5`입니다.

---

## 주요 기능

- Outlet 1 개별 On/Off
- Outlet 2 개별 On/Off
- Outlet 3 개별 On/Off
- Outlet 4 개별 On/Off
- USB 출력 개별 On/Off
- 5개 출력을 하나의 SmartThings 장치 카드로 통합
- Matter Endpoint별 로컬 명령 전송
- Matter `OnOff` attribute 구독을 통한 상태 갱신
- 물리 버튼 또는 다른 Matter controller에서 상태가 변경될 때 SmartThings 상태 반영
- 명령 전송 직후 해당 Endpoint를 다시 읽어 상태 확인
- 수동 Refresh 시 Endpoint `1~5` 상태 재조회
- Hub/Edge Driver 재시작 시 Matter subscription 복구
- 실제 발견된 OnOff Endpoint와 예상 Endpoint `1~5`를 logcat에 기록해 Firmware 차이 진단

---

## 설치

### SmartThings Edge Driver 채널

일반 사용자는 Git이나 SmartThings CLI 없이 다음 채널 초대 링크를 이용할 수 있습니다.

[https://bestow-regional.api.smartthings.com/invite/Kr2zLBpAKpjA](https://bestow-regional.api.smartthings.com/invite/Kr2zLBpAKpjA)

설치 순서:

1. 위 채널 초대 링크를 엽니다.
2. SmartThings 계정으로 로그인합니다.
3. Edge Driver 채널을 등록합니다.
4. WP35를 사용할 SmartThings Hub를 선택합니다.
5. **LELLKI WP35** 드라이버를 설치합니다.
6. SmartThings 앱에서 WP35를 Matter 장치로 등록합니다.

> 전용 드라이버가 설치되기 전에 이미 WP35를 등록했다면 기존 범용 Matter 드라이버가 계속 연결되어 있을 수 있습니다. 이 경우 아래의 재등록 절차를 참고하세요.

---

## 기존 WP35를 전용 드라이버로 전환

이미 SmartThings에 등록된 WP35는 전용 Edge Driver를 설치하더라도 기존 드라이버에서 자동으로 변경되지 않을 수 있습니다.

권장 순서:

1. 현재 WP35의 장치명과 Outlet별 용도를 기록합니다.
2. WP35를 사용하는 SmartThings 루틴을 확인합니다.
3. 채널을 통해 이 전용 Edge Driver를 Hub에 설치합니다.
4. SmartThings 앱에서 기존 WP35를 삭제합니다.
5. 필요하면 WP35를 Matter pairing이 가능한 상태로 초기화합니다.
6. SmartThings 앱에서 `기기 추가`를 선택합니다.
7. Matter QR 코드 또는 설정 코드를 이용해 WP35를 다시 등록합니다.
8. 하나의 WP35 장치 안에 `Outlet 1`, `Outlet 2`, `Outlet 3`, `Outlet 4`, `USB`가 표시되는지 확인합니다.
9. 각 항목이 실제 출력과 맞는지 하나씩 On/Off 테스트합니다.
10. 기존 루틴을 새 장치/구성요소에 다시 연결합니다.

장치를 삭제하면 기존 Device ID와 연결된 루틴이 삭제되거나 연결이 끊길 수 있으므로 재등록 전에 현재 구성을 기록해 두는 것이 좋습니다.

---

## 정상 동작 확인

등록 후 다음 항목을 확인하세요.

- WP35가 하나의 SmartThings 장치로 표시됨
- Outlet 1~4와 USB가 모두 같은 장치 안에 표시됨
- 각 구성요소의 On/Off가 실제 출력과 정확히 대응함
- 물리 조작 후 SmartThings 상태가 갱신됨
- 앱에서 명령한 뒤 실제 출력과 앱 상태가 일치함
- `Refresh` 후 5개 출력 상태가 다시 동기화됨
- Hub 또는 Edge Driver가 재시작된 뒤에도 상태 갱신이 계속됨
- 범용 Matter 드라이버처럼 별도의 Child 장치가 추가로 생성되지 않음

---

## 동작 방식

### On/Off 명령

SmartThings 구성요소에서 On/Off 명령이 발생하면 드라이버는 해당 Component ID를 Matter Endpoint로 변환합니다.

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
해당 Endpoint OnOff attribute 재조회
```

### 상태 보고

Matter `OnOff` attribute 보고를 받으면 Endpoint를 다시 SmartThings 구성요소에 매핑합니다.

```text
Matter OnOff report
        ↓
Endpoint 1~5
        ↓
SmartThings Component
        ↓
switch = on / off
```

드라이버는 예상하지 않은 Endpoint의 OnOff 보고를 임의로 `Outlet 1`에 적용하지 않고 경고 로그를 남긴 뒤 무시합니다.

---

## 문제 해결

### Outlet 1만 보이고 나머지가 보이지 않는 경우

- 채널에서 이 전용 드라이버가 Hub에 설치되어 있는지 확인합니다.
- WP35가 전용 드라이버 설치 **이후** 등록되었는지 확인합니다.
- 기존 범용 Matter 드라이버로 등록된 장치라면 삭제 후 다시 등록합니다.
- Device Profile이 `lellki-wp35-single-card-v5`인지 개발자 로그에서 확인합니다.

### Outlet과 실제 출력 순서가 다른 경우

현재 드라이버는 Endpoint `1~5`가 각각 Outlet 1~4와 USB라는 확인된 구조를 사용합니다.

Firmware 또는 하드웨어 리비전이 다르면 실제 Endpoint 순서가 달라질 수 있습니다. 아래 logcat에서 `OnOff endpoints observed`와 개별 `state` 로그를 확인해 주세요.

### 앱의 상태가 갱신되지 않는 경우

1. SmartThings 앱에서 `Refresh`를 실행합니다.
2. 물리 버튼으로 출력을 변경한 후 상태가 들어오는지 확인합니다.
3. Hub를 재부팅한 뒤 다시 확인합니다.
4. logcat에서 Matter subscription 및 `WP35 v5 state` 로그를 확인합니다.

### 명령은 전송되지만 상태가 맞지 않는 경우

드라이버는 On/Off 명령 직후 동일 Endpoint의 OnOff attribute를 다시 읽습니다. 반복적으로 상태가 맞지 않으면 Matter 통신 상태 또는 실제 Endpoint 구조를 확인해야 합니다.

---

## 개발자용 logcat

일반 사용자는 필요하지 않습니다. SmartThings CLI가 설치된 PC에서:

```powershell
smartthings edge:drivers
```

드라이버 ID를 확인한 후:

```powershell
smartthings edge:drivers:logcat <DRIVER_ID> --hub-address <HUB_IP>
```

주요 로그 예:

```text
Starting LELLKI WP35 single-card driver v5
WP35 v5 OnOff endpoints observed=[1,2,3,4,5] expected=[1,2,3,4,5]
WP35 v5 configured: reason=...
WP35 v5 command: endpoint=... component=... target=...
WP35 v5 state: endpoint=... component=... value=...
```

예상 Endpoint가 없으면 다음과 같은 경고가 표시됩니다.

```text
WP35 v5 expected OnOff endpoint(s) missing=[...] ; firmware or hardware layout may differ
```

> 로그를 Issue에 공유할 때는 개인 네트워크 정보나 Matter setup code 등 민감정보가 포함되어 있지 않은지 확인하세요.

---

## 개발자용 소스 설치

채널 설치 대신 소스를 직접 패키징하려는 경우:

```powershell
git clone https://github.com/leathersocks/lellki-wp35-edge-driver.git
cd lellki-wp35-edge-driver
smartthings edge:drivers:package . --install
```

현재 `packageKey`는 다음 값을 유지합니다.

```text
x2pu.lellki.wp35.matter.single-card.v5
```

기존 설치를 업데이트하려면 호환성을 위해 `packageKey`를 임의로 변경하지 않는 것을 권장합니다.

---

## 저장소 구조

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

## 참고 및 제한사항

- 본 프로젝트는 LELLKI, Uascent 또는 Samsung SmartThings의 공식 드라이버가 아닙니다.
- 확인된 WP35의 VID/PID 및 Endpoint 구조를 기준으로 제작되었습니다.
- 현재 기능은 Endpoint별 `switch` On/Off에 집중합니다.
- 전력/전류/전압/에너지 측정 기능은 현재 Device Profile에 포함하지 않습니다.
- Firmware 또는 하드웨어 리비전에 따라 Endpoint 구조가 다를 수 있습니다.
- GitHub의 코드 변경이 SmartThings 채널에 자동 배포되는 것은 아닙니다. 채널에 실제 설치된 드라이버 버전은 별도로 확인해야 합니다.
- 저장소의 코드 개선 후 실제 Hub 런타임 검증은 별도로 수행하는 것을 권장합니다.

---

## 관련 문서

- [`CHANGELOG.md`](CHANGELOG.md) — 변경 이력
- [`README.en.md`](README.en.md) — English README

오류 재현이나 다른 WP35 Firmware/리비전 지원에 필요한 정보는 GitHub Issue로 공유할 수 있습니다. 가능하면 Firmware 버전, 실제 Endpoint 동작, 관련 logcat 일부를 함께 제공해 주세요.
