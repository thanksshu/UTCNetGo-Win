Set Ws=CreateObject("Wscript.Shell")
Ws.run "tun2socks.exe -tunName tun1 -tunAddr 10.0.0.2 -tunGw 10.0.0.1 -proxyType socks -proxyServer 127.0.0.1:1080",0
WScript.Quit