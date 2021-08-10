# docker build --build-arg SENSORS="12 10000" \
#  --build-arg MQTT_HOST=192.168.x.x --build-arg MQTT_PORT=1883 \
#  --build-arg=MQTT_USERNAME=username --build-arg=MQTT_PASSWORD=hemligt

FROM alpine:edge as BUILD_ENV

COPY ./sparsnas_decode.cpp /build/

RUN apk add --no-cache g++ mosquitto-dev && \
    g++ -o /build/sparsnas_decode -O2 -Wall /build/sparsnas_decode.cpp -lmosquitto

FROM alpine:edge

ARG MQTT_HOST
ARG MQTT_PORT
ARG MQTT_USERNAME
ARG MQTT_PASSWORD
ARG SPARSNAS_SENSOR_ID
ENV MQTT_HOST=${MQTT_HOST:-localhost}
ENV MQTT_PORT=${MQTT_PORT:-1883}
ENV MQTT_USERNAME=$MQTT_USERNAME
ENV MQTT_PASSWORD=$MQTT_PASSWORD
ENV SPARSNAS_DECODE=/usr/bin/sparsnas_decode
ENV SPARSNAS_SENSOR_ID=${SPARSNAS_SENSOR_ID:-0}
ENV SPARSNAS_PULSES_PER_KWH=1000

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
      rtl-sdr \
      mosquitto-libs++ \
      zsh

COPY --from=BUILD_ENV /build/sparsnas_decode /usr/bin/
COPY sparsnas.sh /

ENTRYPOINT ["/sparsnas.sh"]
