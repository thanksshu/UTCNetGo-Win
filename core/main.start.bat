@echo off

rem ���ý��� ��ʼ
color 70
mode con cols=75 lines=40
title Tun2V2ray
rem ���ý��� ����

rem �������ԱȨ�� ��ʼ
ver|findstr "[6,10]\.[0-9]\.[0-9][0-9]*" > nul && (goto Main)
ver|findstr "[3-5]\.[0-9]\.[0-9][0-9]*" > nul && (goto isBelowNT6)

:isBelowNT6
echo �ڵͼ�Windows��������Ҫ�ֶ���ȡ����ԱȨ�ޣ�
goto fermer

:Main
cd /d "%~dp0"
cacls.exe "%SystemDrive%\System Volume Information" >nul 2>nul
if %errorlevel%==0 goto Admin
"admin.get.vbs" /f
exit

:Admin
rem �������ԱȨ�� ����

rem ѡ����� ��ʼ
echo]
echo ************************ע�⣡���л���ӦΪ ������ ��***********************
echo]




echo]
echo ===========================================================================
echo                                  ѡ������
echo ===========================================================================
echo]

cd /d "%~dp0"

set /P gateway=<gateway
echo �趨���أ�%gateway%
choice /C YNF /M "�Ƿ�ʹ�ô����أ���F�رգ�"
if errorlevel 3 goto fermer
if errorlevel 2 goto gwchoisir
if errorlevel 1 goto main
:gwchoisir
echo]
echo �����б�
for /f "tokens=15" %%i in ('ipconfig /all ^| find /i "Ĭ������"') do echo %%i
echo]
set /p gateway=�������أ�
echo]
echo %gateway% >gateway
goto main

:main

echo ��ѡ��
set /P proxy=<proxy

set res_sig=0
rem ѡ����� ����

rem ���� ��ʼ
echo]
echo ===========================================================================
echo                                    ������
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
echo                                     ���
echo ===========================================================================
echo]
rem ���� ����

rem ѡ�� ��ʼ
:cho
choice /C FAR /M "���������ֹͣ F���ȴ� A������ R"
rem Ӧ���ж���ֵ��ߵĴ�����
if errorlevel 3 goto setres
if errorlevel 2 goto cho
if errorlevel 1 goto shutthisdown
rem ѡ�� ����

rem ���� ��ʼ
:setres
set res_sig=1
goto shutthisdown
rem ���� ����

rem ֹͣ ��ʼ
:shutthisdown

echo]
echo ===========================================================================
echo                                    ������
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
echo                                     ���
echo ===========================================================================
echo]

if %res_sig%==1 (
  goto restart
) else (
  goto fermer
)
rem ֹͣ ����

:restart
echo ������
start main.start.bat
exit

:fermer
echo ������˳�
pause > nul
exit