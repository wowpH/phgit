@echo off
setlocal enabledelayedexpansion

@REM 批量克隆拉取脚本
@REM 作者：pH
@REM 时间：2025/07/07 21:15:00
@REM usage: phgit [命令] [参数]
@REM [命令] [参数]:
@REM    -c [文件]       克隆文件中的每个URL到当前目录下
@REM    clone [文件]    克隆文件中的每个URL到当前目录下
@REM    -p              拉取当前目录下的每个仓库
@REM    pull            拉取当前目录下的每个仓库
@REM    -b [分支名]     切换当前目录下所有仓库到指定的分支
@REM    branch [分支名] 切换当前目录下所有仓库到指定的分支
@REM    -h              查看帮助信息
@REM    help            查看帮助信息
@REM    -c -h           查看phgit -c命令的帮助信息，主要是[文件]格式
@REM                    [文件]内容示例：
@REM                    https://github.com/wowpH/demo1.git
@REM                    https://github.com/wowpH/demo2.git
@REM phgit命令示例：
@REM    phgit -c url.txt 
@REM    phgit -p

:: 初始化计数器
set /a total=0
set /a success=0
set /a failed=0

:: 参数处理
if "%1"=="-c" goto clone
if "%1"=="clone" goto clone
if "%1"=="-p" goto pull
if "%1"=="pull" goto pull
if "%1"=="-b" goto branch
if "%1"=="branch" goto branch
if "%1"=="-h" goto help
if "%1"=="help" goto help

:: 无参数或参数无效时显示帮助
goto help

:clone
:: 检查是否显示克隆命令帮助
if "%2"=="-h" goto clone_help

:: 检查文件参数是否提供
if "%2"=="" (
    echo 错误：缺少文件参数
    goto clone_help
)

:: 检查文件是否存在
if not exist "%2" (
    echo 错误：文件"%2"不存在
    goto end
)

:: 初始化进度计数器
set /a processed=0
set /a total=0

:: 先统计总URL数
for /f "usebackq delims=" %%i in ("%2") do (
    set "url=%%i"
    if not "!url!"=="" (
        set /a total+=1
    )
)

echo 开始批量克隆仓库...
echo 总仓库数: %total%
echo.

for /f "usebackq delims=" %%i in ("%2") do (
    set "url=%%i"
    if not "!url!"=="" (
        set /a processed+=1
        set /a percent=processed*100/total
        set "progress="
        for /l %%p in (1,1,!percent!) do set "progress=!progress!█"
        for /l %%p in (!percent!,1,99) do set "progress=!progress! "
        
        echo 正在克隆: !url!
        @REM 克隆到指定目录
        git clone "!url!" "./repos/%date:~0,4%%date:~5,2%%date:~8,2%/%%~nxi"
        if !errorlevel! equ 0 (
            set /a success+=1
            echo [成功] 克隆完成
        ) else (
            set /a failed+=1
            echo [失败] 克隆失败
        )
        echo 进度: [!progress!] !percent!%%
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
echo 用法: phgit %1 [选项] ^<文件^>
echo.
echo 选项:
echo    -h          显示此帮助信息
echo.
echo 参数:
echo    ^<文件^>      包含Git仓库URL列表的文本文件
echo.
echo 文件格式, 每行一个Git仓库URL, 例如:
echo    https://github.com/wowpH/demo1.git
echo    https://github.com/wowpH/demo2.git
echo.
echo 示例:
echo    phgit %1 url.txt
echo    phgit %1 -h
goto end

:pull
:: 初始化进度计数器
set /a processed=0
set /a total=0

:: 先统计总仓库数
for /d %%i in (*) do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo 开始批量拉取更新...
echo 总仓库数: %total%
echo.

for /d %%i in (*) do (
    if exist "%%i\.git" (
        set /a processed+=1
        set /a percent=processed*100/total
        set "progress="
        for /l %%p in (1,1,!percent!) do set "progress=!progress!█"
        for /l %%p in (!percent!,1,99) do set "progress=!progress! "
        
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
        cd ..
        echo 进度: [!progress!] !percent!%%
        echo.
    )
)

echo 拉取完成:
echo     总数: %total%
echo     成功: %success%
echo     失败: %failed%
goto end

:branch
:: 检查分支参数是否提供
if "%2"=="" (
    echo 错误：缺少分支名参数
    goto help
)

:: 初始化进度计数器
set /a processed=0
set /a total=0

:: 先统计总仓库数
for /d %%i in (*) do (
    if exist "%%i\.git" (
        set /a total+=1
    )
)

echo 开始批量切换分支到: %2
echo 总仓库数: %total%
echo.

for /d %%i in (*) do (
    if exist "%%i\.git" (
        set /a processed+=1
        echo 正在处理: %%i
        cd /d "%%i"
        git checkout "%2" 2>&1
        if !errorlevel! equ 0 (
            set /a success+=1
            echo [成功] 切换到分支 %2
        ) else (
            set /a failed+=1
            echo [失败] 切换失败
        )
        cd ..
        echo 进度: !processed!/%total%
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
echo 批量克隆拉取脚本 v1.0
echo.
echo 用法: phgit ^<命令^> [^<参数^>]
echo.
echo 命令列表:
echo    clone ^| -c ^<文件^>      批量克隆指定文件中的Git仓库URL
echo    pull ^| -p              批量拉取当前目录下的所有Git仓库
echo    branch ^| -b ^<分支名^>   批量切换当前目录下所有Git仓库到指定分支
echo    help ^| -h              显示此帮助信息
echo.
echo 选项:
echo    -h, --help             显示指定命令的帮助信息
echo.
echo 示例:
echo    phgit clone url.txt    克隆url.txt文件中列出的所有仓库
echo    phgit -p               拉取当前目录下所有仓库的更新
echo    phgit branch main      将所有仓库切换到main分支
echo    phgit -c -h            显示clone命令的帮助信息
goto end

:end
endlocal
