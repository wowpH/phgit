@echo off
setlocal enabledelayedexpansion

@REM ������¡��ȡ�ű�
@REM ���ߣ�pH
@REM ʱ�䣺2025/07/07 21:15:00
@REM usage: phgit [����] [����]
@REM [����] [����]:
@REM    -c [�ļ�]       ��¡�ļ��е�ÿ��URL����ǰĿ¼��
@REM    clone [�ļ�]    ��¡�ļ��е�ÿ��URL����ǰĿ¼��
@REM    -p              ��ȡ��ǰĿ¼�µ�ÿ���ֿ�
@REM    pull            ��ȡ��ǰĿ¼�µ�ÿ���ֿ�
@REM    -b [��֧��]     �л���ǰĿ¼�����вֿ⵽ָ���ķ�֧
@REM    branch [��֧��] �л���ǰĿ¼�����вֿ⵽ָ���ķ�֧
@REM    -h              �鿴������Ϣ
@REM    help            �鿴������Ϣ
@REM    -c -h           �鿴phgit -c����İ�����Ϣ����Ҫ��[�ļ�]��ʽ
@REM                    [�ļ�]����ʾ����
@REM                    https://github.com/wowpH/demo1.git
@REM                    https://github.com/wowpH/demo2.git
@REM phgit����ʾ����
@REM    phgit -c url.txt 
@REM    phgit -p

:: ��ʼ��������
set /a total=0
set /a success=0
set /a failed=0

:: ��������
if "%1"=="-c" goto clone
if "%1"=="clone" goto clone
if "%1"=="-p" goto pull
if "%1"=="pull" goto pull
if "%1"=="-b" goto branch
if "%1"=="branch" goto branch
if "%1"=="-h" goto help
if "%1"=="help" goto help

:: �޲����������Чʱ��ʾ����
goto help

:clone
:: ����Ƿ���ʾ��¡�������
if "%2"=="-h" goto clone_help

:: ����ļ������Ƿ��ṩ
if "%2"=="" (
    echo ����ȱ���ļ�����
    goto clone_help
)

:: ����ļ��Ƿ����
if not exist "%2" (
    echo �����ļ�"%2"������
    goto end
)

:: ��ʼ�����ȼ�����
set /a processed=0
set /a total=0

:: ��ͳ����URL��
for /f "usebackq delims=" %%i in ("%2") do (
    set "url=%%i"
    if not "!url!"=="" (
        set /a total+=1
    )
)

echo ��ʼ������¡�ֿ�...
echo �ֿܲ���: %total%
echo.

for /f "usebackq delims=" %%i in ("%2") do (
    set "url=%%i"
    if not "!url!"=="" (
        set /a processed+=1
        set /a percent=processed*100/total
        set "progress="
        for /l %%p in (1,1,!percent!) do set "progress=!progress!��"
        for /l %%p in (!percent!,1,99) do set "progress=!progress! "
        
        echo ���ڿ�¡: !url!
        @REM ��¡��ָ��Ŀ¼
        git clone "!url!" "./repos/%date:~0,4%%date:~5,2%%date:~8,2%/%%~nxi"
        if !errorlevel! equ 0 (
            set /a success+=1
            echo [�ɹ�] ��¡���
        ) else (
            set /a failed+=1
            echo [ʧ��] ��¡ʧ��
        )
        echo ����: [!progress!] !percent!%%
        echo.
    )
)

echo ��¡���:
echo     ����: %total%
echo     �ɹ�: %success%
echo     ʧ��: %failed%
goto end

:clone_help
echo.
echo phgit %1       ������¡Git�ֿ�
echo.
echo �÷�: phgit %1 [ѡ��] ^<�ļ�^>
echo.
echo ѡ��:
echo    -h          ��ʾ�˰�����Ϣ
echo.
echo ����:
echo    ^<�ļ�^>      ����Git�ֿ�URL�б���ı��ļ�
echo.
echo �ļ���ʽ, ÿ��һ��Git�ֿ�URL, ����:
echo    https://github.com/wowpH/demo1.git
echo    https://github.com/wowpH/demo2.git
echo.
echo ʾ��:
echo    phgit %1 url.txt
echo    phgit %1 -h
goto end

:pull
:: ��ʼ�����ȼ�����
set /a processed=0
set /a total=0

:: ��ͳ���ֿܲ���
for /d %%i in (*) do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo ��ʼ������ȡ����...
echo �ֿܲ���: %total%
echo.

for /d %%i in (*) do (
    if exist "%%i\.git" (
        set /a processed+=1
        set /a percent=processed*100/total
        set "progress="
        for /l %%p in (1,1,!percent!) do set "progress=!progress!��"
        for /l %%p in (!percent!,1,99) do set "progress=!progress! "
        
        echo ���ڴ���: %%i
        cd /d "%%i"
        git pull
        if !errorlevel! equ 0 (
            set /a success+=1
            echo [�ɹ�] ��ȡ���
        ) else (
            set /a failed+=1
            echo [ʧ��] ��ȡʧ��
        )
        cd ..
        echo ����: [!progress!] !percent!%%
        echo.
    )
)

echo ��ȡ���:
echo     ����: %total%
echo     �ɹ�: %success%
echo     ʧ��: %failed%
goto end

:branch
:: ����֧�����Ƿ��ṩ
if "%2"=="" (
    echo ����ȱ�ٷ�֧������
    goto help
)

:: ��ʼ�����ȼ�����
set /a processed=0
set /a total=0

:: ��ͳ���ֿܲ���
for /d %%i in (*) do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo ��ʼ�����л���֧��: %2
echo �ֿܲ���: %total%
echo.

for /d %%i in (*) do (
    if exist "%%i\.git" (
        set /a processed+=1
        echo ���ڴ���: %%i
        cd /d "%%i"
        git checkout "%2" 2>&1
        if !errorlevel! equ 0 (
            set /a success+=1
            echo [�ɹ�] �л�����֧ %2
        ) else (
            set /a failed+=1
            echo [ʧ��] �л�ʧ��
        )
        cd ..
        echo ����: !processed!/%total%
        echo.
    )
)

echo ��֧�л����:
echo     ����: %total%
echo     �ɹ�: %success%
echo     ʧ��: %failed%
goto end

:help
echo.
echo ������¡��ȡ�ű� v1.0
echo.
echo �÷�: phgit ^<����^> [^<����^>]
echo.
echo �����б�:
echo    clone ^| -c ^<�ļ�^>      ������¡ָ���ļ��е�Git�ֿ�URL
echo    pull ^| -p              ������ȡ��ǰĿ¼�µ�����Git�ֿ�
echo    branch ^| -b ^<��֧��^>   �����л���ǰĿ¼������Git�ֿ⵽ָ����֧
echo    help ^| -h              ��ʾ�˰�����Ϣ
echo.
echo ѡ��:
echo    -h, --help             ��ʾָ������İ�����Ϣ
echo.
echo ʾ��:
echo    phgit clone url.txt    ��¡url.txt�ļ����г������вֿ�
echo    phgit -p               ��ȡ��ǰĿ¼�����вֿ�ĸ���
echo    phgit branch main      �����вֿ��л���main��֧
echo    phgit -c -h            ��ʾclone����İ�����Ϣ
goto end

:end
endlocal
