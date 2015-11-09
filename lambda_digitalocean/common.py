import uuid
import digitalocean

DROPLET_NAME_PREFIX = "lambdatmp-"


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


def create_temporary_droplet(api_key, image_id, region, user_data):
    droplet_name = DROPLET_NAME_PREFIX + "{}".format(uuid.uuid4().hex[0:8])
    print "Creating temporary droplet {}...".format(droplet_name)
    droplet = digitalocean.Droplet(
        token=api_key,
        name=droplet_name,
        region=region,
        image=image_id,
        size_slug='512mb',
        backups=False,
        user_data=user_data
    )
    droplet.create()
    print "Created."


def delete_droplets(api_key, filter_function):
    manager = digitalocean.Manager(token=api_key)

    droplets = [x for x in manager.get_all_droplets() if filter_function(x)]
    for droplet in droplets:
        if droplet.status == "active":
            print "Deleting droplet {}...".format(droplet.name)
            droplet.destroy()


def delete_temporary_droplets(api_key):
    delete_droplets(api_key=api_key, filter_function=(lambda x: x.name.startswith(DROPLET_NAME_PREFIX)))