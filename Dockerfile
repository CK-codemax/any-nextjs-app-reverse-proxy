FROM node:18-alpine

# Install git
RUN apk add --no-cache git

# Create app directory
WORKDIR /app

# Copy the shell script
COPY entrypoint.sh .

# Make the script executable
RUN chmod +x entrypoint.sh

# Set environment variable (can be overridden by build args)
# ARG GITHUB_REPO
# ENV GITHUB_REPO=$GITHUB_REPO

# Run the script on container start
CMD ["./entrypoint.sh"]

