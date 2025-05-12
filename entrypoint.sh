#!/bin/sh

# Exit on any error
set -e

# Check for required environment variable
# if [ -z "$GITHUB_REPO" ]; then
#  echo "Error: GITHUB_REPO environment variable is not set"
#  exit 1
# fi

# Clone repo if not already cloned
if [ ! -d /app/src ]; then
  echo "Cloning repo GITHUB_REPO..."
  git clone https://github.com/CK-codemax/strix-tech.git /app/src
fi

# Install dependencies and build
echo "Installing dependencies"
cd /app/src
npm install
echo "Building app"
npm run build

# Start the app (bind to all interfaces)
echo "Starting app"
npx next start -p 3000 -H 0.0.0.0

