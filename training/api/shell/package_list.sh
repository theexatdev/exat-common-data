#!/bin/bash

BASE_URL="http://159.89.192.86"

pretty_json() {
    local INDENT="   "
    local LEVEL=0
    local CHAR

    while IFS= read -r -n1 CHAR; do
        case "$CHAR" in
            '{' | '[')
                echo "$CHAR"
                ((LEVEL++))
                ;;
            '}' | ']')
                echo
                ((LEVEL--))
                for ((i = 0; i < LEVEL; i++)); do
                    echo -n "$INDENT"
                done
                echo "$CHAR"
                ;;
            ',')
                echo "$CHAR"
                for ((i = 0; i < LEVEL; i++)); do
                    echo -n "$INDENT"
                done
                ;;
            *)
                echo -n "$CHAR"
                ;;
        esac
    done
}

curl -s ${BASE_URL}/api/3/action/package_list | pretty_json