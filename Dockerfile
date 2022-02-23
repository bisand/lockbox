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
RUN wget https://dot.net/v1/dotnet-install.sh
RUN chmod +x ./dotnet-install.sh
RUN sed -i "s|--waitretry 2||g" dotnet-install.sh
RUN sed -i "s|--connect-timeout 15||g" dotnet-install.sh
RUN ./dotnet-install.sh

FROM base as runtime
RUN wget https://dot.net/v1/dotnet-install.sh
RUN chmod +x ./dotnet-install.sh
RUN sed -i "s|--waitretry 2||g" dotnet-install.sh
RUN sed -i "s|--connect-timeout 15||g" dotnet-install.sh
RUN ./dotnet-install.sh --runtime dotnet --install-dir /home/pptruser/.dotnet
ENV DOTNET_ROOT=/home/pptruser/.dotnet

FROM build as runtime-builder
COPY . /src
RUN mkdir /build
WORKDIR /src
# RUN /root/.dotnet/dotnet restore /src/Lockbox.Shell/Lockbox.Shell.csproj
RUN /root/.dotnet/dotnet publish /src/Lockbox.Shell/Lockbox.Shell.csproj --output /build 

FROM runtime
COPY --from=runtime-builder /build /home/pptruser/app
# Run everything after as non-privileged user.

# Create app directory
WORKDIR /home/pptruser/app

RUN chown -R pptruser:pptruser /home/pptruser
# USER pptruser

EXPOSE 4000
CMD [ "./Lockbox.Shell" ]