# Stage 1: Build
FROM node:18 AS build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Dynamically inject environment variables into .env file at build time
# RUN apt-get update && apt-get install -y gettext-base \
#     && envsubst < .env.backend > .env \
#     && rm .env.backend

RUN npm run build

# Stage 2: Production
FROM node:18

WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
COPY --from=build /app/.env ./

RUN npm install --production

EXPOSE 3000
CMD ["npm", "run", "start:prod"]
