FROM node:16

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . . 

ENV PORT=8080

EXPOSE 8080

CMD [ "node", "index.js"]