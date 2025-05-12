# Next.js Application with Nginx Reverse Proxy

This repository provides a production-ready Docker setup for running any Next.js application behind an Nginx reverse proxy. It's designed to be a template that can be used with any Next.js application by modifying the GitHub repository URL in both the `docker-compose.yml` and `entrypoint.sh` files.

## Overview

This setup consists of two main components:
1. A Next.js application container that builds and serves your application
2. An Nginx reverse proxy container that handles incoming requests and forwards them to the Next.js application

### Why Use This Setup?

- **Security**: The Next.js application is not directly exposed to the internet
- **Production Ready**: Includes proper proxy headers and configurations
- **Scalable**: Easy to add SSL, load balancing, or additional services
- **Portable**: Works consistently across different environments
- **Flexible**: Can be used with any Next.js application by changing the repository URL in both `docker-compose.yml` and `entrypoint.sh`

## Prerequisites

- Docker
- Docker Compose
- Git

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/CK-codemax/any-nextjs-app-reverse-proxy.git
   ```

2. Navigate to the project directory:
   ```bash
   cd any-nextjs-app-reverse-proxy
   ```

3. Modify the GitHub repository URL in both files:

   a. In `docker-compose.yml`:
   ```yaml
   services:
     nextjs-app:
       build:
         context: .
         args:
           GITHUB_REPO: https://github.com/your-username/your-nextjs-app.git  # Change this to your Next.js app repository
   ```

   b. In `entrypoint.sh`:
   ```bash
   # Change this line in entrypoint.sh
   git clone https://github.com/your-username/your-nextjs-app.git /app/src
   ```

   > **Important**: Make sure to update the repository URL in both files to match your Next.js application repository.

4. Build and start the containers in detached mode:
   ```bash
   docker-compose up --build -d
   ```

   > **Note**: The application will not be accessible until the containers are running. The build process may take a few minutes as it needs to:
   > - Clone your repository
   > - Install dependencies
   > - Build the Next.js application
   > - Start both the Next.js and Nginx containers

5. Check if containers are running:
   ```bash
   docker ps -a
   ```
   You should see both `nextjs-app` and `reverse-proxy` containers in the list. The status should be "Up" for both containers.

6. Once the containers are running, you can access your application at:
   ```
   http://localhost
   ```

   > **Important**: 
   > - If you don't see the containers running in `docker ps -a`, check the logs: `docker-compose logs -f`
   > - If you try to access the URL before the containers are fully running, you'll get a connection error
   > - To view container logs: `docker-compose logs -f`

## Running in Detached Mode

When running in production or when you don't need to see the logs in your terminal, you can run the containers in detached mode. This is useful for:
- Running the application in the background
- Production deployments
- Running multiple applications simultaneously

### Starting in Detached Mode

```bash
# Build and start in detached mode
docker-compose up --build -d

# Check container status
docker ps -a

# View logs while in detached mode
docker-compose logs -f

# Stop the containers
docker-compose down
```

### Managing Detached Containers

```bash
# Check container status
docker ps -a

# View logs
docker-compose logs -f

# View logs for a specific service
docker-compose logs -f nextjs-app
docker-compose logs -f reverse-proxy

# Stop containers
docker-compose down

# Restart containers
docker-compose restart

# Rebuild and restart in detached mode
docker-compose up --build -d --force-recreate
```

## Manual Build and Run

### Building the Images

1. First, edit the `docker-compose.yml` and `entrypoint.sh` files to set your GitHub repository URL as shown in the Quick Start section.

2. Build the Next.js application image using Docker Compose:
   ```bash
   # Build with logs
   docker-compose build

   # Or build in detached mode
   docker-compose build --no-log
   ```

   > **Note**: The build process will take some time as it needs to clone and build your Next.js application.

3. The Nginx image will be pulled automatically as it uses the official `nginx:alpine` image.

### Running the Containers

1. Using Docker Compose (recommended):
   ```bash
   # Run in detached mode
   docker-compose up -d

   # Check container status
   docker ps -a
   ```

   Once the containers are running (check with `docker ps -a`), access your application at `http://localhost`

2. Or run containers manually (after building with docker-compose):
   ```bash
   # Create a network
   docker network create app-net

   # Run the Next.js container in detached mode
   docker run -d --name nextjs-app --network app-net nextjs-app

   # Run the Nginx container in detached mode
   docker run -d --name reverse-proxy \
     -p 80:80 \
     -v $(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf \
     --network app-net \
     nginx:alpine

   # Check container status
   docker ps -a
   ```

   After running these commands, wait a few moments for the containers to start up, then access your application at `http://localhost`

## Configuration

### Environment Variables and Repository Configuration

- `GITHUB_REPO`: The URL of your Next.js application's GitHub repository
  - Must be set in the `docker-compose.yml` file under the `nextjs-app` service's build args
  - Must also be updated in the `entrypoint.sh` script
  - This is the only way to specify which repository to use
  - Both files must point to the same repository URL

### Customizing the Build Process

The `entrypoint.sh` script can be modified to customize how your Next.js application is installed, built, and started. By default, it uses:

```bash
# Default commands in entrypoint.sh
npm install
npm run build
npx next start -p 3000 -H 0.0.0.0
```

You can modify these commands in `entrypoint.sh` to:
- Use a different package manager (e.g., `yarn` or `pnpm`)
- Add custom build steps
- Change the start command or port
- Add environment-specific configurations
- Include additional setup steps

For example, to use Yarn instead of npm:
```bash
# Modified entrypoint.sh
yarn install
yarn build
yarn start -p 3000 -H 0.0.0.0
```

Or to add custom environment variables:
```bash
# Modified entrypoint.sh
export NODE_ENV=production
npm install
npm run build
NEXT_PUBLIC_API_URL=https://api.example.com npx next start -p 3000 -H 0.0.0.0
```

> **Note**: After modifying `entrypoint.sh`, you'll need to rebuild your containers:
> ```bash
> docker-compose down
> docker-compose up --build
> ```

### Nginx Configuration

The `nginx.conf` file contains the reverse proxy configuration. It:
- Listens on port 80
- Forwards requests to the Next.js application
- Sets appropriate proxy headers
- Can be modified to add SSL, caching, or other Nginx features

### Next.js Application

The `entrypoint.sh` script handles:
- Cloning the specified GitHub repository (from the GITHUB_REPO build arg)
- Installing dependencies
- Building the Next.js application
- Starting the application on port 3000

## Stopping the Application

```bash
# If using Docker Compose
docker-compose down

# If running containers manually
docker stop nextjs-app reverse-proxy
docker rm nextjs-app reverse-proxy
```

## Customization

### Adding SSL

To add SSL support:
1. Add your SSL certificates to the project
2. Modify `nginx.conf` to include SSL configuration
3. Update the port mapping in `docker-compose.yml` to include 443

### Changing Ports

To use different ports:
1. Modify the port mapping in `docker-compose.yml`
2. Update the `proxy_pass` directive in `nginx.conf` if changing the Next.js port

### Adding Environment Variables

To add environment variables for your Next.js application:
1. Add them to the `environment` section in `docker-compose.yml`
2. Or create a `.env` file and reference it in `docker-compose.yml`

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   - Ensure no other service is using port 80
   - Change the port mapping in `docker-compose.yml`

2. **Build Failures**
   - Check the GitHub repository URL
   - Ensure the repository is public or credentials are properly configured
   - Verify the repository contains a valid Next.js application

3. **Application Not Accessible**
   - Check if containers are running: `docker ps -a`
   - View container logs: `docker-compose logs -f nextjs-app` or `docker-compose logs -f reverse-proxy`
   - Verify network connectivity: `docker network inspect app-net`

4. **Container Running but Website Not Accessible**
   If the containers are running (`docker ps -a` shows status as "Up") but the website is not accessible:
   
   a. Access the Next.js container to check the application:
   ```bash
   # Get into the Next.js container shell
   docker exec -it nextjs-app /bin/sh

   # Once inside the container, you can:
   # Check if the application is running
   ps aux | grep next

   # Check the application logs
   cat /app/src/.next/server/pages-manifest.json

   # Check if the port is listening
   netstat -tulpn | grep 3000

   # Check the application directory
   ls -la /app/src

   # Exit the container
   exit
   ```

   b. Check the Nginx container:
   ```bash
   # Get into the Nginx container shell
   docker exec -it reverse-proxy /bin/sh

   # Once inside the container, you can:
   # Check Nginx configuration
   nginx -t

   # Check Nginx logs
   cat /var/log/nginx/error.log
   cat /var/log/nginx/access.log

   # Check if Nginx is running
   ps aux | grep nginx

   # Exit the container
   exit
   ```

   c. Common fixes:
   - Restart the Next.js container: `docker-compose restart nextjs-app`
   - Restart the Nginx container: `docker-compose restart reverse-proxy`
   - Rebuild and restart all containers: `docker-compose up --build -d --force-recreate`

### Debugging Tips

1. **Check Container Logs**
   ```bash
   # View all container logs
   docker-compose logs -f

   # View specific container logs
   docker-compose logs -f nextjs-app
   docker-compose logs -f reverse-proxy
   ```

2. **Check Container Status**
   ```bash
   # View all containers (including stopped ones)
   docker ps -a

   # View only running containers
   docker ps
   ```

3. **Network Troubleshooting**
   ```bash
   # Check if containers can communicate
   docker network inspect app-net

   # Test network connectivity from Next.js container
   docker exec nextjs-app ping reverse-proxy
   ```

4. **Application Debugging**
   ```bash
   # Access Next.js container
   docker exec -it nextjs-app /bin/sh

   # Common debugging commands inside container:
   # Check Node.js version
   node -v

   # Check npm version
   npm -v

   # Check if application files exist
   ls -la /app/src

   # Check application logs
   tail -f /app/src/.next/server/pages-manifest.json
   ```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details. 