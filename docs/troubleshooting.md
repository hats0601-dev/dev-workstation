
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
CommandNotFoundException
```

### 해결
Git 설치 및 터미널 재실행 후 정상 동작을 확인했다.

```powershell
git --version
```

결과:
```text
git version 2.56.0.windows.4
```

### 결과
해결 완료.

---

## 2. WSL2 가상화 환경 오류

### 문제
WSL2를 실행할 수 없다는 오류가 발생했다.

### 원인 가설
- Windows 가상 머신 플랫폼 기능이 활성화되지 않았을 가능성
- 가상화 환경이 제한되었을 가능성
- 시스템 재시작이 필요할 가능성

### 확인
```powershell
wsl --status
```

결과:
```text
가상화가 활성화되지 않은 이 컴퓨터에서는 WSL2를 시작할 수 없습니다.
```

추가 확인:
```powershell
Get-CimInstance Win32_Processor |
    Select-Object Name, VirtualizationFirmwareEnabled, VMMonitorModeExtensions
```

결과:
```text
VirtualizationFirmwareEnabled : False
VMMonitorModeExtensions       : False
```

`systeminfo`에서는 하이퍼바이저가 감지되었으므로 실제 제한 원인은 추가 확인이 필요하다.

### 대응
관리자 권한 및 가상화 설정 변경이 제한될 수 있어 강제로 설정하지 않았다.

Docker 실행이 필요한 실습은 사용 가능한 컨테이너 환경을 확보한 뒤 진행할 예정이다.

### 결과
미해결 — 대체 실행 환경 확인 필요.

---

## 3. Windows 관리자 권한 부족

### 문제
Windows 선택적 기능 상태를 확인하려 했으나 권한 오류가 발생했다.

### 확인
```powershell
Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
```

결과:
```text
요청한 작업을 수행하려면 권한 상승이 필요합니다.
```

### 원인 가설
현재 PowerShell이 관리자 권한으로 실행되지 않았다.

### 대응
교육장 컴퓨터의 시스템 설정을 임의로 변경하지 않고 일반 사용자 권한에서 수행 가능한 작업을 먼저 진행했다.

### 결과
관리자 권한이 필요한 기능 확인은 보류.
