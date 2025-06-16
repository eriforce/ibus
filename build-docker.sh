#!/bin/bash

# Build script for IBus Docker images

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
BUILD_TYPE="simple"
IMAGE_NAME="ibus"
TAG="latest"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -t, --type TYPE     Build type: 'simple' or 'full' (default: simple)"
    echo "  -n, --name NAME     Image name (default: ibus)"
    echo "  -g, --tag TAG       Image tag (default: latest)"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Build simple version with default name"
    echo "  $0 -t full                  # Build full version with tests"
    echo "  $0 -n my-ibus -g v1.5.32   # Custom name and tag"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -g|--tag)
            TAG="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Validate build type
if [[ "$BUILD_TYPE" != "simple" && "$BUILD_TYPE" != "full" ]]; then
    echo -e "${RED}Error: Build type must be 'simple' or 'full'${NC}"
    exit 1
fi

# Set Dockerfile based on build type
if [[ "$BUILD_TYPE" == "simple" ]]; then
    DOCKERFILE="Dockerfile.simple"
    echo -e "${YELLOW}Building simple version (compile only, no tests)${NC}"
else
    DOCKERFILE="Dockerfile"
    echo -e "${YELLOW}Building full version (with tests and distcheck)${NC}"
fi

# Check if Dockerfile exists
if [[ ! -f "$DOCKERFILE" ]]; then
    echo -e "${RED}Error: $DOCKERFILE not found${NC}"
    exit 1
fi

FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

echo -e "${GREEN}Building IBus Docker image...${NC}"
echo "  Image name: $FULL_IMAGE_NAME"
echo "  Dockerfile: $DOCKERFILE"
echo "  Build context: $(pwd)"
echo ""

# Build the Docker image
echo -e "${YELLOW}Starting Docker build...${NC}"
docker build -f "$DOCKERFILE" -t "$FULL_IMAGE_NAME" .

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ Successfully built $FULL_IMAGE_NAME${NC}"
    echo ""
    echo "You can now run:"
    echo "  docker run --rm $FULL_IMAGE_NAME"
    echo "  docker run --rm -it $FULL_IMAGE_NAME /bin/bash"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
