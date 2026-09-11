FROM alpine:3.24 AS ffmpeg

RUN apk add --no-cache \
    ffmpeg \
    fontconfig \
    ttf-dejavu \
    && mkdir -p /out/bin \
                /out/lib \
                /out/etc/fonts \
                /out/usr/share/fonts \
    && cp /usr/bin/ffmpeg /usr/bin/ffprobe /out/bin/ \
    && cp -a /etc/fonts/. /out/etc/fonts/ \
    && cp -a /usr/share/fonts/. /out/usr/share/fonts/ \
    && find /lib /usr/lib -type f -name '*.so*' -exec cp -a {} /out/lib/ \; \
    && find /lib /usr/lib -type l -name '*.so*' -exec cp -a {} /out/lib/ \;

FROM n8nio/n8n:2.38.6

USER root

COPY --from=ffmpeg /out/bin/ /opt/ffmpeg/bin/
COPY --from=ffmpeg /out/lib/ /opt/ffmpeg/lib/

COPY --from=ffmpeg /out/etc/fonts/ /etc/fonts/
COPY --from=ffmpeg /out/usr/share/fonts/ /usr/share/fonts/

RUN printf '#!/bin/sh\nLD_LIBRARY_PATH=/opt/ffmpeg/lib FONTCONFIG_PATH=/etc/fonts exec /opt/ffmpeg/bin/ffmpeg "$@"\n' \
    > /usr/local/bin/ffmpeg \
    && chmod +x /usr/local/bin/ffmpeg \
    && printf '#!/bin/sh\nLD_LIBRARY_PATH=/opt/ffmpeg/lib FONTCONFIG_PATH=/etc/fonts exec /opt/ffmpeg/bin/ffprobe "$@"\n' \
    > /usr/local/bin/ffprobe \
    && chmod +x /usr/local/bin/ffprobe

USER node
