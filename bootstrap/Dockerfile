FROM alpine:3.12

WORKDIR app

COPY . .

RUN apk add --update --upgrade \
    rust=1.44.0-r0 \
    cargo=1.44.0-r0 &&\
    cargo build

EXPOSE 3000

ENTRYPOINT [ "cargo", "run" ]
