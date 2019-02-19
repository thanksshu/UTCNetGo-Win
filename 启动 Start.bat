echo off
rem 环境设置 结束
CMD /E:ON /c
mode con cols=75 lines=3
color 87
chcp 936 >nul
title UTCNet-Go-Win

setlocal enabledelayedexpansion 
cd /d "%~dp0"
rem 环境设置 结束
rem 启动 开始
"core\admin.get.vbs" /f
rem 启动 结束
exit
endlocal