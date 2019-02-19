echo off
rem 环境设置 开始
CMD /E:ON /c
mode con cols=75 lines=3
color 87
chcp 936 >nul
title UTCNet-Go-Win

setlocal enabledelayedexpansion 
cd /d "%~dp0"
rem 环境设置 结束

rem 读取配置 开始
for /f "eol=[ delims=" %%a in (..\config.ini) do (
    for /f "tokens=1 delims=;" %%b in ("%%a") do (
        for /f "tokens=1,2 delims==" %%c in ("%%b") do (
            set key=%%c        
            set value=%%d
            set key=!key: =!
            set value=!value: =!
            set !key!=!value!

            if defined !key! (
              if "!key!" == "" (
                goto config_error
              )
            ) else (
              :config_error
              echo 配置文件有误/please cheak config.ini
              goto fermer
            )
        )
    ) 
)
rem 读取配置 结束

rem 请求管理员权限 开始
ver|findstr "[6,10]\.[0-9]\.[0-9][0-9]*" > nul && (goto Main)
ver|findstr "[3-5]\.[0-9]\.[0-9][0-9]*" > nul && (goto isBelowNT6)

:isBelowNT6
goto needadmin

:Main
cacls.exe "%SystemDrive%\System Volume Information" >nul 2>nul
if not %errorlevel%==0 (
  :needadmin
  echo 需要管理员权限/Need Admin permission
  goto fermer
)
rem 请求管理员权限 结束

rem 初始化 开始
mode con lines=%height%
set res_sig=0

echo.
echo ===========================================================================
echo                             初始化/initializing
echo ===========================================================================
echo.

echo 现在的网关/Gateway used：%gateway%
echo.
echo 网关列表/Gateway list：
for /f "tokens=15" %%i in ('ipconfig ^| find /i "默认网关"') do echo %%i
echo.
echo 是否正确/Correct?
choice
if %errorlevel% == 2 goto fermer
if %errorlevel% == 1 goto starter
goto fermer
rem 初始化 结束

rem 启动 开始
:starter
color 70
echo.
echo ===========================================================================
echo                               启动中/Starting
echo ===========================================================================
echo.

echo "......0%%"

taskkill /f /t /IM tun2socks.exe 1>nul 2>nul
start /min tun2socks.start.vbs 1>nul 2>nul
echo "......20%%"
choice /c v /t 3 /d v /n 1>nul 2>nul

taskkill /f /t /IM v2ray.exe 1>nul 2>nul
start /min v2ray.start.vbs
echo "......40%%"
choice /c v /t 3 /d v /n 1>nul 2>nul

:routesettap
route delete 0.0.0.0 10.0.0.1 1>nul 2>nul
route add 0.0.0.0 mask 0.0.0.0 10.0.0.1 metric 6 1>nul 2>nul

set routelist=
for /F "delims=" %%i in ('route print -4 ^| find "0.0.0.0" ^| find /i "10.0.0.1" ^| find /i "10.0.0.2"') do set routelist=%%i
if not defined routelist (
  echo 异常，是否重试？/Error,Retry?
  choice /t 2 /d y
  if !errorlevel! == 2 (
    echo 请确认Tap网卡无误/Please confirm that Tap is correct
    pause
    goto shutthisdown
  ) else (
    goto routesettap
  )
) 
echo "......60%%"

route delete 0.0.0.0 mask 0.0.0.0 %gateway% 1>nul 2>nul
echo "......80%%"

route delete %proxy% %gateway% 1>nul 2>nul
route add %proxy% %gateway% metric 5 1>nul 2>nul
echo "......100%%"

echo.
echo ===========================================================================
echo                                   完成/Done
echo ===========================================================================
echo.
rem 启动 结束

rem 选择 开始
:cho
color F0
choice /C SR /M "请求操作/Control：停止/Stop S，重启/Restart R"
if errorlevel 2 goto set_res
if errorlevel 1 goto shutthisdown
rem 选择 结束

rem 重启 开始
:set_res
set res_sig=1
goto shutthisdown
rem 重启 结束

rem 停止 开始

:shutthisdown

color 70

echo.
echo ===========================================================================
echo                                 操作中/Working
echo ===========================================================================
echo.

echo "......0%%"
taskkill /f /t /IM v2ray.exe 1>nul 2>nul
echo "......20%%"
taskkill /f /t /IM tun2socks.exe 1>nul 2>nul
echo "......40%%"

route add 0.0.0.0 mask 0.0.0.0 %gateway% metric 6 1>nul 2>nul
echo "......60%%"
route delete 0.0.0.0 mask 0.0.0.0 10.0.0.1 1>nul 2>nul
echo "......80%%"
route delete %proxy% %gateway% 1>nul 2>nul
echo "......100%%"

echo.
echo ===========================================================================
echo                                   完成/Done
echo ===========================================================================
echo.

if %res_sig%==1 (
  goto restart
) else (
  goto fermer
)
rem 停止 结束

:restart
echo 重启中/Restarting
start main.start.bat
endlocal
exit

:fermer
color 08
echo 任意键退出/Press any to exit
pause > nul
endlocal
exit