FROM golang:1.20.4-alpine as builder

RUN mkdir -p /build
ADD . /build
WORKDIR /build

RUN CGO_ENABLED=0 go build -o app

FROM scratch

LABEL org.opencontainers.image.source="https://github.com/m-wrzesien/infoshare-2023"

COPY --from=builder /build/app /

ENTRYPOINT ["/app"]