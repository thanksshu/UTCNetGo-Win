Set RequestUAC = CreateObject("Shell.Application")
RequestUAC.ShellExecute "main.start.bat","/k","","runas",1 
WScript.Quit