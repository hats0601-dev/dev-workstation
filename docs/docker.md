
# Docker 설치 및 컨테이너 운영 실습

## 1. 실행 환경

- OS: Windows
- Shell: PowerShell
- Docker Desktop: 4.97.0
- Docker CLI / Engine: 29.9.2
- Docker Compose: 5.6.1
- Docker 실행 환경: Linux containers
- Docker Context: desktop-linux

## 2. Docker 설치 및 엔진 확인

### 설치

```powershell
winget install --id Docker.DockerDesktop -e --accept-package-agreements --accept-source-agreements
```

설치 결과:

```text
Successfully installed
```

### Docker 버전 확인

```powershell
docker --version
```

실제 출력:

```text
Docker version 29.9.2, build a82e528
```

### Docker 엔진 확인

```powershell
docker info
```

확인된 주요 결과:

```text
Server Version: 29.9.2
Operating System: Docker Desktop
OSType: linux
Architecture: x86_64
Storage Driver: overlayfs
```

초기에는 WSL2 관련 오류로 엔진 실행에 실패했다.

Docker Desktop에서 Docker VMM을 선택한 뒤 엔진이 정상 실행되는 것을 확인했다.

상세 로그: [docker-check.txt](../logs/docker-check.txt)

## 3. hello-world 실행

### 실행 명령

```powershell
docker run hello-world
```

실제 출력 일부:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### 이미지 확인

```powershell
docker images
```

확인한 이미지:

```text
hello-world:latest
```

### 컨테이너 확인

```powershell
docker ps -a
```

확인 결과:

```text
IMAGE         STATUS
hello-world   Exited (0)
```

`Exited (0)`은 프로그램이 정상 종료되었다는 뜻이다.

실행 로그: [hello-world.txt](../logs/hello-world.txt)

## 4. Ubuntu 컨테이너 실습

### 컨테이너 실행 및 내부 진입

```powershell
docker run -it --name ubuntu-practice ubuntu:24.04 bash
```

### 컨테이너 내부 명령어

```bash
pwd
ls -la
echo "Hello Ubuntu"
```

실제 출력:

```text
/
Hello Ubuntu
```

### 컨테이너 종료

```bash
exit
```

### 기존 컨테이너 재시작

```powershell
docker start ubuntu-practice
docker ps
```

### exec를 이용한 내부 진입

```powershell
docker exec -it ubuntu-practice bash
```

기존 컨테이너를 재시작한 후 `/permission-test` 파일과 권한이 유지되는 것을 확인했다.

`docker exec`로 실행한 셸을 종료해도 컨테이너의 메인 프로세스가 실행 중이면 컨테이너는 유지된다.

반면 메인 프로세스가 종료되면 컨테이너도 종료된다.

Linux 권한 실습: [permissions.md](permissions.md)

## 5. Docker 운영 명령어

### 이미지 목록

```powershell
docker images
```

확인한 이미지:

- hello-world:latest
- ubuntu:24.04
- dev-workstation-web:1.0

### 컨테이너 목록

```powershell
docker ps
docker ps -a
```

### 컨테이너 로그

```powershell
docker logs dev-web-8080
docker logs dev-web-8081
```

로그 자료:

- [web-8080.txt](../logs/web-8080.txt)
- [web-8081.txt](../logs/web-8081.txt)

### 리소스 사용량

```powershell
docker stats --no-stream
```

확인한 Ubuntu 컨테이너 리소스:

```text
CPU: 0.00%
MEM: 3.887MiB / 3.876GiB
```

### 컨테이너 중지

```powershell
docker stop ubuntu-practice
```

해당 실습에서 최종 상태는 `Exited (137)`이었다.

종료 코드 137은 SIGKILL에 의해 종료된 상태를 나타낸다. 정확한 원인은 추가 확인이 필요하다.

Docker 운영 로그: [docker-check.txt](../logs/docker-check.txt)

## 6. 커스텀 Docker 이미지 제작

### 선택한 베이스 이미지

`nginx:stable-alpine`

NGINX가 설치된 경량 Linux 기반 이미지를 활용했다.

### Dockerfile

```dockerfile
FROM nginx:stable-alpine

LABEL org.opencontainers.image.title="dev-workstation-web"
LABEL org.opencontainers.image.description="Development workstation mission web server"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
```

### 커스텀 포인트

1. 기존 NGINX 베이스 이미지 사용
2. 이미지 이름과 설명을 LABEL로 정의
3. 직접 작성한 HTML을 NGINX 웹 루트에 복사
4. 웹 서버의 컨테이너 포트 80 명시

Dockerfile 원본: [Dockerfile](../Dockerfile)

웹페이지 원본: [index.html](../site/index.html)

### 이미지 빌드

```powershell
docker build -t dev-workstation-web:1.0 .
```

이미지 확인:

```powershell
docker images
```

확인 결과:

```text
IMAGE                     IMAGE ID
dev-workstation-web:1.0   b2451c5be800
```

## 7. 웹 서버 컨테이너 실행

### 8080 포트

```powershell
docker run -d --name dev-web-8080 -p 8080:80 dev-workstation-web:1.0
curl.exe -i http://localhost:8080
```

실제 응답:

```text
HTTP/1.1 200 OK
Server: nginx/1.30.6
```

접속 증거: [web-8080.png](../screenshots/web-8080.png)

### 8081 포트

```powershell
docker run -d --name dev-web-8081 -p 8081:80 dev-workstation-web:1.0
curl.exe -i http://localhost:8081
```

8081 포트에서도 웹 서버를 실행하고 접속을 검증했다.

접속 증거: [web-8081.png](../screenshots/web-8081.png)

## 8. 포트 매핑 설명

`-p 8080:80`은 Windows 호스트의 8080번 포트를 컨테이너의 80번 포트에 연결한다.

컨테이너는 격리된 네트워크 환경에서 실행되므로 호스트에서 접근하려면 포트 매핑이 필요하다.

동일한 이미지를 사용해도 서로 다른 호스트 포트로 여러 컨테이너를 실행할 수 있다.

## 9. 이미지와 컨테이너의 차이

- 이미지: 애플리케이션 실행에 필요한 파일과 설정을 담은 실행 템플릿
- 컨테이너: 이미지로부터 생성된 독립적인 실행 인스턴스

하나의 이미지에서 여러 컨테이너를 생성할 수 있다.

## 10. 추가 실습

- 바인드 마운트: 로컬 파일 변경을 컨테이너에 반영
- Docker 볼륨: 컨테이너 삭제 후 데이터 유지 확인

상세 내용은 [storage.md](storage.md)에 기록한다.
