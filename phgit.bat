@echo off
setlocal enabledelayedexpansion

:: ��ȡ�����ļ��еĲֿ�Ŀ¼, Ĭ��Ϊ��ǰĿ¼
set "repos_dir=."
if exist "phgit.ini" (
    for /f "tokens=2 delims==" %%d in ('findstr "^repos=" phgit.ini') do (
        set "repos_dir=%%d"
    )
)

@REM ��ʼ���ܼ������� total Ϊ 0���ñ�������ͳ����Ҫ����� Git �ֿ�����
set /a total=0
@REM ��ʼ���ɹ��������� success Ϊ 0���ñ�������ͳ�Ƴɹ������ Git �ֿ�����
set /a success=0
@REM ��ʼ��ʧ�ܼ������� failed Ϊ 0���ñ�������ͳ��ʧ�ܴ���� Git �ֿ�����
set /a failed=0
@REM ��ʼ�����ȼ������� processed Ϊ 0���ñ�������ͳ�Ƶ�ǰ����� Git �ֿ�����
set /a processed=0

set "VALID_COMMANDS=clone pull switch set delete -h"
for %%i in (%VALID_COMMANDS%) do (
    if /i "%1"=="%%i" (
        if "%%i"=="-h" (
            goto help
        ) else (
            goto %%i
        )
    )
)
:: �޲����������Чʱ��ʾ����
goto help

:clone
:: ����Ƿ���ʾ��¡�������
if "%2"=="-h" goto clone_help
if "%2"=="" goto clone_help

:: ����ļ��Ƿ����
if not exist "%2" (
    echo ����: �ļ�"%2"������
    goto end
)

@REM set "timestamp=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
@REM set "repos_dir=%repos_dir%\%timestamp%"

:: ��ͳ����URL��
for /f "usebackq delims=" %%i in ("%2") do (
    set "url=%%i"
    if not "!url!"=="" (
        set /a total+=1
    )
)

echo ��ʼ������¡�ֿ�...
echo �ֿ�Ŀ¼: %repos_dir%
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
        set "repo_name=%%~nxi"
        set "repo_name=!repo_name:.git=!"
        git clone "!url!" "%repos_dir%\!repo_name!"
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
echo �÷�: 
echo    phgit %1 [ѡ��] ^<����^>
echo.
echo ѡ��:
echo    -h             ��ʾ�˰�����Ϣ
echo.
echo ����:
echo    ^<����^>         txt�ļ�·��(���·�������·��), �ļ�ÿ��һ��Git�ֿ�URL, ����:
echo.
echo                   url.txt
echo                   https://github.com/wowpH/demo1.git
echo                   https://github.com/wowpH/demo2.git
echo.
echo                   E:\IdeaProjects\phgit\url.txt
echo                   https://github.com/wowpH/demo1.git
echo                   https://github.com/wowpH/demo2.git
echo.
echo ʾ��:
echo    phgit %1 url.txt
echo    phgit %1 -h
goto end

:pull
:: ��ͳ���ֿܲ���
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo ��ʼ������ȡ����...
echo �ֿ�Ŀ¼: %repos_dir%
echo �ֿܲ���: %total%
echo.

for /d %%i in ("%repos_dir%\*") do (
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
        cd /d "%~dp0"
        echo ����: [!progress!] !percent!%%
        echo.
    )
)

echo ��ȡ���:
echo     ����: %total%
echo     �ɹ�: %success%
echo     ʧ��: %failed%
goto end

:switch
:: ����֧�����Ƿ��ṩ
if "%2"=="-h" goto switch_help
if "%2"=="" goto switch_help

:: ��ͳ���ֿܲ���
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo ��ʼ�����л���֧��: %2
echo �ֿ�Ŀ¼: %repos_dir%
echo �ֿܲ���: %total%
echo.

for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a processed+=1
        set /a percent=processed*100/total
        set "progress="
        for /l %%p in (1,1,!percent!) do set "progress=!progress!��"
        for /l %%p in (!percent!,1,99) do set "progress=!progress! "
        
        echo ���ڴ���: %%i
        cd /d "%%i"
        git switch "%2" 2>&1
        if !errorlevel! equ 0 (
            set /a success+=1
            echo [�ɹ�] �л�����֧ %2
        ) else (
            set /a failed+=1
            echo [ʧ��] �л�ʧ��
        )
        cd /d "%~dp0"
        echo ����: [!progress!] !percent!%%
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
echo ����git�ű� v1.0.1
echo.
echo �÷�:
echo    phgit [^<����^>] [ѡ��] [����]
echo.
echo ����:
echo    set         ���õ�ǰĿ¼����,δ������Ĭ�ϵ�ǰĿ¼
echo    clone       ������¡
echo    switch      �����л���֧
echo    pull        ������ȡ
echo    delete      ����ɾ���ֿ�
echo.
echo ѡ��:
echo    -h          ��ʾ������Ϣ
goto end

:set
:: ����Ƿ���ʾset�������
if "%2"=="-h" goto set_help

:: �������Ƿ��ṩ
if "%2"=="" (
    goto set_help
)

:: ���������ļ�
if not exist "phgit.ini" (
    echo [config] > phgit.ini
    echo ; phgit�����ļ� >> phgit.ini
    echo ; ��ʽ: key=value >> phgit.ini
)

:: ����������
if "%3"=="" (
    echo ����: ȱ��value����
    goto set_help
) else (
    :: ȥ��valueǰ��Ŀո�
    set "value=%3"
    for /f "tokens=*" %%a in ("!value!") do set "value=%%a"
    
    :: ��ɾ�����е�key
    findstr /v "%2=" phgit.ini > phgit.tmp
    move /y phgit.tmp phgit.ini > nul
    
    :: ����µ�key=value
    echo %2=!value!>> phgit.ini
    echo [�ɹ�] ������ %2=!value!
)

goto end

:set_help
echo.
echo phgit set                      ����phgit����
echo.
echo �÷�:
echo    phgit set [ѡ��] ^<key^> ^<value^>
echo.
echo ѡ��:
echo    -h                          ��ʾ�˰�����Ϣ
echo.
echo ����:
echo    ^<key^>                       ����������
echo    ^<value^>                     ������ֵ
echo.
echo key:
echo    repos                       �ֿ�Ŀ¼
echo.
echo ʾ��:
echo    phgit set repos .\repos     ���òֿ�Ŀ¼Ϊ��ǰĿ¼��repos��Ŀ¼
echo    phgit set -h                ��ʾset����İ�����Ϣ
goto end

:switch_help
echo.
echo phgit switch       �����л���֧
echo.
echo �÷�: phgit switch [ѡ��] ^<��֧��^>
echo.
echo ѡ��:
echo    -h              ��ʾ�˰�����Ϣ
echo.
echo ����:
echo    ^<��֧��^>        Ҫ�л����ķ�֧����
echo.
echo ʾ��:
echo    phgit switch main      �����вֿ��л���main��֧
echo    phgit switch -h        ��ʾswitch����İ�����Ϣ
goto end

:delete_help
echo.
echo phgit delete       ����ɾ���ֿ�
echo.
echo �÷�: phgit delete [ѡ��]
echo.
echo ѡ��:
echo    -h              ��ʾ�˰�����Ϣ
echo.
echo ˵��:
echo    �����ɾ�������ļ���reposĿ¼�µ�����Git�ֿ�
echo    ����ǰ����ʾȷ�ϣ�ɾ�����޷��ָ�
echo.
echo ʾ��:
echo    phgit delete           ����ɾ���ֿ�
echo    phgit delete -h        ��ʾdelete����İ�����Ϣ
goto end

:delete
:: ����Ƿ���ʾɾ���������
if "%2"=="-h" goto delete_help

:: ���ֿ�Ŀ¼�Ƿ����
if not exist "%repos_dir%" (
    echo ����: �ֿ�Ŀ¼"%repos_dir%"������
    goto end
)

:: ȷ��ɾ������
set /p confirm=ȷ��Ҫɾ��"%repos_dir%"�µ����вֿ���[y/N] 
if /i not "%confirm%"=="y" (
    echo ��ȡ��ɾ������
    goto end
)

:: ��ͳ���ֿܲ���
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo ��ʼ����ɾ���ֿ�...
echo �ֿ�Ŀ¼: %repos_dir%
echo �ֿܲ���: %total%
echo.

for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a processed+=1
        set /a percent=processed*100/total
        set "progress="
        for /l %%p in (1,1,!percent!) do set "progress=!progress!��"
        for /l %%p in (!percent!,1,99) do set "progress=!progress! "
        
echo ����ɾ��: %%~nxi
rd /s /q "%%i"
if !errorlevel! equ 0 (
            set /a success+=1
            echo [�ɹ�] ɾ�����
        ) else (
            set /a failed+=1
            echo [ʧ��] ɾ��ʧ��
        )
echo ����: [!progress!] !percent!%%
echo.
    )
)

echo ɾ�����:
echo     ����: %total%
echo     �ɹ�: %success%
echo     ʧ��: %failed%
goto end

:end
endlocal
