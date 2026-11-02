
# Docker 스토리지 실습

## 1. 실습 환경

- OS: Windows
- Shell: PowerShell
- Docker Engine: 29.9.2
- Docker Desktop: 4.97.0
- 이미지: dev-workstation-web:1.0
- 프로젝트: dev-workstation

## 2. 바인드 마운트 실습

### 실습 목표

Windows 호스트의 HTML 파일을 Docker 컨테이너에 연결하고, 파일 수정이 실시간으로 반영되는지 확인한다.

### 컨테이너 실행

```powershell
docker run -d --name dev-web-bind -p 8082:80 --mount "type=bind,source=$((Get-Location).Path)\site,target=/usr/share/nginx/html,readonly" dev-workstation-web:1.0
```

호스트의 `site` 디렉터리를 컨테이너 내부 `/usr/share/nginx/html`에 읽기 전용으로 연결했다.

### 변경 전 확인

```powershell
curl.exe http://localhost:8082
```

확인된 HTML:

```html
<p>Status: Ready</p>
```

변경 전 응답: [bind-before.txt](../logs/bind-before.txt)

### 호스트 파일 수정

`site/index.html`에서 다음 내용을 수정했다.

변경 전:

```html
<p>Status: Ready</p>
```

변경 후:

```html
<p>Status: Bind Mount Updated!</p>
```

### 변경 후 확인

컨테이너를 재시작하거나 이미지를 다시 빌드하지 않고 실행했다.

```powershell
curl.exe http://localhost:8082
```

확인된 HTML:

```html
<p>Status: Bind Mount Updated!</p>
```

변경 후 응답: [bind-after.txt](../logs/bind-after.txt)

### 변경 전후 비교

```powershell
Compare-Object (Get-Content logs/bind-before.txt) (Get-Content logs/bind-after.txt)
```

확인 결과:

```text
Status: Bind Mount Updated!  =>
Status: Ready                <=
```

### 결론

바인드 마운트를 이용하면 컨테이너 이미지를 다시 빌드하지 않아도 호스트 파일의 변경 사항이 컨테이너에 반영된다.

이번 실습에서는 컨테이너가 호스트 파일을 읽을 수 있도록 `readonly` 옵션을 사용했다.

---

## 3. Docker 볼륨 영속성 실습

### 실습 목표

컨테이너를 삭제해도 Docker 볼륨에 저장된 데이터가 유지되는지 검증한다.

### 볼륨 생성

```powershell
docker volume create workstation-data
docker volume ls
```

볼륨 이름:

```text
workstation-data
```

### 첫 번째 컨테이너 실행

```powershell
docker run -d --name volume-test-1 -v workstation-data:/data ubuntu:24.04 sleep infinity
```

### 데이터 생성

```powershell
docker exec volume-test-1 sh -c 'echo Docker_Volume_Persistence_Test > /data/test.txt'
```

### 저장된 데이터 확인

```powershell
docker exec volume-test-1 cat /data/test.txt
```

실제 출력:

```text
Docker_Volume_Persistence_Test
```

삭제 전 증거: [volume-before.txt](../logs/volume-before.txt)

### 첫 번째 컨테이너 삭제

```powershell
docker rm -f volume-test-1
```

### 볼륨 유지 확인

```powershell
docker volume ls
```

`workstation-data` 볼륨이 유지되는 것을 확인했다.

### 두 번째 컨테이너 생성

```powershell
docker run -d --name volume-test-2 -v workstation-data:/data ubuntu:24.04 sleep infinity
```

### 기존 데이터 확인

```powershell
docker exec volume-test-2 cat /data/test.txt
```

실제 출력:

```text
Docker_Volume_Persistence_Test
```

삭제 후 증거: [volume-after.txt](../logs/volume-after.txt)

### 삭제 전후 비교

```powershell
Compare-Object (Get-Content logs/volume-before.txt) (Get-Content logs/volume-after.txt)
```

실행 결과: 출력 없음.

이는 두 파일의 내용이 동일하다는 의미이다.

### 결론

Docker 볼륨은 컨테이너의 생명주기와 분리되어 관리된다.

첫 번째 컨테이너를 삭제한 후 새로운 컨테이너에 동일한 볼륨을 연결했을 때 기존 데이터가 유지되었다.

---

## 4. 바인드 마운트와 Docker 볼륨 비교

| 구분 | 바인드 마운트 | Docker 볼륨 |
|---|---|---|
| 저장 위치 | 호스트에서 지정한 경로 | Docker가 관리 |
| 주요 목적 | 로컬 파일 공유 및 개발 | 영속 데이터 저장 |
| 파일 수정 반영 | 가능 | 가능 |
| 컨테이너 삭제 후 유지 | 호스트 파일 유지 | 볼륨 데이터 유지 |
| 이번 실습 | HTML 변경 반영 | 컨테이너 삭제 후 데이터 확인 |

## 5. 실습 완료 체크리스트

- [x] 바인드 마운트 컨테이너 실행
- [x] 호스트 HTML 파일 수정
- [x] 컨테이너 재시작 없이 변경 반영 확인
- [x] 변경 전후 응답 비교
- [x] Docker 볼륨 생성
- [x] 볼륨에 데이터 저장
- [x] 기존 컨테이너 삭제
- [x] 새 컨테이너에 동일 볼륨 연결
- [x] 데이터 유지 확인
- [x] 삭제 전후 데이터 비교
