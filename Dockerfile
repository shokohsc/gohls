FROM jrottenberg/ffmpeg:4.1-scratch as ffmpeg

FROM golang:latest as builder
ARG VERSION="0.1.0"
WORKDIR /app

RUN apt update && \
    apt install -y ffmpeg git npm nodejs

COPY . .
RUN ./scripts/prep_release.sh $VERSION

FROM ubuntu
WORKDIR /app

COPY --from=ffmpeg /bin/ffmpeg /usr/bin/ffmpeg
COPY --from=ffmpeg /bin/ffprobe /usr/bin/ffprobe
COPY --from=builder /app/build/gohls-linux-amd64-0.1.0/gohls /usr/bin/gohls
COPY --from=builder /app/ui/build /build

ENTRYPOINT ["gohls"]
CMD ["serve", "--listen", ":8080", "-config", "/config/gohls-config.json"]