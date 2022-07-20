# A docker image for the func container.

# default variant is the official alpine node image (much smaller than the standard image)
FROM node:14.20.0-alpine3.15
ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install OpenJDK- 
# (https://stackoverflow.com/a/61713897)
# https://github.com/geerlingguy/ansible-role-java/issues/64#issuecomment-597132394

RUN mkdir /usr/share/man/man1/

RUN  apk update \
  && apk upgrade \
  && apk add ca-certificates \
  && update-ca-certificates \
  && apk add --update coreutils && rm -rf /var/cache/apk/* \ 
  && apk add --update openjdk11 tzdata curl unzip bash \
  && apk add --no-cache nss \
  && rm -rf /var/cache/apk/*

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
RUN export JAVA_HOME


COPY package.json /usr/src/app/
RUN npm install && npm cache clean --force

# Needed for chromium
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      freetype-dev \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      yarn
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN npm i puppeteer@5.3.0
RUN addgroup -S pptruser && adduser -S -g pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app
COPY server.js /usr/src/app/server.js

USER pptruser

CMD [ "npm", "start" ]

EXPOSE 8888