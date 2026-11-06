#!/bin/sh

set -eu

echo "Selecting Firebase configuration..."

if [ "$PRODUCT_BUNDLE_IDENTIFIER" = "com.physiohomey.partner" ]; then
    SOURCE="${PROJECT_DIR}/Firebase/Partner/GoogleService-Info.plist"
    echo "Building PhysioHomey Partner"
else
    SOURCE="${PROJECT_DIR}/Runner/GoogleService-Info.plist"
    echo "Building PhysioHomey Customer"
fi

DEST="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/GoogleService-Info.plist"

if [ ! -f "$SOURCE" ]; then
    echo "error: Firebase configuration not found: $SOURCE"
    exit 1
fi

/usr/bin/ditto "$SOURCE" "$DEST"

echo "Firebase configuration copied successfully."