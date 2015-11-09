import sys
sys.path.append(".")

import argparse
from lambda_digitalocean.main import start


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("-k", "--api-key", required=True)
    parser.add_argument("-i", "--image-name", required=True)
    parser.add_argument("-r", "--region", required=True)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--user-data-file", required=False)
    group.add_argument("--user-data", required=False)

    args = parser.parse_args()

    start(
        api_key=args.api_key,
        image_name=args.image_name,
        region=args.region,
        user_data_file=args.user_data_file,
        user_data=args.user_data
    )


if __name__ == '__main__':
    sys.exit(main())
