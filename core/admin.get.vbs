Set RequestUAC = CreateObject("Shell.Application")
RequestUAC.ShellExecute "core\main.start.bat","/k","","runas",1 
WScript.Quit