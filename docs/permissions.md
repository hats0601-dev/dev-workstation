
# 파일 및 디렉터리 권한 실습

## 1. 실행 환경

- OS: Windows
- Shell: PowerShell
- 권한 체계: Windows ACL
- 프로젝트: dev-workstation

## 2. 실습 목표

파일과 디렉터리의 접근 권한을 확인하고, 권한 변경 전후 결과를 비교한다.

## 3. 파일 권한 실습

### 3.1 파일 생성

```powershell
New-Item -ItemType Directory -Path permissions -Force
New-Item -ItemType File -Path permissions\test.txt -Force
```

### 3.2 변경 전 권한 확인

```powershell
Get-Acl permissions\test.txt | Format-List
```

확인 결과:

```text
IdentityReference : GNIA\hats06012038
FileSystemRights  : FullControl
IsInherited       : True
```

### 3.3 읽기 전용 속성 실습

```powershell
Set-Content permissions\test.txt "Permission Test"
Set-ItemProperty -Path permissions\test.txt -Name IsReadOnly -Value $true
Get-Item permissions\test.txt | Select-Object Name, IsReadOnly
```

확인 결과: IsReadOnly = True

이후 읽기 전용 속성을 해제했다.

```powershell
Set-ItemProperty -Path permissions\test.txt -Name IsReadOnly -Value $false
```

### 3.4 파일 ACL 권한 변경

```powershell
$file = "permissions\test.txt"
$acl = Get-Acl $file
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $user, "Read", "Allow"
)

$acl.AddAccessRule($rule)
Set-Acl -Path $file -AclObject $acl
```

### 3.5 변경 후 결과

```text
FileSystemRights  : Read, Synchronize
AccessControlType : Allow
IsInherited       : False
```

기존 FullControl 권한은 유지되고, 명시적인 Read 규칙이 추가되었다.

## 4. 디렉터리 권한 실습

### 4.1 변경 전 권한

```text
FileSystemRights : FullControl
IsInherited      : True
```

### 4.2 디렉터리 ACL 변경

```powershell
$dir = "permissions"
$acl = Get-Acl $dir
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $user,
    "ReadAndExecute",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)

$acl.AddAccessRule($rule)
Set-Acl -Path $dir -AclObject $acl
```

### 4.3 변경 후 결과

```text
FileSystemRights  : ReadAndExecute, Synchronize
AccessControlType : Allow
IsInherited       : False
InheritanceFlags  : ContainerInherit, ObjectInherit
```

기존 FullControl 권한은 유지되고, ReadAndExecute 규칙이 추가되었다.

## 5. Linux 파일 권한 개념

Linux에서는 r, w, x로 권한을 표현한다.

| 권한 | 의미 | 숫자 |
|---|---|---|
| r | 읽기 | 4 |
| w | 쓰기 | 2 |
| x | 실행 | 1 |

### 644 권한

- 소유자: rw-
- 그룹: r--
- 기타 사용자: r--

### 755 권한

- 소유자: rwx
- 그룹: r-x
- 기타 사용자: r-x

Linux에서는 chmod 명령어로 권한을 변경한다.

```bash
chmod 644 test.txt
chmod 755 example-directory
```

위 명령어는 개념 설명용이며 실제 실행 결과가 아니다.

## 6. 실습 결과

- [x] 파일 생성
- [x] 파일 권한 확인
- [x] 읽기 전용 속성 변경
- [x] 파일 ACL 규칙 추가
- [x] 디렉터리 ACL 규칙 추가
- [x] 변경 전후 비교
- [x] Linux 644, 755 권한 개념 정리
- [ ] Linux chmod 실제 실행 검증

## 7. 결론

Windows PowerShell에서 파일과 디렉터리의 ACL 권한을 확인하고 명시적인 접근 규칙을 추가했다.

기존 FullControl 권한이 유지되므로 접근 제한 실험은 아니다.

Windows ACL과 Linux chmod는 서로 다른 권한 체계이며, Linux에서의 실제 권한 변경은 별도 환경에서 검증할 예정이다.


---

## 8. Docker Ubuntu에서 Linux 권한 변경 실습

### 실행 환경
- Docker Engine: 29.9.2
- 이미지: ubuntu:24.04
- 컨테이너: ubuntu-practice

### 8.1 Ubuntu 컨테이너 실행

```powershell
docker run -it --name ubuntu-practice ubuntu:24.04 bash
```

### 8.2 파일 및 디렉터리 생성

```bash
mkdir /permission-test
touch /permission-test/test.txt
ls -ld /permission-test
ls -l /permission-test/test.txt
```

실제 출력:

```text
drwxr-xr-x 2 root root 4096 Nov 2 10:40 /permission-test
-rw-r--r-- 1 root root 0 Nov 2 10:40 /permission-test/test.txt
```

### 8.3 권한을 700, 600으로 변경

```bash
chmod 700 /permission-test
chmod 600 /permission-test/test.txt
ls -ld /permission-test
ls -l /permission-test/test.txt
```

실제 출력:

```text
drwx------ 2 root root 4096 Nov 2 10:40 /permission-test
-rw------- 1 root root 0 Nov 2 10:40 /permission-test/test.txt
```

### 8.4 권한을 755, 644로 변경

```bash
chmod 755 /permission-test
chmod 644 /permission-test/test.txt
ls -ld /permission-test
ls -l /permission-test/test.txt
```

실제 출력:

```text
drwxr-xr-x 2 root root 4096 Nov 2 10:40 /permission-test
-rw-r--r-- 1 root root 0 Nov 2 10:40 /permission-test/test.txt
```

### 8.5 검증 결과

| 대상 | 최초 권한 | 변경 권한 | 최종 권한 |
|---|---|---|---|
| 디렉터리 | 755 | 700 | 755 |
| 파일 | 644 | 600 | 644 |

컨테이너 종료 후 재시작해도 파일 및 권한이 유지되는 것을 확인했다.

최종 상태 확인 로그: [linux-permissions.txt](../logs/linux-permissions.txt)

### 결론

Linux에서 chmod 명령어를 이용하여 파일과 디렉터리의 권한을 변경하고, ls -l 및 ls -ld 명령어로 변경 결과를 검증했다.
