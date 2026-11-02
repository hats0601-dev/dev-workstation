# 터미널 기본 조작 실습

## 실행 환경
- OS: Windows
- Shell: PowerShell
- Git: 2.56.0.windows.4

## 수행 명령어

### 1. 디렉토리 생성 및 이동
mkdir practice
cd practice
pwd

### 2. 숨김 파일 포함 목록 확인
Get-ChildItem -Force

### 3. 파일 생성 및 내용 확인
New-Item -ItemType File -Name "hello.txt"
Set-Content hello.txt "Hello Dev Workstation"
Get-Content hello.txt

확인 결과: Hello Dev Workstation

### 4. 파일 복사
Copy-Item hello.txt copy.txt
Get-ChildItem

확인 결과: hello.txt, copy.txt

### 5. 이름 변경
Rename-Item copy.txt renamed.txt
Get-ChildItem

확인 결과: hello.txt, renamed.txt

### 6. 파일 삭제
Remove-Item renamed.txt
Get-ChildItem

확인 결과: hello.txt만 남음

### 7. 상위 디렉토리 이동
cd ..
pwd

확인 결과: dev-workstation 디렉토리로 이동

## 실제 실행 증거

파일 및 디렉터리 생성, 이동, 복사, 이름 변경, 삭제 명령어를 재실행하고 실제 출력 결과를 저장했습니다.

- [터미널 실습 출력 로그](../logs/terminal-output.txt)

임시 실습 디렉터리가 삭제된 것도 `Test-Path` 결과 `False`로 검증했습니다.
