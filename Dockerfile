ARG DOTNET_VERSION=6.0.102

FROM alpine as base

# Installs latest Chromium (92) package.
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont

# Install .net dependencies
RUN apk add bash icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Puppeteer v10.0.0 works with Chromium 92.
#RUN npm install puppeteer

# Add user so we don't need --no-sandbox.
RUN addgroup -S pptruser && adduser -S -g pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

FROM base as build
ENV DOTNET_VER=$DOTNET_VERSION
RUN wget https://dot.net/v1/dotnet-install.sh
RUN chmod +x ./dotnet-install.sh
RUN ./dotnet-install.sh --version 6.0.102

FROM base as runtime
ENV DOTNET_VER=$DOTNET_VERSION
RUN wget https://dot.net/v1/dotnet-install.sh
RUN chmod +x ./dotnet-install.sh
RUN ./dotnet-install.sh --runtime --version 6.0.102

FROM build as runtime-builder

FROM runtime
COPY --from=runtime-builder /build /app
# Run everything after as non-privileged user.

# Create app directory
WORKDIR /home/pptruser

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

# RUN npm install
# If you are building your code for production
RUN npm install --production

# Bundle app source
COPY . .

RUN mv client_dist public
RUN mv server_dist server

RUN chown -R pptruser:pptruser /home/pptruser
USER pptruser

EXPOSE 4000
CMD [ "node", "server/index.js" ]