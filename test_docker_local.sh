#!/bin/bash

# Variables
IMAGE_NAME="example-flask-crud"
TAG="latest"

# Run the container locally
docker run -d -p 80:80 --name test-crud $IMAGE_NAME:$TAG

echo "✅ Container is running locally on http://localhost (port 80)"

# Optional: show logs
echo "📜 To view logs, use: docker logs -f test-crud"
