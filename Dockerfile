FROM alpine as build
ARG TOKEN
ARG RELEASE

ENV TOKEN=${TOKEN:-invalid}
ENV RELEASE=${RELEASE:-0.9.1}

RUN    apk update \
    && apk add alpine-sdk vim swig \
    && ln `which swig` `which swig`3.0 \
    && mkdir -p /var/cache/distfiles \
    && chmod a+w /var/cache/distfiles \
    && adduser -D freeswitch \
    && addgroup freeswitch abuild \
    && echo "freeswitch ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/freeswitch \
    && chmod 400 /etc/sudoers.d/freeswitch

USER freeswitch
WORKDIR /home/freeswitch
RUN    abuild-keygen -a -i \
    && git clone https://github.com/lazedo/freeswitch-docker-alpine.git \
    && cd freeswitch-docker-alpine \
    && git checkout -b kazoo origin/kazoo \
    && abuild checksum \
    && abuild -r

FROM alpine as freeswitch
COPY --from=build /home/freeswitch/packages/freeswitch/x86_64/* /apks/x86_64/
RUN echo -e "/apks\n$(cat /etc/apk/repositories)" > /etc/apk/repositories \
    && ls -la /apks/x86_64/ \
    && apk add --update --allow-untrusted \
           bash curl wget iproute2 \
           kazoo-freeswitch kazoo-freeswitch-flite

CMD ["freeswitch", "-nonat"]
