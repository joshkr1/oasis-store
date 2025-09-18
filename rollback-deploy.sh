#!/bin/bash
# Rollback script for Oasis Store

set -euo pipefail

APP_DIR="/var/www/html"
TMP_DIR="/tmp/oasis_rollback"

if [ $# -lt 1 ]; then
  echo "❌ Usage: $0 <tag>"
  echo "Example: $0 deploy-2025-09-18-21-05"
  exit 1
fi

ROLLBACK_TAG="$1"

echo "⏪ Rolling back Oasis Store to tag: $ROLLBACK_TAG"

# Step 1: Fetch latest tags from GitHub
git fetch --all --tags

# Step 2: Checkout the given tag
git checkout "$ROLLBACK_TAG"

# Step 3: Build temporary clean copy
echo "📦 Preparing rollback package..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

rsync -av --exclude='.git' --exclude='.env' --exclude='*.sh' ./ "$TMP_DIR/"

# Step 4: Deploy to Apache directory (atomic update)
echo "📂 Deploying to $APP_DIR..."
sudo rsync -av --delete "$TMP_DIR/" "$APP_DIR/"

# Step 5: Ensure proper ownership/permissions
sudo chown -R apache:apache "$APP_DIR"
sudo find "$APP_DIR" -type d -exec chmod 755 {} \;
sudo find "$APP_DIR" -type f -exec chmod 644 {} \;

# Step 6: Restart Apache
echo "🔄 Restarting Apache..."
sudo systemctl restart httpd

echo "✅ Rollback complete! Oasis Store is live at tag $ROLLBACK_TAG"

