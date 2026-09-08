FROM alpine:3.24 AS ffmpeg

RUN apk add --no-cache ffmpeg \
    && mkdir -p /out/bin /out/lib \
    && cp /usr/bin/ffmpeg /usr/bin/ffprobe /out/bin/ \
    && find /lib /usr/lib -type f -name '*.so*' -exec cp -a {} /out/lib/ \; \
    && find /lib /usr/lib -type l -name '*.so*' -exec cp -a {} /out/lib/ \;

FROM n8nio/n8n:2.34.6

USER root

COPY --from=ffmpeg /out/bin/ /opt/ffmpeg/bin/
COPY --from=ffmpeg /out/lib/ /opt/ffmpeg/lib/

RUN printf '#!/bin/sh\nLD_LIBRARY_PATH=/opt/ffmpeg/lib exec /opt/ffmpeg/bin/ffmpeg "$@"\n' \
    > /usr/local/bin/ffmpeg \
    && chmod +x /usr/local/bin/ffmpeg \
    && printf '#!/bin/sh\nLD_LIBRARY_PATH=/opt/ffmpeg/lib exec /opt/ffmpeg/bin/ffprobe "$@"\n' \
    > /usr/local/bin/ffprobe \
    && chmod +x /usr/local/bin/ffprobe

USER node
