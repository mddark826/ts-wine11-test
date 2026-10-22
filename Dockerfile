FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive WINEARCH=wow64 WINEPREFIX=/home/app/.wine DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --no-install-recommends wget gnupg ca-certificates curl p7zip-full xvfb x11vnc novnc python3-websockify fonts-wqy-zenhei locales xterm && mkdir -pm755 /etc/apt/keyrings && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources && apt-get update && apt-get install -y --install-recommends winehq-stable && apt-get install -y --no-install-recommends libegl1:i386 libgles2:i386 libgl1-mesa-dri:i386 libgl1:i386 && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && locale-gen zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8

RUN useradd -m app
WORKDIR /home/app

RUN wget -O /tmp/ipts.7z http://dlc.ipts.com/v5/ipts.7z && 7z x -pipts123 -o/home/app/ipts /tmp/ipts.7z && rm /tmp/ipts.7z && chown -R app:app /home/app

COPY start.sh /home/app/start.sh
RUN chmod +x /home/app/start.sh

USER app
CMD ["/bin/bash", "/home/app/start.sh"]
