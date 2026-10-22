#!/bin/bash
export WINEARCH=wow64 WINEPREFIX=/home/app/.wine DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1 LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
echo "=== wine version ==="
wine --version
Xvfb :99 -screen 0 1024x768x24 &
sleep 2
wine wineboot --init
if [ ! -d /home/app/.wine/drive_c/windows/mono ]; then
  echo "=== installing wine-mono via msiexec ==="
  wine msiexec /i /usr/share/wine/mono/wine-mono-11.0.0-x86.msi /quiet || true
fi
wine reg add 'HKCU\Software\Wine\Explorer' /v Desktop /d '1024x768' /f
wine reg add 'HKCU\Software\Wine\Explorer\Desktops' /v Default /d '1024x768' /f
x11vnc -display :99 -forever -shared -rfbport 5900 -nopw &
websockify --web /usr/share/novnc ${PORT:-10000} 127.0.0.1:5900 &
( while true; do curl -s "$RENDER_EXTERNAL_URL" > /dev/null 2>&1; sleep 540; done ) &
APP=$(find /home/app/ipts -name ipts.exe | head -1)
echo "=== launching $APP ==="
cd "$(dirname "$APP")"
wine "$APP" --no-sandbox --disable-setuid-sandbox --disable-gpu --disable-dev-shm-usage --disable-extensions --mute-audio &
( sleep 30; echo "=== ps at 30s ==="; ps aux | grep -iE 'ipts|wineserver' | grep -v grep; sleep 60; echo "=== ps at 90s ==="; ps aux | grep -iE 'ipts|wineserver' | grep -v grep; sleep 120; echo "=== ps at 210s ==="; ps aux | grep -iE 'ipts|wineserver' | grep -v grep ) &
sleep infinity
