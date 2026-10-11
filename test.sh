#!/bin/bash
set -e

LECTURE=${1:-"01-switch-security"}

# Remove trailing slash if provided
LECTURE=${LECTURE%/}

if [ ! -d "$LECTURE" ]; then
    echo "❌ Error: Lecture directory '$LECTURE' not found!"
    echo "Available lectures:"
    ls -d [0-9]*/ | grep -v "\."
    exit 1
fi

echo "🐳 Ensuring Docker container is running..."
cd local_env
docker compose up -d
cd ..

echo "🚀 Starting Slidev interactive Dev Server for $LECTURE..."
echo "👉 Open http://localhost:3030 in your browser."
echo "Press Ctrl+C to stop the server."
echo ""

# The markdown file usually matches the folder name in this structure
MD_FILE="$LECTURE/$LECTURE.md"

if [ ! -f "$MD_FILE" ]; then
    # Fallback to slides.md if the specific named file doesn't exist
    if [ -f "$LECTURE/slides.md" ]; then
        MD_FILE="$LECTURE/slides.md"
    else
        echo "❌ Error: Could not find $MD_FILE or $LECTURE/slides.md"
        exit 1
    fi
fi

# Run the dev server interactively inside the container
docker exec -it sred-slidev-build-docker npx -y @slidev/cli "$MD_FILE" --remote --port 3030

