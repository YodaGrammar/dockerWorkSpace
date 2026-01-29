FROM node:25-alpine

RUN apk add --update --no-cache curl

WORKDIR /app

# Expose the port used by the Vite development server
EXPOSE 3000

# Use a default command, can be overridden in Docker compose.yml file
CMD ["npm", "run", "dev"]