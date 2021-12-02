#!/bin/bash

# Make sure we are in the master branch.
git checkout master

# Get current working dir.
PWD=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Remove previous src dir.
find src -depth -mindepth 1 ! -iregex 'src/index.js' | xargs rm -rf

REPOSITORY_DATA=$(curl --silent "https://api.github.com/repos/google/libphonenumber/releases/latest")
LATEST_TAG=$(echo $REPOSITORY_DATA | grep -Po '"tag_name": "v\K.*?(?=")')

# Download the requested tagged release.
echo "Downloading release $LATEST_TAG..."

curl -L -s https://github.com/googlei18n/libphonenumber/archive/v$LATEST_TAG.tar.gz -o v$LATEST_TAG.tar.gz

tar -xf v$LATEST_TAG.tar.gz

cp libphonenumber-$LATEST_TAG/javascript/i18n/phonenumbers/* src/

rm v$LATEST_TAG.tar.gz

rm -rf libphonenumber-$LATEST_TAG

# Add the modified files to git.
git add $PWD/../src/

if [ $(git diff --cached --name-only | wc --lines) -gt 0 ]; then
  # Prepare a new branch for this update.
  git checkout -b support/update-libphonenumber-${LATEST_TAG//\./\-}

  git config --global user.email "github-actions[bot]@users.noreply.github.com"
  git config --global user.name "github-actions[bot]"

  # Commit with the standard message.
  git commit -m "Update libphonenumber@$LATEST_TAG"

  # Push the new branch.
  git push -u origin support/update-libphonenumber-${LATEST_TAG//\./\-}
fi;

echo "Done!"
