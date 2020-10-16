FROM node:12.11.1-alpine

WORKDIR /app

COPY . .

RUN apk add git &&\
    cp .env.example .env &&\
    npm i &&\
    npm run build

ENTRYPOINT sleep 30 && npm run send & npm run listen
