@echo off
setlocal enabledelayedexpansion

@REM �汾��
set "VER=1.2.0"
@REM �����б�
set "COMMANDS=-h -i -v clone delete pull set switch"

@REM Git�ֿ�����: Ĭ��Ϊ 0
set /a git_repos_count=0
@REM �ɹ�����: Ĭ��Ϊ 0
set /a success=0
@REM ʧ������: Ĭ��Ϊ 0
set /a failed=0
@REM ��������: Ĭ��Ϊ 0
set /a processed=0
@REM �������ַ���: Ĭ��Ϊ��
set "progress_bar="
@REM ����������: Ĭ��Ϊ 50
set /a progress_bar_len=50
@REM ��װĿ¼
set "install_dir=%~dp0"
@REM ����Ŀ¼
set "work_dir=%cd%"
@REM �����ļ�Ŀ¼: Ĭ��Ϊ��װĿ¼
set "config_dir=%install_dir%"
@REM �����ļ�·��: Ĭ��Ϊ�����ļ�Ŀ¼�µ� phgit.ini
set "config_file=%config_dir%phgit.ini"
@REM �ֿ�Ŀ¼: Ĭ��Ϊ����Ŀ¼
set "repos_dir=%work_dir%"

@REM ��ȡ�����ļ��еĲֿ�Ŀ¼, Ĭ��Ϊ����Ŀ¼
if exist "%config_file%" (
    for /f "tokens=2 delims==" %%d in ('findstr "^repos=" "%config_file%"') do (
        if "%%d"=="%%~fd" (
            @REM �����ļ��еĲֿ�Ŀ¼�Ǿ���·��
            set "repos_dir=%%d"
        ) else (
            @REM �����ļ��еĲֿ�Ŀ¼�����·��, ����ڹ���Ŀ¼
            set "repos_dir=%work_dir%\%%d"
        )
        @REM ת��·��Ϊ����·��
        for %%p in ("!repos_dir!") do set "repos_dir=%%~fp"
        @REM �Ƴ�·��ĩβ�� "\"
        if "!repos_dir:~-1!"=="\" set "repos_dir=!repos_dir:~0,-1!"
    )
)

@REM ͳ��Ŀ¼�еĲֿ�����
call :count_repos

@REM ���� phgit �������
for %%i in (%COMMANDS%) do (
    @REM ���������б�
    if /i "%1"=="%%i" (
        if "%%i"=="-h" (
            @REM ��ʾ������Ϣ
            goto help
        ) else if "%%i"=="-i" (
            @REM ��ʾ�ֿ���Ϣ
            goto info
        ) else if "%%i"=="-v" (
            @REM ��ʾ�汾��Ϣ
            goto version
        ) else (
            @REM ��Ӧ����
            goto %%i
        )
    )
)
@REM �޲����������Чʱ��ʾ����
goto help

@REM ���������
:output_progress_bar
    call :create_progress_bar
    echo %progress_bar%
    echo.
    goto :eof

@REM ��������������: ���ݰٷֱ����ɽ������ַ���
@REM    ���: ȫ�ֱ��� progress_bar
:create_progress_bar
    setlocal enabledelayedexpansion
    set "progress_char=��"
    set "empty_char=��"
    @REM ���Ȱٷֱ�ֵ, 0-100
    set /a percent=processed*100/git_repos_count
    @REM ����ɽ���������
    set /a completed_len=processed*progress_bar_len/git_repos_count
    @REM �������ַ���
    set "progress="
    for /l %%p in (1,1,!completed_len!) do set "progress=!progress!%progress_char%"
    @REM δ��ɽ�������ʼλ��
    set /a unfinished_start=completed_len+1
    for /l %%p in (!unfinished_start!,1,!progress_bar_len!) do set "progress=!progress!%empty_char%"
    @REM ��������ݵ�ȫ�ֱ���
    endlocal & set "progress_bar=����: %progress% %percent%%%"
    goto :eof

@REM ͳ�Ʋֿ�����
:count_repos
    if "%1"=="" (
        @REM ͳ�Ʋֿ�Ŀ¼�еĲֿ�����
        for /d %%i in ("%repos_dir%\*") do (
            @REM �����ֿ�Ŀ¼����Ŀ¼
            if exist "%%i\.git" (
                @REM Ŀ¼��Git�ֿ�, ������ 1
                set /a git_repos_count+=1
            )
        )
    ) else (
        @REM ͳ�ƴ����ļ��еĲֿ�����
        set "file=%~f1"
        if not exist "!file!" (
            echo ����: �ļ�"%1"������
            goto end
        )
        @REM �����ļ��е�URL
        for /f "usebackq delims=" %%i in ("!file!") do (
            set "url=%%i"
            if not "!url!"=="" (
                @REM ͳ��URL����
                set /a git_repos_count+=1
            )
        )
    )
    goto :eof

@REM ��ʾ������ʾ��Ϣ
:show_oper_info
    echo.
    echo %~1
    echo �ֿ�Ŀ¼: %repos_dir%
    echo �ֿ�����: %git_repos_count%
    echo.
    goto :eof

@REM ��ʾ���������Ϣ
:show_oper_complete_info
    echo %~1
    echo �ֿ�Ŀ¼: %repos_dir%
    echo �ֿ�����: %git_repos_count%
    echo     �ɹ�: %success%
    echo     ʧ��: %failed%
    goto :eof

@REM ����������
:output_oper_result
    if !errorlevel! equ 0 (
        set /a success+=1
        echo [�ɹ�] %~1
    ) else (
        set /a failed+=1
        echo [ʧ��] %~2
    )
    goto :eof

@REM ��ʾclone���������Ϣ
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

@REM ������¡�ֿ�
:clone
if "%2"=="-h" goto clone_help
if "%2"=="" goto clone_help
set "file=%~f2"
@REM ͳ�ƴ����ļ��е�URL����
call :count_repos "!file!"
call :show_oper_info "��ʼ������¡�ֿ�..."
for /f "usebackq delims=" %%i in ("!file!") do (
    set "url=%%i"
    if not "!url!"=="" (
        echo ���ڿ�¡: !url!
        @REM ��¡��ָ��Ŀ¼
        set "repo_name=%%~nxi"
        set "repo_name=!repo_name:.git=!"
        git clone "!url!" "%repos_dir%\!repo_name!"
        call :output_oper_result "��¡���" "��¡ʧ��"
        set /a processed+=1
        call :output_progress_bar
    )
)
call :show_oper_complete_info "������¡���"
goto end

@REM ��ʾdelete���������Ϣ
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
if "%2"=="-h" goto delete_help
if not exist "%repos_dir%" (
    echo ����: �ֿ�Ŀ¼"%repos_dir%"������
    goto end
)
@REM ȷ��ɾ������
set /p confirm=ȷ��Ҫɾ��"%repos_dir%"�µ����вֿ���[y/n] 
if /i not "%confirm%"=="y" (
    echo ��ȡ��ɾ������
    goto end
)
call :show_oper_info "��ʼ����ɾ���ֿ�..."
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        echo ����ɾ��: %%~nxi
        rd /s /q "%%i"
        if exist "%%i" (
            echo [ʧ��] ɾ��ʧ��
            set /a failed+=1
        ) else (
            echo [�ɹ�] ɾ���ɹ�
            set /a success+=1
        )
        set /a processed+=1
        call :output_progress_bar
    )
)
call :show_oper_complete_info "ɾ�����"
goto end

:pull
call :show_oper_info "��ʼ������ȡ����..."
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        echo ������ȡ: %%i
        cd /d "%%i"
        git pull
        if !errorlevel! neq 0 (
            echo ��⵽�����޸ģ����ڴ���...
            git stash save "phgit pull stash"
            git pull
        )
        call :output_oper_result "��ȡ���" "��ȡʧ��"
        set /a processed+=1
        call :output_progress_bar
    )
)
call :show_oper_complete_info "������ȡ���"
goto end

@REM ��ʾset���������Ϣ
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

:set
:: ����Ƿ���ʾset�������
if "%2"=="-h" goto set_help
if "%2"=="" goto set_help
:: ���������ļ�
if not exist "%config_file%" (
    echo [config] > "%config_file%"
    echo ; phgit�����ļ� >> "%config_file%"
    echo ; ��ʽ: key=value >> "%config_file%"
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
    findstr /v "%2=" "%config_file%" > "%config_file%.tmp"
    move /y "%config_file%.tmp" "%config_file%" > nul
    :: ����µ�key=value
    echo %2=!value!>> "%config_file%"
    echo [�ɹ�] ������ %2=!value!
)
goto end

@REM ��ʾswitch���������Ϣ
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

:switch
:: ����֧�����Ƿ��ṩ
if "%2"=="-h" goto switch_help
if "%2"=="" goto switch_help
call :show_oper_info "��ʼ�����л���֧��: %2"
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        echo �����л�: %%i
        cd /d "%%i"
        @REM ����֧�Ƿ����
        git show-ref --verify --quiet refs/heads/%2
        if !errorlevel! neq 0 (
            echo ��֧ %2 ������
        ) else (
            @REM ��鱾���Ƿ�����޸�
            git diff --quiet --exit-code
            if !errorlevel! neq 0 (
                echo ��⵽�����޸ģ����ڴ���...
                git stash save "phgit switch stash"
                if !errorlevel! neq 0 (
                    echo ����ʧ�ܣ��޷��л���֧
                ) else (
                    @REM ���سɹ����л���֧
                    git switch "%2"
                )
            ) else (
                @REM �������޸ģ�ֱ���л�
                git switch "%2"
            )
        )
        call :output_oper_result "�л����" "�л�ʧ��"
        set /a processed+=1
        call :output_progress_bar
    )
)
call :show_oper_complete_info "��֧�л����"
goto end

@REM ��ʾ������Ϣ
:help
echo.
echo ����Git�ű� v%VER%
echo.
echo �÷�:
echo    phgit [����] [ѡ��] [����]
echo.
echo ����:
echo    clone       ������¡�ֿ�
echo    delete      ����ɾ���ֿ�(��GitĿ¼)
echo    pull        ������ȡ����
echo    set         ����phgit����
echo    switch      �����л���֧
echo.
echo ѡ��:
echo    -h          ��ʾ������Ϣ
echo    -i          ��ʾ��ϸ��Ϣ
echo    -v          ��ʾ�汾��Ϣ
goto end

@REM ���info��ǩ��ʾ��Ϣ
:info
echo.
echo  ����Ŀ¼: %work_dir%
echo  �ֿ�Ŀ¼: %repos_dir%
echo  ��װĿ¼: %install_dir%
@REM �����ļ�����ʱ��ʾ�����ļ�·��
if exist "%config_file%" (
    echo  �����ļ�: %config_file%
)
echo  �ֿ�����: %git_repos_count%
goto end

@REM ����汾��Ϣ
:version
echo.
echo ��Ŀ����: phgit
echo   �汾��: %VER%
echo     ����: pH
echo ��Ŀ��ַ: https://github.com/wowpH/phgit.git
goto end

:end
endlocal
