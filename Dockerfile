# Control what version of Node to use
ARG NODE_VERSION=16.8.0

# Stage 1.
# - Ensure `libc6-compat` is available to ensure native npm deps get built ok
# - Installs our node_modules according to our package* files
FROM node:${NODE_VERSION}-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ARG SOME_THING="hello"
RUN npm run build

# Stage 2.
# - Copies our source & node_modules from the last layer
# - Runs our production build
FROM node:${NODE_VERSION}-alpine as runner
WORKDIR /app
ENV NODE_ENV=production
RUN npm install http-server -g
COPY --from=builder /app/build ./build
EXPOSE 3000
CMD ["http-server", "./build", "-p 3000"]
