echo off
color 87
mode con cols=75 lines=1
chcp 936
setlocal enabledelayedexpansion 
cd /d "%~dp0"

rem ��ȡ���� ��ʼ
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
rem ��ȡ���� ����

rem ���ý��� ��ʼ
mode con lines=%height%
title UTCNet-Go-Win
rem ���ý��� ����

rem �������ԱȨ�� ��ʼ
ver|findstr "[6,10]\.[0-9]\.[0-9][0-9]*" > nul && (goto Main)
ver|findstr "[3-5]\.[0-9]\.[0-9][0-9]*" > nul && (goto isBelowNT6)

:isBelowNT6
echo ��Ҫ����ԱȨ��/Need Admin permission
goto fermer

:Main
cacls.exe "%SystemDrive%\System Volume Information" >nul 2>nul
if %errorlevel%==0 goto Admin
"admin.get.vbs" /f
endlocal
exit

:Admin
rem �������ԱȨ�� ����

rem ��ʼ�� ��ʼ
echo]
echo ===========================================================================
echo                             ��ʼ��/initializing
echo ===========================================================================
echo]
set res_sig=0
echo ���ڵ�����/Gateway used��%gateway%
echo.
echo �Ƿ���ȷ�����ȴ�5�룩/ Correct?(Wait you for 5s)
choice /T 5 /D Y
if %errorlevel% == 2 goto gwlist
if %errorlevel% == 1 goto starter
:gwlist
echo �����б�/Gateway list��
for /f "tokens=15" %%i in ('ipconfig ^| find /i "Ĭ������"') do echo %%i
echo ѡ�����ز�����config.ini / Chose the gateway, fill it in the config.ini
goto fermer
rem ��ʼ�� ����

rem ���� ��ʼ
:starter
color 70
echo]
echo ===========================================================================
echo                               ������/Starting
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
echo                                   ���/Done
echo ===========================================================================
echo]
rem ���� ����

rem ѡ�� ��ʼ
:cho
color F0
choice /C SR /M "�������/Control��ֹͣ/Stop S������/Restart R"
rem Ӧ���ж���ֵ��ߵĴ�����
if errorlevel 2 goto set_res
if errorlevel 1 goto shutthisdown
rem ѡ�� ����

rem ���� ��ʼ
:set_res
set res_sig=1
goto shutthisdown
rem ���� ����

rem ֹͣ ��ʼ
:shutthisdown

color 70

echo]
echo ===========================================================================
echo                                 ������/Working
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
echo                                   ���/Done
echo ===========================================================================
echo]

if %res_sig%==1 (
  goto restart
) else (
  goto fermer
)
rem ֹͣ ����

:restart
echo ������/Restarting
start main.start.bat
endlocal
exit

:fermer
color 08
echo ������˳�/Press any to exit
pause > nul
endlocal
exit