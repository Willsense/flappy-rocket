# Use the official Node.js image as the base image
FROM node:20 AS builder

# Set the working directory in the container
WORKDIR /app

# Copy shared files
COPY package*.json ./
COPY tsconfig.json ./

# Copy server files
COPY workspaces/server/package*.json workspaces/server/
COPY workspaces/server workspaces/server/

# Copy client files
COPY workspaces/client/package*.json workspaces/client/
COPY workspaces/client workspaces/client/

# Install dependencies
RUN npm ci

# Build client
WORKDIR /app/workspaces/client
RUN npm run build --workspace=client

# Build server
WORKDIR /app

# Production image
FROM node:20

# Set the working directory in the container
WORKDIR /app

# Copy dependencies and built client
COPY --from=builder /app /app

# Expose the port the app runs on
EXPOSE 3000

# Start the server
CMD ["npm", "run", "start", "--workspace=server"]
