FROM node:current-alpine

RUN mkdir -p /project/app
COPY app /project/app
COPY package.json /project 

WORKDIR /project
RUN npm i

EXPOSE 3001

CMD ["npm", "start"]