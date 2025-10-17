# vim:set ft=dockerfile:
ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}

# ARGs are cleared after every FROM
# see: https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG DEBIAN_VERSION
ARG TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxx

# By default, install the full set of FreeSWITCH packages.  Specify an alternative with:
#   --build-arg="FS_META_PACKAGE=freeswitch-meta-vanilla"
# alternatives include:
#   freeswitch-meta-bare
#   freeswitch-meta-vanilla
#   freeswitch-meta-sorbet
#   freeswitch-meta-all-dbg
ARG FS_META_PACKAGE=freeswitch-meta-bare

# Source Dockerfile:
# https://github.com/docker-library/postgres/blob/master/9.4/Dockerfile

# explicitly set user/group IDs
ARG FREESWITCH_UID=499
ARG FREESWITCH_GID=499
RUN groupadd -r freeswitch --gid=${FREESWITCH_GID} && useradd -r -g freeswitch --uid=${FREESWITCH_UID} freeswitch

# make the "en_US.UTF-8" locale so freeswitch will be utf-8 enabled by default
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends ca-certificates gnupg gnupg2 gosu locales wget curl lsb-release ntp gdb \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

# https://freeswitch.org/confluence/display/FREESWITCH/Debian
# https://developer.signalwire.com/freeswitch/FreeSWITCH-Explained/Installation/Linux/Debian_67240088/

# RUN wget --no-verbose --http-user=signalwire --http-password=${TOKEN} \
#      -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg \
#      https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg \
#     && echo "machine freeswitch.signalwire.com login signalwire password ${TOKEN}" > /etc/apt/auth.conf \
#     && echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ ${DEBIAN_VERSION} main" > /etc/apt/sources.list.d/freeswitch.list \
RUN curl -sSL https://freeswitch.org/fsget | bash -s ${TOKEN} release \
    && apt-get -qq update \
    && apt-get install -y ${FS_META_PACKAGE}

RUN apt-get install -y freeswitch-conf-vanilla freeswitch-mod-commands freeswitch-meta-codecs freeswitch-mod-console freeswitch-mod-logfile freeswitch-mod-distributor \
    freeswitch-lang-en freeswitch-mod-say-en freeswitch-sounds-en-us-callie \
    freeswitch-mod-enum freeswitch-mod-cdr-csv freeswitch-mod-event-socket freeswitch-mod-sofia freeswitch-mod-sofia-dbg freeswitch-mod-loopback \
    freeswitch-mod-conference freeswitch-mod-db freeswitch-mod-dptools freeswitch-mod-expr freeswitch-mod-fifo libyuv-dev freeswitch-mod-httapi \
    freeswitch-mod-hash freeswitch-mod-esl freeswitch-mod-esf freeswitch-mod-fsv freeswitch-mod-valet-parking freeswitch-mod-dialplan-xml freeswitch-dbg \
    freeswitch-mod-sndfile freeswitch-mod-native-file freeswitch-mod-local-stream freeswitch-mod-tone-stream freeswitch-mod-lua freeswitch-meta-mod-say \
    freeswitch-mod-xml-cdr freeswitch-mod-verto freeswitch-mod-callcenter freeswitch-mod-rtc freeswitch-mod-png freeswitch-mod-json-cdr freeswitch-mod-shout \
    freeswitch-mod-sms freeswitch-mod-sms-dbg freeswitch-mod-cidlookup freeswitch-mod-memcache \
    freeswitch-mod-imagick freeswitch-mod-tts-commandline freeswitch-mod-directory freeswitch-mod-flite \
    freeswitch-mod-pgsql freeswitch-mod-av \
    freeswitch-music-default

RUN apt-get purge -y --auto-remove \
    && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

#remove the music package to protect music on hold from package updates
RUN mkdir -p /usr/share/freeswitch/sounds/temp
RUN mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/temp
RUN apt-get remove -y freeswitch-music-default
RUN mkdir -p /usr/share/freeswitch/sounds/music/default
RUN mv /usr/share/freeswitch/sounds/temp/* /usr/share/freeswitch/sounds/music/default
RUN rm -R /usr/share/freeswitch/sounds/temp

COPY docker-entrypoint.sh /
# Add anything else here

## Ports
# Document ports used by this container
### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 5066 ws, 7443 wss, 8081 8082 verto, 16384-32768, 64535-65535 rtp
EXPOSE 8021/tcp
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 5061/tcp 5061/udp 5081/tcp 5081/udp
EXPOSE 5066/tcp
EXPOSE 7443/tcp
EXPOSE 8081/tcp 8082/tcp
EXPOSE 64535-65535/udp
EXPOSE 16384-32768/udp

# Volumes
## Freeswitch Configuration
#VOLUME ["/etc/freeswitch"]
## Tmp so we can get core dumps out
#VOLUME ["/tmp"]

# Limits Configuration
COPY    build/freeswitch.limits.conf /etc/security/limits.d/

# Healthcheck to make sure the service is running
SHELL       ["/bin/bash", "-c"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  fs_cli -x status | grep -q ^UP || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeswitch"]
