#!/bin/sh

# Set variables
GENERATE_ZIP=false
BUILD_PATH="./build"

# Set options based on user input
if [ -n "$1" ]; then
  GENERATE_ZIP="$1"
fi

# If not configured, default to repository name
if [ -z "$PLUGIN_SLUG" ]; then
  PLUGIN_SLUG=${GITHUB_REPOSITORY#*/}
fi

# Set GitHub "path" output
DEST_PATH="$BUILD_PATH/$PLUGIN_SLUG"
echo "path=$DEST_PATH" >> "$GITHUB_OUTPUT"

# Navigate to the workspace
cd "$GITHUB_WORKSPACE" || exit

# Install PHP and JS dependencies
echo "Installing PHP and JS dependencies..."
yarn install || exit "$?"
composer install || exit "$?"

# Run JS build
echo "Running JS Build..."
yarn run build || exit "$?"

# Clean up PHP dependencies
echo "Cleaning up PHP dependencies..."
composer install --no-dev || exit "$?"

# Rsync files excluding those in .distignore, if present
if [ -r "${GITHUB_WORKSPACE}/.distignore" ]; then
  rsync -rc --exclude-from="$GITHUB_WORKSPACE/.distignore" "$GITHUB_WORKSPACE/" "$DEST_PATH/" --delete --delete-excluded || exit "$?"
else
  rsync -rc "$GITHUB_WORKSPACE/" "$DEST_PATH/" --delete || exit "$?"
fi

# Generate the zip file if requested
if [ "$GENERATE_ZIP" = true ]; then
  echo "Generating zip file..."
  cd "$BUILD_PATH" || exit
  zip -r "${PLUGIN_SLUG}.zip" "$PLUGIN_SLUG/" || exit "$?"
  # Set GitHub "zip_path" output
  echo "zip_path=$BUILD_PATH/${PLUGIN_SLUG}.zip" >> "$GITHUB_OUTPUT"
  echo "Zip file generated!"
fi

echo "Build done!"
