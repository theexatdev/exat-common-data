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

package_data=$(cat <<EOF
{
    "geo_coverage_other": "",
    "maintainer": "test contact",
    "update_frequency_unit": "\u0e44\u0e21\u0e48\u0e21\u0e35\u0e01\u0e32\u0e23\u0e1b\u0e23\u0e31\u0e1a\u0e1b\u0e23\u0e38\u0e07\u0e2b\u0e25\u0e31\u0e07\u0e08\u0e32\u0e01\u0e01\u0e32\u0e23\u0e08\u0e31\u0e14\u0e40\u0e01\u0e47\u0e1a\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25",
    "tag_string": "test tag",
    "private": "False",
    "maintainer_email": "test@test.local",
    "last_updated_date": "",
    "data_language": "\u0e44\u0e17\u0e22",
    "reference_data": "",
    "data_support_other": "",
    "title": "$pacakge_name",
    "state": "draft",
    "pkg_name": "",
    "update_frequency_interval": "",
    "objective": "\u0e1e\u0e31\u0e19\u0e18\u0e01\u0e34\u0e08\u0e2b\u0e19\u0e48\u0e27\u0e22\u0e07\u0e32\u0e19",
    "license_id": "Open Data Common",
    "data_collect_other": "",
    "type": "dataset",
    "data_support": "",
    "data_type": "\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e23\u0e30\u0e40\u0e1a\u0e35\u0e22\u0e19",
    "tags": [{"state": "active", "name": "test tag"}],
    "accessible_condition": "",
    "high_value_dataset": "",
    "data_source": "test data",
    "allow_harvest": "True",
    "name": "$pacakge_name",
    "data_collect": "",
    "url": "",
    "update_frequency_unit_other": "",
    "notes": "test api description",
    "owner_org": "exat",
    "data_format": "CSV",
    "license_id_other": "",
    "data_category": "\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e2a\u0e32\u0e18\u0e32\u0e23\u0e13\u0e30",
    "created_date": "",
    "geo_coverage": "\u0e44\u0e21\u0e48\u0e21\u0e35"
}
EOF
)

curl -s -X POST -H "Content-Type: application/json" -H "$auth_header" "$BASE_URL/api/3/action/package_create" -d "$package_data" | pretty_json
