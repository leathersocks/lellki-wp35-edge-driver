# LELLKI WP35 SmartThings Edge Driver

LELLKI WP35 Matter 멀티탭을 SmartThings에서 **하나의 다중 구성요소 장치**로 표시하고, 각 콘센트와 USB 출력을 개별 제어하기 위한 전용 Edge Driver입니다.

## 지원 기기 정보

* Matter Vendor ID: `5120` (`0x1400`)
* Matter Product ID: `1002` (`0x03EA`)
* 확인된 Firmware 버전: `1.10`

### Matter Endpoint 구성

| Endpoint | SmartThings 구성요소 | 실제 출력       |
| -------: | ---------------- | ----------- |
|        1 | `main`           | 첫 번째 AC 콘센트 |
|        2 | `outlet2`        | 두 번째 AC 콘센트 |
|        3 | `outlet3`        | 세 번째 AC 콘센트 |
|        4 | `outlet4`        | 네 번째 AC 콘센트 |
|        5 | `usb`            | USB 출력      |

## 주요 기능

기존 범용 Matter 드라이버에서는 Endpoint 2~5가 별도의 Edge Child 장치로 생성될 수 있습니다.

이 드라이버는 LELLKI WP35의 모든 출력을 하나의 SmartThings 장치 안에 다음과 같이 표시합니다.

* Outlet 1
* Outlet 2
* Outlet 3
* Outlet 4
* USB

각 구성요소의 스위치 명령은 해당 Matter Endpoint로 로컬 전송됩니다.

```text
LELLKI WP35
├─ Outlet 1 → Endpoint 1
├─ Outlet 2 → Endpoint 2
├─ Outlet 3 → Endpoint 3
├─ Outlet 4 → Endpoint 4
└─ USB      → Endpoint 5
```

### 채널 초대 링크

[https://bestow-regional.api.smartthings.com/invite/Kr2zLBpAKpjA](https://bestow-regional.api.smartthings.com/invite/Kr2zLBpAKpjA)

드라이버가 설치된 후 SmartThings 앱에서 WP35를 다시 등록해야 전용 드라이버가 적용됩니다.

## 기존 WP35 장치 전환 방법

이미 SmartThings에 등록된 WP35는 전용 Edge Driver를 설치하더라도 기존 드라이버에서 자동으로 변경되지 않을 수 있습니다.

다음 순서로 다시 등록하는 것을 권장합니다.

1. 위 초대 링크를 통해 전용 Edge Driver를 허브에 설치합니다.
2. 기존 WP35의 장치명과 각 콘센트의 용도를 기록합니다.
3. WP35에 연결된 SmartThings 루틴을 확인합니다.
4. SmartThings 앱에서 기존 WP35를 삭제합니다.
5. WP35를 초기화합니다.
6. SmartThings 앱에서 `기기 추가`를 선택합니다.
7. Matter QR 코드 또는 설정 코드를 이용해 WP35를 다시 등록합니다.
8. 등록된 WP35에서 Outlet 1~4와 USB가 하나의 장치에 표시되는지 확인합니다.
9. 기존에 사용하던 루틴을 다시 연결합니다.

장치를 삭제하면 기존 장치 ID와 연결된 루틴이 삭제될 수 있으므로, 재등록 전에 현재 설정을 기록해 두는 것이 좋습니다.

## 정상 동작 확인 항목

설치 후 다음 사항을 확인해 주세요.

* Outlet 1~4와 USB가 하나의 WP35 장치에 표시되는지
* 각 구성요소가 실제 콘센트 및 USB 출력과 올바르게 대응하는지
* SmartThings 앱에서 개별 On/Off 제어가 정상적으로 동작하는지
* 물리 버튼이나 제조사 앱에서 상태를 변경했을 때 SmartThings 상태가 갱신되는지
* SmartThings 허브를 재부팅한 후에도 제어와 상태 갱신이 유지되는지
* 기존 범용 드라이버처럼 별도의 자식 장치가 추가로 생성되지 않는지

## 지원 기능

* Outlet 1 개별 On/Off
* Outlet 2 개별 On/Off
* Outlet 3 개별 On/Off
* Outlet 4 개별 On/Off
* USB 출력 개별 On/Off
* 하나의 SmartThings 장치 카드로 통합 표시
* Matter Endpoint별 로컬 제어
* 물리 조작에 따른 상태 갱신
* 허브 재부팅 후 상태 구독 복구

## 참고사항

* 본 드라이버는 LELLKI, Uascent 또는 Samsung SmartThings의 공식 지원 드라이버가 아닙니다.
* LELLKI WP35 Matter 멀티탭의 확인된 VID, PID 및 Endpoint 구조를 기준으로 제작했습니다.
* 펌웨어 버전이나 하드웨어 리비전에 따라 동작 차이가 발생할 수 있습니다.
* 기존에 등록된 WP35는 드라이버 설치 후 삭제하고 다시 등록해야 정상적으로 적용될 수 있습니다.
* 장치를 다시 등록하면 기존 SmartThings 루틴을 다시 연결해야 할 수 있습니다.
