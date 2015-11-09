import sys
sys.path.append(".")

import config
from lambda_digitalocean import main


def create(event, context):
    main.start(
        api_key=config.API_KEY,
        image_name=config.IMAGE_NAME,
        region=config.REGION,
        user_data_file=config.USER_DATA_FILENAME)


def cleanup(event, context):
    main.delete_temporary_droplets(api_key=config.API_KEY)