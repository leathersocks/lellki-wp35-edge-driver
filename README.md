# LELLKI WP35 SmartThings Edge Driver

LELLKI WP35 Matter 멀티탭을 SmartThings에서 **하나의 다중 구성요소 장치**로 표시하기 위한 전용 Edge Driver 초안입니다.

## 확인된 기기 정보

- Matter Vendor ID: `5120` (`0x1400`)
- Matter Product ID: `1002` (`0x03EA`)
- Firmware 확인값: `1.10`
- Endpoint 1: 첫 번째 AC 콘센트 (`main`)
- Endpoint 2: 두 번째 AC 콘센트 (`outlet2`)
- Endpoint 3: 세 번째 AC 콘센트 (`outlet3`)
- Endpoint 4: 네 번째 AC 콘센트 (`outlet4`)
- Endpoint 5: USB 출력 (`usb`)

## 기대 동작

기존 범용 Matter 드라이버는 Endpoint 2~5를 별도 Edge Child 장치로 생성하지만, 이 드라이버는 하나의 WP35 장치 안에 다음 구성요소를 표시하도록 설계했습니다.

- Outlet 1
- Outlet 2
- Outlet 3
- Outlet 4
- USB

각 구성요소의 스위치 명령은 해당 Matter Endpoint로 로컬 전송됩니다.

## 설치

SmartThings CLI가 필요합니다.

```powershell
smartthings edge:drivers:package .
```

출력된 Driver ID를 확인한 뒤 개인 채널을 만들거나 기존 채널에 할당합니다.

```powershell
smartthings edge:channels:create
smartthings edge:channels:assign
smartthings edge:drivers:install
```

CLI 버전에 따라 인수 형식이 달라질 수 있으므로 각 명령의 도움말을 확인하세요.

```powershell
smartthings edge:drivers:package --help
smartthings edge:channels:assign --help
smartthings edge:drivers:install --help
```

## 장치 전환 시 주의사항

Matter 장치는 이미 설치된 드라이버가 자동으로 이 전용 드라이버로 바뀌지 않을 수 있습니다.

1. 먼저 이 드라이버를 SmartThings 허브에 설치합니다.
2. WP35의 현재 장치명과 콘센트별 용도를 기록합니다.
3. SmartThings에서 WP35를 제거합니다.
4. WP35를 초기화한 뒤 Matter로 다시 추가합니다.
5. 새 장치가 `LELLKI WP35` 드라이버를 선택했는지 Advanced Web 또는 CLI에서 확인합니다.

장치를 제거하면 기존 루틴과 장치 ID가 삭제되므로 루틴을 다시 연결해야 합니다.

## 검증할 항목

이 패키지는 제공된 실제 장치 JSON을 기준으로 작성한 **테스트 전 초안**입니다. 설치 후 아래를 확인해야 합니다.

- 각 구성요소가 올바른 물리 출력과 대응하는지
- 앱에서 개별 On/Off 명령이 정상인지
- 물리 버튼 또는 제조사 앱에서 상태가 바뀔 때 SmartThings 상태가 갱신되는지
- 허브 재부팅 후에도 구독과 상태 갱신이 유지되는지
- 기존처럼 자식 장치가 추가 생성되지 않는지

로그 확인:

```powershell
smartthings edge:drivers:logcat
```

## 제한사항

- WP35가 Matter로 공개하지 않는 소비전력, 과부하 보호, 전원 복구 설정, LED 설정은 이 드라이버만으로 추가할 수 없습니다.
- 현재 장치 JSON에는 각 Endpoint가 표준 Matter On/Off Plug-in Unit으로만 공개되어 있습니다.
- 이 드라이버는 LELLKI, Uascent, Samsung SmartThings의 공식 지원 드라이버가 아닙니다.
