#!/bin/bash
# Cleanup script to move unnecessary documentation files to /old folder
# Keeps the codebase clean for production deployment

echo "Starting cleanup of old documentation files..."

# Create old directory if it doesn't exist
mkdir -p /app/old

# List of files to move to old folder
OLD_FILES=(
  "AAPANEL_DEPLOYMENT_GUIDE.md"
  "BUILD_VERIFICATION_REPORT.md"
  "CONTACT_FORM_SERVICES.md"
  "DEPLOYMENT_CHECKLIST.md"
  "DEPLOYMENT_PACKAGE_SUMMARY.md"
  "DEPLOYMENT_SUMMARY_NEW_SERVICES.md"
  "FIXES_COMPLETE_SUMMARY.md"
  "PRODUCTION_BUILD_COMPLETE.md"
  "PRODUCTION_BUILD_SUMMARY.md"
  "PRODUCTION_BUILD_SUMMARY_FINAL.md"
  "PRODUCTION_README.md"
  "QUICK_DEPLOYMENT_GUIDE.md"
  "QUICK_DEPLOY_COMMANDS.md"
  "SCREENSHOTS_SUMMARY.md"
  "SEO_OPTIMIZATION_GUIDE.md"
  "SLACK_NOTIFICATION_SETUP.md"
  "nginx-aapanel.conf"
  "nginx-production-9001.conf"
  "nginx-production.conf"
  "supervisor-backend-9001.conf"
  "techresona-aapanel.tar.gz"
  "der.zip"
  "new-logo.jpg"
)

# Move files to old folder
for file in "${OLD_FILES[@]}"; do
  if [ -f "/app/$file" ]; then
    echo "Moving $file to /old folder..."
    mv "/app/$file" "/app/old/"
  fi
done

# Move old build scripts but keep the optimized one
if [ -f "/app/build-aapanel.sh" ]; then
  echo "Moving old build scripts to /old folder..."
  mv "/app/build-aapanel.sh" "/app/old/"
fi

if [ -f "/app/build-production.sh" ]; then
  mv "/app/build-production.sh" "/app/old/"
fi

echo "Cleanup complete! Old files moved to /app/old/"
echo "Production-ready codebase is now clean."
