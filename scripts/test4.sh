#!/bin/bash

if [ -z "$GIT_URL" ]; then
    echo "ERROR: GIT_URL environment variable is not set or empty."
    exit 1
fi

## install exat
echo "HELLO $GIT_URL"