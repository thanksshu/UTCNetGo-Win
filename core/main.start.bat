echo off
color 87
mode con cols=75 lines=1
chcp 936
setlocal enabledelayedexpansion 
cd /d "%~dp0"

rem 读取配置 开始
for /f "delims= eol=[" %%a in (..\config.ini) do (
    for /f "delims=; tokens=1" %%b in ("%%a") do (
        for /f "delims== tokens=1,2" %%c in ("%%b") do (
            set key=%%c        
            set value=%%d
            set key=!key: =!
            set value=!value: =!
            set !key!=!value!
        )
    ) 
)
rem 读取配置 结束

rem 设置界面 开始
mode con lines=%height%
title UTCNet-Go-Win
rem 设置界面 结束

rem 请求管理员权限 开始
ver|findstr "[6,10]\.[0-9]\.[0-9][0-9]*" > nul && (goto Main)
ver|findstr "[3-5]\.[0-9]\.[0-9][0-9]*" > nul && (goto isBelowNT6)

:isBelowNT6
echo 需要管理员权限/Need Admin permission
goto fermer

:Main
cacls.exe "%SystemDrive%\System Volume Information" >nul 2>nul
if %errorlevel%==0 goto Admin
"admin.get.vbs" /f
endlocal
exit

:Admin
rem 请求管理员权限 结束

rem 初始化 开始
echo]
echo ===========================================================================
echo                             初始化/initializing
echo ===========================================================================
echo]
set res_sig=0
echo 现在的网关/Gateway used：%gateway%
echo.
echo 是否正确？（等待5秒）/ Correct?(Wait you for 5s)
choice /T 5 /D Y
if %errorlevel% == 2 goto gwlist
if %errorlevel% == 1 goto starter
:gwlist
echo 网关列表/Gateway list：
for /f "tokens=15" %%i in ('ipconfig ^| find /i "默认网关"') do echo %%i
echo 选择网关并填入config.ini / Chose the gateway, fill it in the config.ini
goto fermer
rem 初始化 结束

rem 启动 开始
:starter
color 70
echo]
echo ===========================================================================
echo                               启动中/Starting
echo ===========================================================================
echo]


echo "......0%%"
start /min tun2socks.start.vbs
echo "......20%%"

choice /t 2 /d y /n >nul
echo "......30%%"
choice /t 2 /d y /n >nul

route add 0.0.0.0 mask 0.0.0.0 10.0.0.1 metric 6
echo "......40%%"
route add %proxy% %gateway% metric 5
echo "......60%%"
route delete 0.0.0.0 mask 0.0.0.0 %gateway% metric 6
echo "......80%%"

choice /t 1 /d y /n >nul 

start /min v2ray.start.vbs
choice /t 2 /d y /n >nul
echo "......100%%"

choice /t 1 /d y /n >nul

echo]
echo ===========================================================================
echo                                   完成/Done
echo ===========================================================================
echo]
rem 启动 结束

rem 选择 开始
:cho
color F0
choice /C SR /M "请求操作/Control：停止/Stop S，重启/Restart R"
rem 应先判断数值最高的错误码
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

echo]
echo ===========================================================================
echo                                 操作中/Working
echo ===========================================================================
echo]

echo "......0%%"
taskkill /f /t /IM v2ray.exe
echo "......20%%"
taskkill /f /t /IM tun2socks.exe
echo "......40%%"

route add 0.0.0.0 mask 0.0.0.0 %gateway% metric 6
echo "......60%%"
route delete 0.0.0.0 mask 0.0.0.0 10.0.0.1 metric 6
echo "......80%%"
route delete %proxy% %gateway% metric 5
echo "......100%%"

echo]
echo ===========================================================================
echo                                   完成/Done
echo ===========================================================================
echo]

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