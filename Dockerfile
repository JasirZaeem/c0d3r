FROM node:18-alpine AS BuildBot
WORKDIR /usr/src/bot
COPY package.json .
COPY yarn.lock .
COPY tsconfig.json .
RUN yarn install
COPY . .
RUN yarn run build

FROM node:18-alpine
RUN apk add --no-cache tini

WORKDIR /usr/src/bot
COPY package.json .
COPY yarn.lock .
RUN yarn install --production && yarn cache clean
COPY --from=BuildBot /usr/src/bot/dist .
ENV NODE_ENV production
ENV PORT 80
EXPOSE 80

USER node
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "index.js"]
