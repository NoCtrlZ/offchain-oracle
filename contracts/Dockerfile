FROM node:12.11.1-alpine

WORKDIR /app

COPY . .

RUN apk add git &&\
    cp .env.example .env &&\
    npm i

EXPOSE 7545

ENTRYPOINT npm run deploy && node utilities/watcher.js
