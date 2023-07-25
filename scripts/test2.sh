#!/bin/bash

if [ -z "$GITURL" ]; then
    echo "ERROR: GITURL environment variable is not set or empty.
    exit 1
fi

## install exat
echo "HELLO $GITURL"