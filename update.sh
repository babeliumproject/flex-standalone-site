#!/bin/bash

# Revert uncommitted changes
echo "Reverting ucommitted changes"
git reset --hard

# Remove the dist folder
echo "Removing dist folder"
rm -r dist

# Pull the latest revision of the code
echo "Pulling latest revision of the code"
git pull

# Deploy to the dist folder
echo "Deploying using ant"
ANT_OPTS="-Xmx1024M" ant 

