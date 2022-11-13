@echo off
title Youtube Downloader


:loop
echo Wpisz link do filmu
set /p "link=$ "

echo Czy chcesz pobrac mp4 [domyslnie mp3]
set /p "ext=$ "

if %ext% == tak goto mp4
goto mp3

:mp4
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" %link%
goto koniec

:mp3
yt-dlp -x --audio-format mp3 %link%
goto koniec


:koniec
echo "Czy chcesz juz skonczyc [tak/nie]?"
set /p "cho=$ "
if %cho% == tak goto end
goto loop

:end
