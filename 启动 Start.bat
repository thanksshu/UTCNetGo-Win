echo off
rem �������� ����
CMD /E:ON /c
mode con cols=75 lines=3
color 87
chcp 936 >nul
title UTCNet-Go-Win

setlocal enabledelayedexpansion 
cd /d "%~dp0"
rem �������� ����
rem ���� ��ʼ
"core\admin.get.vbs" /f
rem ���� ����
exit
endlocal