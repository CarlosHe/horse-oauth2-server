FROM ubuntu:18.04

RUN apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y \
    && apt-get install -y tzdata && apt-get install -y joe wget p7zip-full curl openssh-server build-essential zlib1g-dev libcurl4-gnutls-dev libncurses5

RUN wget https://www.openssl.org/source/openssl-1.0.2g.tar.gz \
    && tar -xzvf openssl-1.0.2g.tar.gz \
    && cd openssl-1.0.2g \
    && ./config \
    && make install \
    && ln -sf /usr/local/ssl/bin/openssl `which openssl`

RUN apt-get install -y libpq-dev

COPY ./Linux64/Release/oauth2_server /usr/sbin/
ENTRYPOINT /usr/sbin/oauth2_server