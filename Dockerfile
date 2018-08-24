FROM node:8.11.4

WORKDIR /usr/app

COPY package-lock.json package.json ./
RUN npm install --no-progress --ignore-optional

CMD npm run dev
