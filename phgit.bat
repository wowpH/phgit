@echo off
setlocal enabledelayedexpansion

@REM 版本号
set "VER=1.1.0"
@REM 命令列表
set "COMMANDS=-h -i -v clone delete pull set switch"

@REM Git仓库数量: 默认为 0
set /a git_repos_count=0
@REM 成功数量: 默认为 0
set /a success=0
@REM 失败数量: 默认为 0
set /a failed=0
@REM 进度数量: 默认为 0
set /a processed=0
@REM 进度条字符串: 默认为空
set "progress_bar="
@REM 进度条长度: 默认为 50
set /a progress_bar_len=50
@REM 安装目录
set "install_dir=%~dp0"
@REM 工作目录
set "work_dir=%cd%"
@REM 配置文件目录: 默认为安装目录
set "config_dir=%install_dir%"
@REM 配置文件路径: 默认为配置文件目录下的 phgit.ini
set "config_file=%config_dir%phgit.ini"
@REM 仓库目录: 默认为工作目录
set "repos_dir=%work_dir%"

@REM 读取配置文件中的仓库目录, 默认为工作目录
if exist "%config_file%" (
    for /f "tokens=2 delims==" %%d in ('findstr "^repos=" "%config_file%"') do (
        if "%%d"=="%%~fd" (
            @REM 配置文件中的仓库目录是绝对路径
            set "repos_dir=%%d"
        ) else (
            @REM 配置文件中的仓库目录是相对路径, 相对于工作目录
            set "repos_dir=%work_dir%\%%d"
        )
        @REM 转换路径为绝对路径
        for %%p in ("!repos_dir!") do set "repos_dir=%%~fp"
        @REM 移除路径末尾的 "\"
        if "!repos_dir:~-1!"=="\" set "repos_dir=!repos_dir:~0,-1!"
    )
)

@REM 统计目录中的仓库数量
call :count_repos

@REM 解析 phgit 命令参数
for %%i in (%COMMANDS%) do (
    @REM 遍历命令列表
    if /i "%1"=="%%i" (
        if "%%i"=="-h" (
            @REM 显示帮助信息
            goto help
        ) else if "%%i"=="-i" (
            @REM 显示仓库信息
            goto info
        ) else if "%%i"=="-v" (
            @REM 显示版本信息
            goto version
        ) else (
            @REM 对应命令
            goto %%i
        )
    )
)
@REM 无参数或参数无效时显示帮助
goto help

@REM 进度条公共函数: 根据百分比生成进度条字符串
@REM    输出: 全局变量 progress_bar
:create_progress_bar
    setlocal enabledelayedexpansion
    set "progress_char=■"
    set "empty_char=□"
    @REM 进度百分比值, 0-100
    set /a percent=processed*100/git_repos_count
    @REM 已完成进度条长度
    set /a completed_len=processed*progress_bar_len/git_repos_count
    @REM 进度条字符串
    set "progress="
    for /l %%p in (1,1,!completed_len!) do set "progress=!progress!%progress_char%"
    @REM 未完成进度条开始位置
    set /a unfinished_start=completed_len+1
    for /l %%p in (!unfinished_start!,1,!progress_bar_len!) do set "progress=!progress!%empty_char%"
    @REM 将结果传递到全局变量
    endlocal & set "progress_bar=进度: %progress% %percent%%%"
    goto :eof

@REM 统计仓库数量
:count_repos
    @REM 支持传入仓库文件
    if "%1"=="" (
        for /d %%i in ("%repos_dir%\*") do (
            if exist "%%i\.git" (
                set /a git_repos_count+=1
            )
        )
    ) else (
        echo 统计传入文件中的仓库数量
        set "file=%~f1"
        if not exist "!file!" (
            echo 错误: 文件"%1"不存在
            goto end
        )
        for /f "usebackq delims=" %%i in ("!file!") do (
            set "url=%%i"
            if not "!url!"=="" (
                set /a git_repos_count+=1
            )
        )
    )
    goto :eof

@REM 显示操作提示信息
:show_oper_info
    echo.
    echo %~1
    echo     目录: %repos_dir%
    echo     总数: %git_repos_count%
    echo.
    goto :eof

@REM 显示操作完成信息
:show_oper_complete_info
    echo %~1
    echo     目录: %repos_dir%
    echo     总数: %git_repos_count%
    echo     成功: %success%
    echo     失败: %failed%
    goto :eof

@REM 输出操作结果
:output_oper_result
    if !errorlevel! equ 0 (
        set /a success+=1
        echo [成功] %~1
    ) else (
        set /a failed+=1
        echo [失败] %~2
    )
    goto :eof

@REM 显示clone命令帮助信息
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

@REM 批量克隆仓库
:clone
if "%2"=="-h" goto clone_help
if "%2"=="" goto clone_help
@REM 检查文件是否存在
set "file=%~f2"
@REM 统计传入文件中的URL数量
call :count_repos "!file!"
call :show_oper_info "开始批量克隆仓库..."
for /f "usebackq delims=" %%i in ("!file!") do (
    set "url=%%i"
    if not "!url!"=="" (
        set /a processed+=1
        set /a percent=processed*progress_bar_len/git_repos_count
        call :create_progress_bar
        echo 正在克隆: !url!
        @REM 克隆到指定目录
        set "repo_name=%%~nxi"
        set "repo_name=!repo_name:.git=!"
        git clone "!url!" "%repos_dir%\!repo_name!"
        call :output_oper_result "克隆完成" "克隆失败"
        echo !progress_bar!
        echo.
    )
)
call :show_oper_complete_info "批量克隆完成"
goto end

@REM 显示delete命令帮助信息
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
call :show_oper_info "开始批量删除仓库..."
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a processed+=1
        call :create_progress_bar
        
        echo 正在删除: %%~nxi
        rd /s /q "%%i"
        call :output_oper_result "删除完成" "删除失败"
        echo !progress_bar!
        echo.
    )
)
call :show_oper_complete_info "删除完成"
goto end

:pull
call :show_oper_info "开始批量拉取更新..."
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a processed+=1
        call :create_progress_bar
        echo 正在处理: %%i
        cd /d "%%i"
        git pull
        call :output_oper_result "拉取完成" "拉取失败"
        cd /d "%~dp0"
        echo !progress_bar!
        echo.
    )
)
call :show_oper_complete_info "批量拉取完成"
goto end

@REM 显示set命令帮助信息
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

:set
:: 检查是否显示set命令帮助
if "%2"=="-h" goto set_help
if "%2"=="" goto set_help
:: 创建配置文件
if not exist "%config_file%" (
    echo [config] > "%config_file%"
    echo ; phgit配置文件 >> "%config_file%"
    echo ; 格式: key=value >> "%config_file%"
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
    findstr /v "%2=" "%config_file%" > "%config_file%.tmp"
    move /y "%config_file%.tmp" "%config_file%" > nul
    :: 添加新的key=value
    echo %2=!value!>> "%config_file%"
    echo [成功] 已设置 %2=!value!
)
goto end

@REM 显示switch命令帮助信息
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

:switch
:: 检查分支参数是否提供
if "%2"=="-h" goto switch_help
if "%2"=="" goto switch_help
call :show_oper_info "开始批量切换分支到: %2"
for /d %%i in ("%repos_dir%\*") do (
    if exist "%%i\.git" (
        set /a processed+=1
        call :create_progress_bar
        echo 正在处理: %%i
        cd /d "%%i"
        git switch "%2" 2>&1
        call :output_oper_result "切换完成" "切换失败"
        cd /d "%~dp0"
        echo !progress_bar!
        echo.
    )
)
call :show_oper_complete_info "分支切换完成"
goto end

@REM 显示帮助信息
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
echo    -i          显示详细信息
goto end

@REM 添加info标签显示信息
:info
echo.
echo phgit版本: %VER%
echo  当前目录: %work_dir%
echo  仓库目录: %repos_dir%
echo  仓库总数: %git_repos_count%
echo  安装目录: %install_dir%
echo  配置文件: %config_file%
goto end

:end
endlocal
