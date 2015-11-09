from common import get_image_id, create_temporary_droplet, delete_temporary_droplets


def start(api_key, image_name, region, user_data=None, user_data_file=None):
    if user_data and user_data_file:
        raise RuntimeError("Cannot provide both user_data and user_data_file")
    elif user_data_file:
        with open(user_data_file) as f:
            user_data = f.read()
    elif not user_data:
        user_data = ""

    image_id = get_image_id(
        api_key=api_key,
        image_name=image_name,
        region=region
    )

    create_temporary_droplet(
        api_key=api_key,
        image_id=image_id,
        region=region,
        user_data=user_data
    )


def cleanup(api_key):
    delete_temporary_droplets(api_key=api_key)
