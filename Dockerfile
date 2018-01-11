from alpine as build
RUN    apk update \
    && apk add alpine-sdk \
    && mkdir -p /var/cache/distfiles \
    && sudo chmod a+w /var/cache/distfiles \
    && adduser -D freeswitch \
    && echo "freeswitch ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && addgroup freeswitch abuild
USER freeswitch
RUN    abuild-keygen -a -i \
    && git clone https://github.com/lazedo/freeswitch-docker-alpine.git \
    && cd freeswitch-docker-alpine \
    && abuild -r

from alpine
COPY --from /home/freeswitch/packages/freeswitch-1.9.0-r0.apk /
RUN apk update \
    && apk add /freeswitch-1.9.0-r0.apk --allow-untrusted \
    && rm freeswitch-1.9.0-r0.apk

ENTRYPOINT ["freeswitch", "-nonat"]

