
# 개발 환경 트러블슈팅

## 1. Git 명령어 인식 실패

### 문제

PowerShell에서 `git --version`을 실행했으나 명령어를 인식하지 못했다.

### 원인 가설

- Git이 설치되지 않았을 가능성
- Git 실행 경로가 PATH 환경변수에 등록되지 않았을 가능성

### 확인

```powershell
git --version
```

초기 결과:

```text
git : 'git' 용어가 cmdlet, 함수, 스크립트 파일 또는 실행할 수 있는 프로그램 이름으로 인식되지 않습니다.
FullyQualifiedErrorId : CommandNotFoundException
```

### 해결 과정

1. Git 설치 여부를 확인했다.
2. Git 설치 명령어를 실행했다.
3. 설치 후 PowerShell을 다시 실행했다.
4. Git 버전을 확인했다.

설치 명령어:

```powershell
winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
```

검증 명령어:

```powershell
git --version
```

실제 출력:

```text
git version 2.56.0.windows.4
```

### 최종 결과

**해결 완료**

Git을 정상적으로 사용할 수 있게 되었으며, GitHub 저장소 Clone, Commit, Push 작업까지 성공했다.

---

## 2. WSL2 가상화 환경 오류

### 문제

Docker Desktop을 설치했으나 WSL2 가상화 오류로 Docker 엔진을 실행할 수 없었다.

Docker CLI 명령어는 정상적으로 인식됐지만 Docker 엔진(Server)에 연결하지 못했다.

### 원인 가설

- Windows Virtual Machine Platform 기능이 비활성화되었을 가능성
- 교육장 컴퓨터의 가상화 환경이 제한되었을 가능성
- 시스템 재시작이 필요할 가능성

### 확인

WSL 상태 확인:

```powershell
wsl --status
```

실제 오류:

```text
기본 버전: 2

가상화가 활성화되지 않은 이 컴퓨터에서는 WSL2를 시작할 수 없습니다.

컴퓨터의 펌웨어 설정에서 '가상 머신 플랫폼' 선택적 구성 요소가 활성화되고, 가상화가 켜져 있는지 확인하세요.
```

추가 확인:

```powershell
Get-CimInstance Win32_Processor |
    Select-Object Name, VirtualizationFirmwareEnabled, VMMonitorModeExtensions
```

실제 결과:

```text
VirtualizationFirmwareEnabled : False
VMMonitorModeExtensions       : False
```

Docker 엔진 확인:

```powershell
docker info
```

초기 오류:

```text
Server:
failed to connect to the docker API at npipe:////./pipe/docker_engine

The system cannot find the file specified.
```

Docker Desktop에서도 다음 오류가 발생했다.

```text
Virtual Machine Platform is not enabled
```

### 해결 과정

1. `wsl --status` 실행 시 가상화 관련 오류가 발생했다.
2. Docker Desktop 4.97.0을 설치했다.
3. Docker CLI는 정상 동작했으나 Docker 엔진 연결에 실패했다.
4. Docker Desktop에서 Virtual Machine Platform 관련 오류를 확인했다.
5. Windows 기능 활성화를 시도했지만 관리자 권한 부족으로 실패했다.
6. Docker Desktop 설정에서 WSL2 대신 Docker VMM 백엔드를 선택했다.
7. Docker Desktop을 재시작한 뒤 Docker 엔진이 정상 실행됐다.

Docker Desktop 설치 명령어:

```powershell
winget install --id Docker.DockerDesktop -e --accept-package-agreements --accept-source-agreements
```

설치 결과:

```text
Successfully installed
```

### 해결 후 검증

Docker 버전 확인:

```powershell
docker --version
```

실제 출력:

```text
Docker version 29.9.2, build a82e528
```

Docker 엔진 확인:

```powershell
docker info
```

실제 확인 결과:

```text
Server Version: 29.9.2
Storage Driver: overlayfs
Operating System: Docker Desktop
OSType: linux
Architecture: x86_64
CPUs: 24
Total Memory: 3.876GiB
```

추가 검증:

```powershell
docker run hello-world
```

실제 출력:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### 최종 결과

**Docker 실행 문제 해결 완료**

Docker VMM 백엔드로 변경하여 Docker 엔진 및 Linux 컨테이너 실행에 성공했다.

이후 다음 작업도 정상적으로 수행했다.

- Ubuntu 24.04 컨테이너 실행
- NGINX 기반 커스텀 이미지 빌드
- 8080, 8081 포트 매핑
- 바인드 마운트 변경 반영
- Docker 볼륨 영속성 검증

단, WSL2 자체의 오류를 해결한 것은 아니며 Docker 실행 백엔드를 변경하여 실습을 진행한 것이다.

검증 로그:

- [Docker 엔진 점검 로그](../logs/docker-check.txt)
- [hello-world 실행 로그](../logs/hello-world.txt)
- [Docker 실습 기술 문서](docker.md)
- [Docker 스토리지 검증 문서](storage.md)

---

## 3. Windows 관리자 권한 부족

### 문제

Windows 선택적 기능인 Virtual Machine Platform의 상태를 확인하거나 활성화하려 했으나 권한 오류가 발생했다.

### 원인 가설

- PowerShell을 일반 사용자 권한으로 실행했다.
- Windows 시스템 기능 변경에 관리자 권한이 필요했다.
- 교육장 컴퓨터의 관리 정책으로 시스템 설정 변경이 제한될 가능성이 있었다.

### 확인

기능 상태 확인 명령어:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
```

실제 오류:

```text
Get-WindowsOptionalFeature : 요청한 작업을 수행하려면 권한 상승이 필요합니다.
```

기능 활성화 시도:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
```

실제 오류:

```text
Enable-WindowsOptionalFeature : 요청한 작업을 수행하려면 권한 상승이 필요합니다.
```

### 대응

1. Windows 기능 변경에 관리자 권한이 필요한 것을 확인했다.
2. 교육장 컴퓨터의 시스템 설정을 강제로 변경하지 않았다.
3. 재부팅이 필요할 수 있는 WSL2 설정 변경을 중단했다.
4. Docker Desktop에서 다른 실행 백엔드를 사용할 수 있는지 확인했다.
5. Docker VMM 백엔드를 선택하여 Docker 엔진 실행에 성공했다.

### 최종 결과

**Docker 실습 진행 가능 — 관리자 권한 문제는 우회**

Windows의 Virtual Machine Platform 기능을 직접 변경하지 않고 Docker VMM 백엔드를 사용했다.

관리자 권한 자체를 확보하거나 Windows 기능 설정 문제를 해결한 것은 아니지만, Docker 실행이라는 실습 목표는 달성했다.

---

## 4. Docker 볼륨 파일 생성 시 명령어 오류

### 문제

Docker 볼륨에 파일을 생성하려 했으나 파일이 정상적으로 생성되지 않았다.

최초 실행 명령어:

```powershell
docker exec volume-test-1 sh -c 'echo "Docker Volume Persistence Test" > /data/test.txt'
```

실제 출력:

```text
Docker
```

이후 파일 확인 명령어:

```powershell
docker exec volume-test-1 cat /data/test.txt
```

실제 오류:

```text
cat: /data/test.txt: No such file or directory
```

### 원인 가설

Windows PowerShell에서 Docker 명령어의 따옴표 및 인수 전달이 예상과 다르게 처리되었을 가능성이 있었다.

### 해결 과정

따옴표 처리 문제를 피하기 위해 파일에 저장할 문자열에서 공백을 제거하고 밑줄을 사용했다.

수정한 명령어:

```powershell
docker exec volume-test-1 sh -c 'echo Docker_Volume_Persistence_Test > /data/test.txt'
```

### 해결 후 검증

```powershell
docker exec volume-test-1 cat /data/test.txt
```

실제 출력:

```text
Docker_Volume_Persistence_Test
```

이후 첫 번째 컨테이너를 삭제하고 동일한 볼륨을 연결한 새 컨테이너를 생성했다.

```powershell
docker rm -f volume-test-1

docker run -d --name volume-test-2 -v workstation-data:/data ubuntu:24.04 sleep infinity

docker exec volume-test-2 cat /data/test.txt
```

실제 출력:

```text
Docker_Volume_Persistence_Test
```

### 최종 결과

**해결 완료**

파일 생성 명령어를 수정하여 데이터를 정상적으로 저장했으며, 컨테이너를 삭제한 후에도 데이터가 유지되는 것을 확인했다.

검증 로그:

- [컨테이너 삭제 전 데이터](../logs/volume-before.txt)
- [컨테이너 삭제 후 데이터](../logs/volume-after.txt)
- [볼륨 영속성 실습 문서](storage.md)

---

## 5. 트러블슈팅 결과 요약

| 번호 | 문제 | 해결 결과 |
|---|---|---|
| 1 | Git 명령어 인식 실패 | Git 설치 후 정상 작동 |
| 2 | WSL2 가상화 오류 | Docker VMM 전환으로 Docker 실행 성공 |
| 3 | Windows 관리자 권한 부족 | 시스템 설정 변경 없이 Docker VMM 활용 |
| 4 | Docker 볼륨 파일 생성 실패 | 명령어 수정 후 파일 생성 및 영속성 검증 성공 |

## 결론

이번 실습에서는 개발 환경 구성 중 발생하는 명령어 인식 오류, 가상화 환경 오류, 관리자 권한 문제, Docker 컨테이너 내부 파일 생성 문제를 경험했다.

문제 발생 시 오류 메시지를 확인하고 원인을 가설로 설정한 뒤, 실제 명령어로 검증하고 해결 방법을 적용하는 과정을 수행했다.

특히 교육장 컴퓨터의 제한된 환경에서도 Docker VMM 백엔드를 활용하여 컨테이너 실행 및 Docker 핵심 기능 검증을 완료했다.
