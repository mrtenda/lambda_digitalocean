import sys
sys.path.append(".")

import argparse
from lambda_digitalocean.main import cleanup


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("-k", "--api-key", required=True)

    args = parser.parse_args()

    api_key = args.api_key

    cleanup(api_key=api_key)


if __name__ == '__main__':
    sys.exit(main())
