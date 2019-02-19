echo off
rem �������� ��ʼ
CMD /E:ON /c
mode con cols=75 lines=3
color 87
chcp 936 >nul
title UTCNet-Go-Win

setlocal enabledelayedexpansion 
cd /d "%~dp0"
rem �������� ����

rem ��ȡ���� ��ʼ
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
              echo �����ļ�����/please cheak config.ini
              goto fermer
            )
        )
    ) 
)
rem ��ȡ���� ����

rem �������ԱȨ�� ��ʼ
ver|findstr "[6,10]\.[0-9]\.[0-9][0-9]*" > nul && (goto Main)
ver|findstr "[3-5]\.[0-9]\.[0-9][0-9]*" > nul && (goto isBelowNT6)

:isBelowNT6
goto needadmin

:Main
cacls.exe "%SystemDrive%\System Volume Information" >nul 2>nul
if not %errorlevel%==0 (
  :needadmin
  echo ��Ҫ����ԱȨ��/Need Admin permission
  goto fermer
)
rem �������ԱȨ�� ����

rem ��ʼ�� ��ʼ
mode con lines=%height%
set res_sig=0

echo.
echo ===========================================================================
echo                             ��ʼ��/initializing
echo ===========================================================================
echo.

echo ���ڵ�����/Gateway used��%gateway%
echo.
echo �����б�/Gateway list��
for /f "tokens=15" %%i in ('ipconfig ^| find /i "Ĭ������"') do echo %%i
echo.
echo �Ƿ���ȷ/Correct?
choice
if %errorlevel% == 2 goto fermer
if %errorlevel% == 1 goto starter
goto fermer
rem ��ʼ�� ����

rem ���� ��ʼ
:starter
color 70
echo.
echo ===========================================================================
echo                               ������/Starting
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
  echo �쳣���Ƿ����ԣ�/Error,Retry?
  choice /t 2 /d y
  if !errorlevel! == 2 (
    echo ��ȷ��Tap��������/Please confirm that Tap is correct
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
echo                                   ���/Done
echo ===========================================================================
echo.
rem ���� ����

rem ѡ�� ��ʼ
:cho
color F0
choice /C SR /M "�������/Control��ֹͣ/Stop S������/Restart R"
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

echo.
echo ===========================================================================
echo                                 ������/Working
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
echo                                   ���/Done
echo ===========================================================================
echo.

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