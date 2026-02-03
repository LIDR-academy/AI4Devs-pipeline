#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./build_and_push_docker.sh [options]

Options:
  -u, --username   Docker Hub username (or DOCKERHUB_USERNAME)
  -r, --repo       Docker Hub repository name (or DOCKERHUB_REPO)
  -t, --tag        Image tag (default: latest)
  -c, --context    Docker build context (default: ./backend)
  -f, --dockerfile Dockerfile path (default: ./backend/Dockerfile)
  -h, --help       Show this help message

Example:
  ./build_and_push_docker.sh -u myuser -r myrepo -t v1.0.0
USAGE
}

DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-}" 
DOCKERHUB_REPO="${DOCKERHUB_REPO:-}"
IMAGE_TAG="latest"
BUILD_CONTEXT="./backend"
DOCKERFILE_PATH="./backend/Dockerfile"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--username)
      DOCKERHUB_USERNAME="$2"
      shift 2
      ;;
    -r|--repo)
      DOCKERHUB_REPO="$2"
      shift 2
      ;;
    -t|--tag)
      IMAGE_TAG="$2"
      shift 2
      ;;
    -c|--context)
      BUILD_CONTEXT="$2"
      shift 2
      ;;
    -f|--dockerfile)
      DOCKERFILE_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
 done

if [[ -z "$DOCKERHUB_USERNAME" || -z "$DOCKERHUB_REPO" ]]; then
  echo "Error: Docker Hub username and repo are required." >&2
  usage
  exit 1
fi

IMAGE_REF="${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:${IMAGE_TAG}"

if command -v curl >/dev/null 2>&1; then
  echo "Existing tags for ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:"
  curl -fsSL "https://hub.docker.com/v2/repositories/${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}/tags?page_size=100" \
    | python3 -c "import json,sys; data=json.load(sys.stdin); print('\n'.join(t['name'] for t in data.get('results', [])))" \
    || echo "Unable to list tags (repository may be private or not found)."
else
  echo "curl is not installed; skipping tag listing."
fi

echo "\nBuilding image: ${IMAGE_REF}"
docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_REF" "$BUILD_CONTEXT"

echo "\nPushing image: ${IMAGE_REF}"
docker push "$IMAGE_REF"

echo "\nDone."
