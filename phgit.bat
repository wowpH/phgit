@echo off
setlocal enabledelayedexpansion

set "VER=1.0.3"

:: 读取配置文件中的仓库目录, 默认为当前目录
set "repos_dir=."
if exist "phgit.ini" (
    for /f "tokens=2 delims==" %%d in ('findstr "^repos=" phgit.ini') do (
        set "repos_dir=%%d"
    )
)

@REM 初始化总计数变量 total 为 0，该变量用于统计需要处理的 Git 仓库数量
set /a total=0
@REM 初始化成功计数变量 success 为 0，该变量用于统计成功处理的 Git 仓库数量
set /a success=0
@REM 初始化失败计数变量 failed 为 0，该变量用于统计失败处理的 Git 仓库数量
set /a failed=0
@REM 初始化进度计数变量 processed 为 0，该变量用于统计当前处理的 Git 仓库数量
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
:: 无参数或参数无效时显示帮助
goto help

:: 进度条公共函数: 根据百分比生成进度条字符串
:: 参数: %1=当前百分比(0-100)
:: 输出: 全局变量 progress_bar
:create_progress_bar
    setlocal enabledelayedexpansion
    set "percent=%1"
    set "progress="
    for /l %%p in (1,1,!percent!) do set "progress=!progress!█"
    for /l %%p in (!percent!,1,99) do set "progress=!progress! "
    :: 将结果传递到全局变量
    endlocal & set "progress_bar=%progress%"
    goto :eof

:clone
:: 检查是否显示克隆命令帮助
if "%2"=="-h" goto clone_help
if "%2"=="" goto clone_help

:: 检查文件是否存在
if not exist "%2" (
    echo 错误: 文件"%2"不存在
    goto end
)

:: 先统计总URL数
for /f "usebackq delims=" %%i in ("%2") do (
    set "url=%%i"
    if not "!url!"=="" (
        set /a total+=1
    )
)

echo 开始批量克隆仓库...
echo 仓库目录: %repos_dir%
echo 总仓库数: %total%
echo.

for /f "usebackq delims=" %%i in ("%2") do (
    set "url=%%i"
    if not "!url!"=="" (
        set /a processed+=1
        set /a percent=processed*100/total
        call :create_progress_bar !percent!
        @REM set "progress="
        @REM for /l %%p in (1,1,!percent!) do set "progress=!progress!█"
        @REM for /l %%p in (!percent!,1,99) do set "progress=!progress! "
        
        echo 正在克隆: !url!
        @REM 克隆到指定目录
        set "repo_name=%%~nxi"
        set "repo_name=!repo_name:.git=!"
        git clone "!url!" "%repos_dir%\!repo_name!"
        if !errorlevel! equ 0 (
            set /a success+=1
            echo [成功] 克隆完成
        ) else (
            set /a failed+=1
            echo [失败] 克隆失败
        )
        echo 进度: [!progress_bar!] !percent!%%
        echo.
    )
)

echo 克隆完成:
echo     总数: %total%
echo     成功: %success%
echo     失败: %failed%
goto end

:clone_help
echo.
echo phgit %1       批量克隆Git仓库
echo.
echo 用法: 
echo    phgit %1 [选项] ^<参数^>
echo.
echo 选项:
echo    -h             显示此帮助信息
echo.
echo 参数:
echo    ^<参数^>         txt文件路径(相对路径或绝对路径), 文件每行一个Git仓库URL, 例如:
echo.
echo                   url.txt
echo                   https://github.com/wowpH/demo1.git
echo                   https://github.com/wowpH/demo2.git
echo.
echo                   E:\IdeaProjects\phgit\url.txt
echo                   https://github.com/wowpH/demo1.git
echo                   https://github.com/wowpH/demo2.git
echo.
echo 示例:
echo    phgit %1 url.txt
echo    phgit %1 -h
goto end

:pull
:: 先统计总仓库数
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo 开始批量拉取更新...
echo 仓库目录: %repos_dir%
echo 总仓库数: %total%
echo.

for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a processed+=1
        set /a percent=processed*100/total
        call :create_progress_bar !percent!
        
        echo 正在处理: %%i
        cd /d "%%i"
        git pull
        if !errorlevel! equ 0 (
            set /a success+=1
            echo [成功] 拉取完成
        ) else (
            set /a failed+=1
            echo [失败] 拉取失败
        )
        cd /d "%~dp0"
        echo 进度: [!progress_bar!] !percent!%%
        echo.
    )
)

echo 拉取完成:
echo     总数: %total%
echo     成功: %success%
echo     失败: %failed%
goto end

:switch
:: 检查分支参数是否提供
if "%2"=="-h" goto switch_help
if "%2"=="" goto switch_help

:: 先统计总仓库数
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo 开始批量切换分支到: %2
echo 仓库目录: %repos_dir%
echo 总仓库数: %total%
echo.

for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a processed+=1
        set /a percent=processed*100/total
        call :create_progress_bar !percent!
        
        echo 正在处理: %%i
        cd /d "%%i"
        git switch "%2" 2>&1
        if !errorlevel! equ 0 (
            set /a success+=1
            echo [成功] 切换到分支 %2
        ) else (
            set /a failed+=1
            echo [失败] 切换失败
        )
        cd /d "%~dp0"
        echo 进度: [!progress_bar!] !percent!%%
        echo.
    )
)

echo 分支切换完成:
echo     总数: %total%
echo     成功: %success%
echo     失败: %failed%
goto end

:help
echo.
echo 批量Git脚本 v%VER%

echo.
echo 用法:
echo    phgit [^<命令^>] [选项] [参数]
echo.
echo 命令:
echo    clone       批量克隆
echo    delete      批量删除仓库,仅删除Git仓库目录
echo    pull        批量拉取
echo    set         设置当前目录配置,未设置则默认当前目录
echo    switch      批量切换分支
echo.
echo 选项:
echo    -h          显示帮助信息
goto end

:set
:: 检查是否显示set命令帮助
if "%2"=="-h" goto set_help

:: 检查参数是否提供
if "%2"=="" (
    goto set_help
)

:: 创建配置文件
if not exist "phgit.ini" (
    echo [config] > phgit.ini
    echo ; phgit配置文件 >> phgit.ini
    echo ; 格式: key=value >> phgit.ini
)

:: 设置配置项
if "%3"=="" (
    echo 错误: 缺少value参数
    goto set_help
) else (
    :: 去除value前后的空格
    set "value=%3"
    for /f "tokens=*" %%a in ("!value!") do set "value=%%a"
    
    :: 先删除已有的key
    findstr /v "%2=" phgit.ini > phgit.tmp
    move /y phgit.tmp phgit.ini > nul
    
    :: 添加新的key=value
    echo %2=!value!>> phgit.ini
    echo [成功] 已设置 %2=!value!
)

goto end

:set_help
echo.
echo phgit set                      管理phgit配置
echo.
echo 用法:
echo    phgit set [选项] ^<key^> ^<value^>
echo.
echo 选项:
echo    -h                          显示此帮助信息
echo.
echo 参数:
echo    ^<key^>                       配置项名称
echo    ^<value^>                     配置项值
echo.
echo key:
echo    repos                       仓库目录
echo.
echo 示例:
echo    phgit set repos .\repos     设置仓库目录为当前目录的repos子目录
echo    phgit set -h                显示set命令的帮助信息
goto end

:switch_help
echo.
echo phgit switch       批量切换分支
echo.
echo 用法: phgit switch [选项] ^<分支名^>
echo.
echo 选项:
echo    -h              显示此帮助信息
echo.
echo 参数:
echo    ^<分支名^>        要切换到的分支名称
echo.
echo 示例:
echo    phgit switch main      将所有仓库切换到main分支
echo    phgit switch -h        显示switch命令的帮助信息
goto end

:delete_help
echo.
echo phgit delete       批量删除仓库
echo.
echo 用法: phgit delete [选项]
echo.
echo 选项:
echo    -h              显示此帮助信息
echo.
echo 说明:
echo    此命令将删除配置文件中repos目录下的所有Git仓库
echo    操作前会提示确认，删除后无法恢复
echo.
echo 示例:
echo    phgit delete           批量删除仓库
echo    phgit delete -h        显示delete命令的帮助信息
goto end

:delete
:: 检查是否显示删除命令帮助
if "%2"=="-h" goto delete_help

:: 检查仓库目录是否存在
if not exist "%repos_dir%" (
    echo 错误: 仓库目录"%repos_dir%"不存在
    goto end
)

:: 确认删除操作
set /p confirm=确定要删除"%repos_dir%"下的所有仓库吗？[y/N] 
if /i not "%confirm%"=="y" (
    echo 已取消删除操作
    goto end
)

:: 先统计总仓库数
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo 开始批量删除仓库...
echo 仓库目录: %repos_dir%
echo 总仓库数: %total%
echo.

for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a processed+=1
        set /a percent=processed*100/total
        call :create_progress_bar !percent!
        
echo 正在删除: %%~nxi
rd /s /q "%%i"
if !errorlevel! equ 0 (
            set /a success+=1
            echo [成功] 删除完成
        ) else (
            set /a failed+=1
            echo [失败] 删除失败
        )
echo 进度: [!progress_bar!] !percent!%%
echo.
    )
)

echo 删除完成:
echo     总数: %total%
echo     成功: %success%
echo     失败: %failed%
goto end

:end
endlocal
