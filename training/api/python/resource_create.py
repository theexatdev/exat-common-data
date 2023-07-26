# encoding: utf-8

import argparse
import requests
import json

BASE_URL = "http://159.89.192.86"

def create_resource(access_token, package_id, resource_name):
    try:
        headers = {
            "Authorization": access_token
        }
        data = {
            "package_id": package_id,
            "name": resource_name,
            "format": "CSV"
        }
        with open('dataset.csv', 'rb') as file:
            response = requests.post(f"{BASE_URL}/api/3/action/resource_create",
                          headers=headers,
                          data=data,
                          files=[('upload', file)])
            
            print(json.dumps(response.json(), indent=4))
    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--access_token", help="Access token")
    parser.add_argument("--package_id", help="Package ID")
    parser.add_argument("--resource_name", help="Resource name")
    args = parser.parse_args()

    if args.access_token and args.package_id and args.resource_name:
        create_resource(args.access_token, args.package_id, args.resource_name)
    else:
        print("Please provide all the required arguments: --access_token, --package_id, --resource_name")
