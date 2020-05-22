FROM golang:1.14.3-alpine

ARG SIGNAL_CLI_VERSION=0.6.7

ENV GIN_MODE=release

RUN apk add --no-cache openjdk11 git wget

ENV LANG en_US.UTF-8

RUN cd /tmp/ \
        && wget -P /tmp/ https://github.com/AsamK/signal-cli/archive/v${SIGNAL_CLI_VERSION}.tar.gz \
        && tar -xvf /tmp/v${SIGNAL_CLI_VERSION}.tar.gz \
        && cd signal-cli-${SIGNAL_CLI_VERSION} \
        && ./gradlew build \
        && ./gradlew installDist \
        && ln -s /tmp/signal-cli-${SIGNAL_CLI_VERSION}/build/install/signal-cli/bin/signal-cli /usr/bin/signal-cli \
        && rm -rf /tmp/v${SIGNAL_CLI_VERSION}.tar.gz

RUN mkdir -p /signal-cli-config/
RUN mkdir -p /home/.local/share/signal-cli
COPY src/ /tmp/signal-cli-rest-api-src
RUN cd /tmp/signal-cli-rest-api-src && go get -d ./... && go build main.go

ENV PATH /tmp/signal-cli-rest-api-src/:/usr/bin/signal-cli-${SIGNAL_CLI_VERSION}/bin/:$PATH

EXPOSE 8080

ENTRYPOINT ["main"]
