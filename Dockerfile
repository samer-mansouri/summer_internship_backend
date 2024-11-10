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

RUN echo "DATABASE_HOST=db" > .env && \
    echo "DATABASE_PORT=3306" >> .env && \
    echo "DATABASE_USER=user" >> .env && \
    echo "DATABASE_PASSWORD=password" >> .env && \
    echo "DATABASE_NAME=mydatabase" >> .env && \
    echo "DATABASE_DRIVER=mysql" >> .env && \
    echo "" >> .env && \
    echo "REDIS_HOST=redis" >> .env && \
    echo "REDIS_PORT=6379" >> .env && \
    echo "REDIS_PASSWORD=optional" >> .env && \
    echo "REDIS_DB=0" >> .env

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
