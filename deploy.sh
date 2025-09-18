#!/bin/bash
# Deployment script for Oasis Store

set -euo pipefail

echo "🚀 Starting deployment..."

APP_DIR="/var/www/html"
TMP_DIR="/tmp/oasis_deploy"

# Step 1: Commit & push local changes to GitHub
echo "💾 Saving local changes to GitHub..."
git add .
git commit -m "chore: auto-deploy from EC2 on $(date)" || echo "ℹ️ No changes to commit"
git push origin main

# Step 2: Create and push a unique deployment tag
TAG="deploy-$(date +'%Y-%m-%d-%H-%M-%S')"
echo "🏷️ Creating deployment tag: $TAG"
git tag -a "$TAG" -m "Deployment on $(date)"
git push origin "$TAG"

# Step 3: Pull latest changes from GitHub
echo "⬇️ Pulling latest changes from GitHub..."
git pull origin main --tags

# Step 4: Build temporary clean copy
echo "📦 Preparing deployment package..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

rsync -av --exclude='.git' --exclude='.env' --exclude='*.sh' ./ "$TMP_DIR/"

# Step 5: Deploy to Apache directory (atomic update)
echo "📂 Deploying to $APP_DIR..."
sudo rsync -av --delete "$TMP_DIR/" "$APP_DIR/"

# Step 6: Ensure proper ownership/permissions
sudo chown -R apache:apache "$APP_DIR"
sudo find "$APP_DIR" -type d -exec chmod 755 {} \;
sudo find "$APP_DIR" -type f -exec chmod 644 {} \;

# Step 7: Restart Apache
echo "🔄 Restarting Apache..."
sudo systemctl restart httpd

echo "✅ Deployment complete! Oasis Store is live at tag $TAG"

