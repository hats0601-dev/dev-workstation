
# Development Workstation 구축 미션

Windows 환경에서 터미널, Git/GitHub, Docker를 활용하여 재현 가능한 개발 워크스테이션을 구축한 프로젝트입니다.

NGINX 기반 웹 서버를 Docker 이미지로 제작하고, 컨테이너 실행, 포트 매핑, 바인드 마운트, Docker 볼륨 영속성을 실제로 검증했습니다.

## 1. 프로젝트 목표

- 터미널 기반 파일 및 디렉터리 조작
- Windows ACL 및 Linux 파일 권한 이해
- Docker 설치와 컨테이너 실행 환경 구축
- Dockerfile을 이용한 커스텀 웹 서버 이미지 제작
- 포트 매핑을 통한 웹 서버 접속
- 바인드 마운트를 통한 파일 변경 반영
- Docker 볼륨을 통한 데이터 영속성 검증
- Git과 GitHub를 활용한 버전 관리 및 협업 환경 구성
- 실행 결과와 트러블슈팅 문서화

## 2. 실행 환경

| 항목 | 환경 |
|---|---|
| OS | Windows |
| Shell | PowerShell |
| Editor | Visual Studio Code |
| Git | 2.56.0.windows.4 |
| Docker Desktop | 4.97.0 |
| Docker Engine / CLI | 29.9.2 |
| Docker Compose | 5.6.1 |
| Docker Context | desktop-linux |
| 컨테이너 OS | Linux |
| 웹 서버 | NGINX |
| 베이스 이미지 | nginx:stable-alpine |
| Ubuntu 이미지 | ubuntu:24.04 |
| Docker 실행 방식 | Docker VMM |

교육장 Windows PC에서 WSL2 가상화 문제가 발생하여 Docker Desktop의 Docker VMM 백엔드로 변경한 뒤 실행에 성공했습니다.

Docker 환경 점검 로그: [docker-check.txt](logs/docker-check.txt)

## 3. 프로젝트 구조

```text
dev-workstation/
├── README.md
├── Dockerfile
├── site/
│   └── index.html
├── practice/
│   └── hello.txt
├── permissions/
│   └── test.txt
├── docs/
│   ├── terminal.md
│   ├── permissions.md
│   ├── docker.md
│   ├── storage.md
│   └── troubleshooting.md
├── logs/
│   ├── docker-check.txt
│   ├── hello-world.txt
│   ├── linux-permissions.txt
│   ├── web-8080.txt
│   ├── web-8081.txt
│   ├── bind-before.txt
│   ├── bind-after.txt
│   ├── volume-before.txt
│   └── volume-after.txt
└── screenshots/
    ├── web-8080.png
    └── web-8081.png
```

## 4. 미션 수행 체크리스트

- [x] Git 설치 및 사용자 정보 설정
- [x] GitHub 저장소 생성 및 연동
- [x] VSCode에서 프로젝트 연동
- [x] 터미널 기본 명령어 실습
- [x] 파일과 디렉터리 생성, 복사, 이동, 삭제
- [x] Windows ACL 권한 변경
- [x] Linux chmod 644, 755 권한 변경
- [x] Docker 설치 및 엔진 점검
- [x] hello-world 컨테이너 실행
- [x] Ubuntu 컨테이너 실행 및 내부 진입
- [x] Docker 이미지·컨테이너 운영 명령어 실습
- [x] Dockerfile 작성 및 커스텀 이미지 빌드
- [x] 웹 서버 8080 포트 접속
- [x] 웹 서버 8081 포트 접속
- [x] 바인드 마운트 변경 반영 검증
- [x] Docker 볼륨 영속성 검증
- [x] GitHub Push/Pull 실습
- [x] 트러블슈팅 2건 이상 문서화

## 5. 터미널 및 파일 권한 실습

### 터미널 명령어

PowerShell에서 다음 작업을 수행했습니다.

```powershell
pwd
Get-ChildItem -Force
mkdir practice
cd practice
New-Item -ItemType File -Name hello.txt
Set-Content hello.txt "Hello Dev Workstation"
Get-Content hello.txt
Copy-Item hello.txt copy.txt
Rename-Item copy.txt renamed.txt
Remove-Item renamed.txt
cd ..
```

실습 기록: [terminal.md](docs/terminal.md)

### Linux 파일 권한

Ubuntu 컨테이너에서 파일과 디렉터리의 권한을 변경했습니다.

```bash
chmod 600 /permission-test/test.txt
chmod 700 /permission-test

chmod 644 /permission-test/test.txt
chmod 755 /permission-test
```

검증 결과:

| 대상 | 변경 과정 | 최종 권한 |
|---|---|---|
| 파일 | 644 → 600 → 644 | rw-r--r-- |
| 디렉터리 | 755 → 700 → 755 | rwxr-xr-x |

권한의 숫자는 읽기(r=4), 쓰기(w=2), 실행(x=1)을 합산하여 표현합니다.

상세 문서: [permissions.md](docs/permissions.md)

최종 검증 로그: [linux-permissions.txt](logs/linux-permissions.txt)

## 6. Docker 설치 및 기본 검증

### Docker 버전

```powershell
docker --version
```

실제 확인 결과:

```text
Docker version 29.9.2, build a82e528
```

### Docker 엔진 상태

```powershell
docker info
```

확인 결과:

```text
Server Version: 29.9.2
Operating System: Docker Desktop
OSType: linux
Architecture: x86_64
```

### hello-world 실행

```powershell
docker run hello-world
```

실행 결과:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

검증 로그: [hello-world.txt](logs/hello-world.txt)

### Ubuntu 컨테이너 실행

```powershell
docker run -it --name ubuntu-practice ubuntu:24.04 bash
```

Ubuntu 내부에서 `pwd`, `ls -la`, `echo`를 실행하고, 컨테이너 종료 및 재진입도 확인했습니다.

### Docker 운영 명령어

```powershell
docker images
docker ps
docker ps -a
docker logs dev-web-8080
docker stats --no-stream
docker stop ubuntu-practice
```

운영 기록: [docker.md](docs/docker.md)

상태 로그: [docker-check.txt](logs/docker-check.txt)

## 7. 커스텀 Docker 이미지 제작

### 베이스 이미지

`nginx:stable-alpine`

기존 NGINX 이미지에 직접 작성한 HTML 콘텐츠와 메타데이터를 추가했습니다.

### Dockerfile

```dockerfile
FROM nginx:stable-alpine

LABEL org.opencontainers.image.title="dev-workstation-web"
LABEL org.opencontainers.image.description="Development workstation mission web server"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
```

커스텀 포인트:

1. NGINX 기반 이미지 사용
2. LABEL로 이미지 정보 추가
3. COPY로 직접 작성한 웹페이지 포함
4. EXPOSE로 컨테이너의 HTTP 포트 명시

원본 파일: [Dockerfile](Dockerfile)

웹페이지: [index.html](site/index.html)

### 이미지 빌드

프로젝트 루트 디렉터리에서 실행합니다.

```powershell
docker build -t dev-workstation-web:1.0 .
```

이미지 확인:

```powershell
docker images
```

생성된 이미지:

```text
dev-workstation-web:1.0
```

## 8. 포트 매핑 및 웹 서버 검증

### 8080 포트 실행

```powershell
docker run -d --name dev-web-8080 -p 8080:80 dev-workstation-web:1.0
curl.exe -i http://localhost:8080
```

실제 결과:

```text
HTTP/1.1 200 OK
Server: nginx/1.30.6
```

![8080 포트 접속 화면](screenshots/web-8080.png)

### 8081 포트 실행

```powershell
docker run -d --name dev-web-8081 -p 8081:80 dev-workstation-web:1.0
curl.exe -i http://localhost:8081
```

![8081 포트 접속 화면](screenshots/web-8081.png)

포트 매핑은 호스트 PC의 포트를 컨테이너 내부 포트에 연결하는 기능입니다.

`-p 8080:80`은 호스트의 8080번 포트를 컨테이너의 80번 포트에 연결합니다.

동일한 이미지로 여러 컨테이너를 생성할 수 있으며, 각각 다른 호스트 포트를 사용할 수 있습니다.

상세 문서: [docker.md](docs/docker.md)

## 9. 바인드 마운트 검증

Windows 호스트의 `site` 폴더를 NGINX 컨테이너에 연결했습니다.

```powershell
docker run -d --name dev-web-bind -p 8082:80 --mount "type=bind,source=$((Get-Location).Path)\site,target=/usr/share/nginx/html,readonly" dev-workstation-web:1.0
```

### 변경 전

```html
<p>Status: Ready</p>
```

### 변경 후

```html
<p>Status: Bind Mount Updated!</p>
```

호스트 파일을 변경한 뒤 컨테이너를 재시작하거나 이미지를 재빌드하지 않고 다음 명령어로 확인했습니다.

```powershell
curl.exe http://localhost:8082
```

변경 사항이 즉시 반영됐습니다.

증거:

- [변경 전 HTML 응답](logs/bind-before.txt)
- [변경 후 HTML 응답](logs/bind-after.txt)

상세 문서: [storage.md](docs/storage.md)

## 10. Docker 볼륨 영속성 검증

### 볼륨 생성

```powershell
docker volume create workstation-data
```

### 첫 번째 컨테이너 생성

```powershell
docker run -d --name volume-test-1 -v workstation-data:/data ubuntu:24.04 sleep infinity
```

### 파일 저장

```powershell
docker exec volume-test-1 sh -c 'echo Docker_Volume_Persistence_Test > /data/test.txt'
```

확인 결과:

```text
Docker_Volume_Persistence_Test
```

### 첫 번째 컨테이너 삭제

```powershell
docker rm -f volume-test-1
```

### 두 번째 컨테이너 생성

```powershell
docker run -d --name volume-test-2 -v workstation-data:/data ubuntu:24.04 sleep infinity
```

### 데이터 유지 확인

```powershell
docker exec volume-test-2 cat /data/test.txt
```

실제 결과:

```text
Docker_Volume_Persistence_Test
```

컨테이너를 삭제해도 동일한 Docker 볼륨에 저장된 데이터가 유지되는 것을 확인했습니다.

증거:

- [컨테이너 삭제 전 데이터](logs/volume-before.txt)
- [컨테이너 삭제 후 데이터](logs/volume-after.txt)

상세 문서: [storage.md](docs/storage.md)

## 11. Git 및 GitHub 연동

Git은 로컬 컴퓨터에서 소스코드의 변경 이력을 관리하는 도구입니다.

GitHub는 Git 저장소를 원격으로 보관하고 협업할 수 있도록 제공하는 플랫폼입니다.

### Git 설정

```powershell
git config --global user.name "hats0601-dev"
git config --global init.defaultBranch main
git config --global --list
```

Git 이메일도 설정했으며 개인정보 보호를 위해 문서에는 전체 주소를 기록하지 않았습니다.

### 저장소 복구

```powershell
git clone https://github.com/hats0601-dev/dev-workstation.git
```

### 변경 사항 업로드

```powershell
git add .
git commit -m "docs: update workstation mission"
git push origin main
```

### 기존 저장소 업데이트

```powershell
git pull origin main
```

### 원격 저장소 확인

```powershell
git remote -v
```

원격 저장소:

[GitHub Repository](https://github.com/hats0601-dev/dev-workstation)

### VSCode 및 GitHub 연동 증거

![VSCode 저장소 연동](screenshots/vscode-github.png)

## 12. 트러블슈팅

실습 중 발생한 문제를 원인 가설, 확인, 해결 과정으로 정리했습니다.

| 문제 | 대응 결과 |
|---|---|
| Git 명령어 인식 실패 | Git 설치 후 정상 동작 |
| WSL2 가상화 오류 | Docker VMM 전환으로 Docker 엔진 실행 성공 |
| Windows 관리자 권한 부족 | 시스템 기능 변경 없이 다른 백엔드 사용 |
| Docker 볼륨 파일 생성 오류 | 명령어 수정 후 데이터 저장 성공 |

상세 문서: [troubleshooting.md](docs/troubleshooting.md)

## 13. 재현 방법

### 준비 사항

- Docker 엔진을 실행할 수 있는 Windows 환경
- Docker Desktop
- Git
- 인터넷 연결

### 저장소 가져오기

```powershell
git clone https://github.com/hats0601-dev/dev-workstation.git
cd dev-workstation
```

### Docker 엔진 확인

```powershell
docker info
```

### 이미지 빌드

```powershell
docker build -t dev-workstation-web:1.0 .
실제 빌드 출력 로그: [docker-build.txt](logs/docker-build.txt)
```

### 웹 서버 실행

```powershell
docker run -d --name dev-web-8080 -p 8080:80 dev-workstation-web:1.0
```

### 접속 확인

브라우저에서 다음 주소를 엽니다.

http://localhost:8080

또는 다음 명령어를 실행합니다.

```powershell
curl.exe -i http://localhost:8080
```

### 주의사항

- 컨테이너 이름이나 호스트 포트가 이미 사용 중이면 이름 또는 포트를 변경해야 합니다.
- 다른 PC에서는 프로젝트 경로가 달라질 수 있으므로 바인드 마운트에 현재 작업 경로를 사용합니다.
- Docker Desktop의 실행 백엔드는 PC의 가상화 지원 및 Windows 설정에 따라 달라질 수 있습니다.
- GitHub에는 소스코드와 증거 로그가 저장되지만 Docker 이미지, 컨테이너, 볼륨 데이터 자체는 자동으로 동기화되지 않습니다.
- Docker 실행 환경이 초기화되면 이미지 빌드 및 컨테이너 생성 작업을 다시 수행해야 합니다.

## 14. 최종 결과

이번 미션에서는 Windows 개발 환경에서 Git/GitHub와 Docker를 연동하고, NGINX 기반 웹 서버를 컨테이너화했습니다.

Docker 이미지와 컨테이너의 차이, 포트 매핑, 바인드 마운트, 볼륨 영속성을 실제 실행 결과로 확인했습니다.

또한 제한된 교육장 환경에서 발생한 문제를 분석하고 Docker VMM을 사용해 실행 환경을 구성했습니다.

모든 주요 실습 결과는 `docs/`, `logs/`, `screenshots/`에서 확인할 수 있습니다.
