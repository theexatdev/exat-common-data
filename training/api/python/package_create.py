# encoding: utf-8

import argparse
import requests
import json
from helper import create_package_data

BASE_URL = "http://159.89.192.86"
ORG_ID = "exat"

def create_package(access_token, package_id):
    try:
        headers = {
            "Authorization": access_token
        }
        data = create_package_data(ORG_ID, package_id)
        response = requests.post(f"{BASE_URL}/api/3/action/package_create",
                        headers=headers,
                        json=data)
        
        print(json.dumps(response.json(), indent=4))
    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--access_token", help="Access token")
    parser.add_argument("--package_id", help="Package ID")
    args = parser.parse_args()

    if args.access_token and args.package_id:
        create_package(args.access_token, args.package_id)
    else:
        print("Please provide all the required arguments: --access_token, --package_id")
