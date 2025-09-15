# Stage 1: Build the application
FROM node:lts-alpine AS build
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
RUN npm run make

# Stage 2: Create the final production image
FROM node:lts-alpine
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install --production --silent && mv node_modules ../
COPY . .
EXPOSE 3000
RUN chown -R node /usr/src/app

# Electron requires these dependencies to run
RUN apk add --no-cache udev ttf-freefont dbus libx11-xcb libxcb libxcomposite libxcursor libxdamage libxext libxfixes libxi libxrandr libxrender libxtst alsa-lib-dev

COPY --from=build /usr/src/app/out/electron-fiddle-linux-x64 /usr/src/app/

RUN chown -R node:node .
USER node

# The command to run the app will depend on the executable name from electron-forge
# This is a common pattern.
CMD ["./electron-fiddle"]
