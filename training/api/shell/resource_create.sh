#!/bin/bash

BASE_URL="http://159.89.192.86"
packag_id="api-test-dataset"

usage() {
    echo "Usage: $0 <resource_name> [-t \"token\"]"
}

resource_name="$1"
token=""

if [ -z "$resource_name" ]; then
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

auth_header=""
if [ -n "$token" ]; then
    auth_header="Authorization: $token"
fi


curl -X POST -H "Content-Type: multipart/form-data" -H "$auth_header" "$BASE_URL/api/3/action/resource_create" --form upload=@dataset.csv --form package_id=$packag_id --form name=$resource_name --form format=CSV