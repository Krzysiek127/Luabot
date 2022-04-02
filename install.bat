@echo off
PowerShell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; iex ((new-object net.webclient).DownloadString('https://github.com/luvit/lit/raw/master/get-lit.ps1'))"
lit install SinisterRectus/discordia
lit install creationix/coro-split
lit install creationix/coro-spawn
pause