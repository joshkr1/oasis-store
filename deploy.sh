#!/bin/bash
# Deployment script for Oasis Store

set -e

echo "🚀 Starting deployment..."

# Pull latest changes
git pull origin main

# Copy files to Apache server directory
sudo cp -r * /var/www/html/

# Restart Apache
sudo systemctl restart httpd

echo "✅ Deployment complete! Oasis Store is live."

