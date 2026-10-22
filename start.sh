#!/bin/bash
export WINEARCH=wow64 WINEPREFIX=/home/app/.wine DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1 LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
echo "=== wine version ==="
wine --version
mkdir -p /home/app/.cache/wine
cp /usr/share/wine/mono/wine-mono-10.4.1-x86.msi /home/app/.cache/wine/ 2>/dev/null || true
Xvfb :99 -screen 0 1024x768x24 &
sleep 2
WINEDEBUG=+mscoree wine wineboot --init
for i in $(seq 1 72); do
  if [ -d /home/app/.wine/drive_c/windows/mono ] && ! pgrep -f wineboot.exe > /dev/null; then echo "=== prefix ready after ${i} checks ==="; break; fi
  sleep 5
done
if [ ! -d /home/app/.wine/drive_c/windows/mono ]; then
  echo "=== installing wine-mono via msiexec ==="
  wine msiexec /i /usr/share/wine/mono/wine-mono-10.4.1-x86.msi /quiet || true
  sleep 5
fi
wine reg add 'HKCU\Software\Wine\Explorer' /v Desktop /d '1024x768' /f
wine reg add 'HKCU\Software\Wine\Explorer\Desktops' /v Default /d '1024x768' /f
x11vnc -display :99 -forever -shared -rfbport 5900 -nopw &
websockify --web /usr/share/novnc ${PORT:-10000} 127.0.0.1:5900 &
( while true; do curl -s "$RENDER_EXTERNAL_URL" > /dev/null 2>&1; sleep 540; done ) &
APP=$(find /home/app/ipts -name ipts.exe | head -1)
echo "=== launching $APP ==="
cd "$(dirname "$APP")"
WINEDEBUG=+mscoree wine "$APP" --no-sandbox --disable-setuid-sandbox --disable-gpu --disable-dev-shm-usage --disable-extensions --mute-audio &
( sleep 45; echo "=== ps full at 45s ==="; ps aux; if ! ps aux | grep -i '[i]pts.exe' > /dev/null; then echo "=== relaunching app (attempt 2) ==="; cd "$(dirname "$APP")"; WINEDEBUG=+mscoree wine "$APP" --no-sandbox --disable-setuid-sandbox --disable-gpu --disable-dev-shm-usage --disable-extensions --mute-audio & fi; sleep 75; echo "=== ps full at 120s ==="; ps aux ) &
sleep infinity
