#!/bin/bash

BASE_URL="http://159.89.192.86"

usage() {
    echo "Usage: $0 [-q \"query\"] [-t \"token\"] [-i]"
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

query=""
token=""
include_private="false"

while getopts "q:t:i" opt; do
    case "$opt" in
        q)
            query="$OPTARG"
            ;;
        t)
            token="$OPTARG"
            ;;
        i)
            include_private="true"
            ;;
        \?)
            usage
            exit 1
            ;;
    esac
done

json_data="{"
if [ -n "$query" ]; then
    json_data+="\"q\": \"$query\","
fi
json_data+="\"include_private\": $include_private,"
json_data="${json_data%,}"
json_data+="}"

auth_header=""
if [ -n "$token" ]; then
    auth_header="Authorization: $token"
fi

curl -s -X POST -H "Content-Type: application/json" -H "$auth_header" "$BASE_URL/api/3/action/package_search" -d "$json_data" | pretty_json


