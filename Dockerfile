# Base image
FROM node:20 as base

WORKDIR /app

# Copy shared files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm install

# Copy server files
COPY workspaces/server/package*.json workspaces/server/
COPY workspaces/server workspaces/server/

# Copy client files
COPY workspaces/client/package*.json workspaces/client/
COPY workspaces/client workspaces/client/

# Stage for server
FROM base as server

WORKDIR /app/workspaces/server

# Install dependencies
RUN npm install --production

# Run server
CMD ["npm", "run", "start", "--workspace=server"]

# Stage for client
FROM base as client

WORKDIR /app/workspaces/client

# Build client
RUN npm run build --workspace=client

# Serve client
FROM nginx:alpine

COPY --from=client /app/workspaces/client/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
