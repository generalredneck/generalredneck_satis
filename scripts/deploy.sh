#!/usr/bin/env bash

# This is to replace having to manually cp files from lando to hosting and
# commiting.

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GIT_PAGES_REPO=git@github.com:generalredneck/generalredneck.github.io.git
GIT_PAGES_REPO_DIR=/tmp/git-pages

 # For this to work, the user that's running this must have access to the
 # following repository.

 # Locally, make sure that your ssh key is added to github.

 # On CircleCI, use a user deploy key or add a custom ssh key that has write
 # access to the following repository on github. See
 # https://circleci.com/docs/add-ssh-key#circleci-cloud-or-server-3-x

 SATIS_ROOT="$SCRIPT_DIR/.."

 rm -rf "$GIT_PAGES_REPO_DIR"
 git clone "$GIT_PAGES_REPO" "$GIT_PAGES_REPO_DIR"
 git -C "$GIT_PAGES_REPO_DIR" checkout main
 rm -rf "$GIT_PAGES_REPO_DIR/packages"
 cp -r "$SATIS_ROOT/packages" "$GIT_PAGES_REPO_DIR/packages"
 git -C "$GIT_PAGES_REPO_DIR" add packages
 git -C "$GIT_PAGES_REPO_DIR" commit -m "Deploying Packagist Changes"
 git -C "$GIT_PAGES_REPO_DIR" push origin main
