FROM n8nio/n8n:latest

USER root

# Install curl
RUN apk add --no-cache curl

USER node

