# 설치 절차 요약

## 1. SmartThings CLI 설치 및 로그인

Windows용 SmartThings CLI를 설치한 뒤 터미널에서 로그인합니다.

```powershell
smartthings login
```

## 2. 패키징

압축을 푼 폴더에서 실행합니다.

```powershell
cd lellki-wp35-edge-driver
smartthings edge:drivers:package .
```

## 3. 개인 채널 생성 및 드라이버 배포

CLI의 대화형 선택을 이용하는 것이 가장 안전합니다.

```powershell
smartthings edge:channels:create
smartthings edge:channels:assign
smartthings edge:drivers:install
```

## 4. WP35 재등록

전용 fingerprint는 새 페어링 시 적용되는 것이 가장 확실합니다. 기존 장치를 삭제하기 전에 연결된 루틴을 기록한 뒤 WP35를 초기화하고 다시 Matter 페어링합니다.

## 5. 확인

Advanced Web에서 새 WP35 장치의 Driver ID와 Profile을 확인하고, 각 구성요소를 차례로 켜고 끕니다.
