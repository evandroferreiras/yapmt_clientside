FROM node:8.16.1-alpine


RUN npm install -g http-server

WORKDIR /app

COPY . .

RUN npm install

RUN npm run build

EXPOSE 8080

CMD [ "http-server", "dist" ]