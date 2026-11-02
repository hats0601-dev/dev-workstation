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

## 참고
위 결과는 실습 확인 사항을 요약한 것입니다.
실제 터미널 출력 원문은 별도 증거로 보완할 예정입니다.
