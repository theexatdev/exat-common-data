#!/bin/bash

# ask for git user
while true; do
  read -p "Enter GitLab user: " git_user
  echo
  if [[ -n $git_user ]]; then
    break
  else
    echo "GitLab user cannot be empty. Please try again."
  fi
done

# ask for git token
while true; do
  read -s -p "Enter GitLab access token: " git_access_token
  echo
  if [[ -n $git_access_token ]]; then
    break
  else
    echo "GitLab access token cannot be empty. Please try again."
  fi
done

repository="https://${git_user}:${git_access_token}@git.sbpds.com/government/exat/common/ckan-docker.git"
echo "$repository"
git clone "$repository"