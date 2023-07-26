#!/bin/bash

BASE_URL="http://159.89.192.86"

usage() {
    echo "Usage: $0 <pacakge_name> [-t \"token\"]"
}

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

pacakge_name="$1"
token=""

if [ -z "$pacakge_name" ]; then
    usage
    exit 1
fi

shift
while getopts "q:t:i" opt; do
    case "$opt" in
        t)
            token="$OPTARG"
            ;;
        \?)
            usage
            exit 1
            ;;
    esac
done

json_data="{\"id\": \"$pacakge_name\"}"

auth_header=""
if [ -n "$token" ]; then
    auth_header="Authorization: $token"
fi

curl -s -X POST -H "Content-Type: application/json" -H "$auth_header" "$BASE_URL/api/3/action/package_show" -d "$json_data" | pretty_json


