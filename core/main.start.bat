@echo off

rem 设置界面 开始
color 70
mode con cols=75 lines=40
title Tun2V2ray
rem 设置界面 结束

rem 请求管理员权限 开始
ver|findstr "[6,10]\.[0-9]\.[0-9][0-9]*" > nul && (goto Main)
ver|findstr "[3-5]\.[0-9]\.[0-9][0-9]*" > nul && (goto isBelowNT6)

:isBelowNT6
echo 在低级Windows下运行需要手动获取管理员权限！
goto fermer

:Main
cd /d "%~dp0"
cacls.exe "%SystemDrive%\System Volume Information" >nul 2>nul
if %errorlevel%==0 goto Admin
"admin.get.vbs" /f
exit

:Admin
rem 请求管理员权限 结束

rem 选择变量 开始
echo]
echo ************************注意！运行环境应为 ！中文 ！***********************
echo]




echo]
echo ===========================================================================
echo                                  选择网关
echo ===========================================================================
echo]

cd /d "%~dp0"

set /P gateway=<gateway
echo 设定网关：%gateway%
choice /C YNF /M "是否使用此网关？（F关闭）"
if errorlevel 3 goto fermer
if errorlevel 2 goto gwchoisir
if errorlevel 1 goto main
:gwchoisir
echo]
echo 网关列表：
for /f "tokens=15" %%i in ('ipconfig /all ^| find /i "默认网关"') do echo %%i
echo]
set /p gateway=输入网关：
echo]
echo %gateway% >gateway
goto main

:main

echo 已选择
set /P proxy=<proxy

set res_sig=0
rem 选择变量 结束

rem 启动 开始
echo]
echo ===========================================================================
echo                                    启动中
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
echo                                     完成
echo ===========================================================================
echo]
rem 启动 结束

rem 选择 开始
:cho
choice /C FAR /M "请求操作：停止 F，等待 A，重启 R"
rem 应先判断数值最高的错误码
if errorlevel 3 goto setres
if errorlevel 2 goto cho
if errorlevel 1 goto shutthisdown
rem 选择 结束

rem 重启 开始
:setres
set res_sig=1
goto shutthisdown
rem 重启 结束

rem 停止 开始
:shutthisdown

echo]
echo ===========================================================================
echo                                    操作中
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
echo                                     完成
echo ===========================================================================
echo]

if %res_sig%==1 (
  goto restart
) else (
  goto fermer
)
rem 停止 结束

:restart
echo 重启中
start main.start.bat
exit

:fermer
echo 任意键退出
pause > nul
exit