from datetime import datetime, timedelta
import time

import digitalocean

DROPLET_NAME_FORMAT = "lambdaRun-{id}-{expiration_time}"


def get_image_id(api_key, image_name, region):
    print "Looking up image ID for image name {} in region {}...".format(image_name, region)
    manager = digitalocean.Manager(token=api_key)
    images = manager.get_all_images()
    for image in images:
        if image.name == image_name:
            print "Got image ID", image.id
            return image.id
    raise RuntimeError("No image found with name '{}'".format(image_name) +
                       (" in region '{}'".format(region) if region else ""))


def get_ssh_key_id(api_key, ssh_key_fingerprint):
    print "Looking up ssh key ID for key fingerprint {}...".format(ssh_key_fingerprint)
    manager = digitalocean.Manager(token=api_key)
    key = manager.get_ssh_key(ssh_key_fingerprint)
    print "Got key ID", key.id
    return key.id


def create_temporary_droplet(api_key, image_id, image_name, region, ssh_key_id, user_data, lifespan_in_seconds):
    expiration_date = datetime.now() + timedelta(seconds=lifespan_in_seconds)
    expiration_date_posix = int(time.mktime(expiration_date.timetuple()))
    droplet_name = DROPLET_NAME_FORMAT.format(
        id=image_name,
        expiration_time=expiration_date_posix,
    )
    print "Creating temporary droplet {}...".format(droplet_name)
    droplet = digitalocean.Droplet(
        token=api_key,
        name=droplet_name,
        region=region,
        image=image_id,
        size_slug='512mb',
        backups=False,
        user_data=user_data,
        ssh_keys=[ssh_key_id]
    )
    droplet.create()


def delete_expired_droplets(api_key):
    now_posix = int(time.time())

    manager = digitalocean.Manager(token=api_key)

    for droplet in manager.get_all_droplets():
        if not droplet.name.startswith("lambdaRun-"):
            continue

        expiration_date_posix = int(droplet.name.split('-')[-1])
        if expiration_date_posix > now_posix:
            print "Not deleting non-expired droplet {}".format(droplet.name)
            continue

        if droplet.status != "active":
            print "Skipping non-active droplet {}".format(droplet.name)
            continue

        print "Deleting expired droplet {}...".format(droplet.name)
        droplet.destroy()
