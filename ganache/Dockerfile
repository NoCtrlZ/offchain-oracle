FROM node:12.11.1-alpine

WORKDIR /app

COPY . .

RUN apk add git &&\
    npm i &&\
    mkdir sample &&\
    npm i -g ganache-cli

EXPOSE 7545

ENTRYPOINT npm run deploy & ganache-cli -m="belt prize arrow cabbage banner proof word above ability helmet design rely" --networkId=5777 -p 7545 -h 0.0.0.0
