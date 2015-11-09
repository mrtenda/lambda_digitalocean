# lambda_digitalocean

This is code for an AWS Lambda function to start a worker in DigitalOcean. When the Lambda function is run with this code, it'll start up a new DigitalOcean droplet worker using the specified droplet image. Also included is another Lambda function for deleting the Droplet workers after they've completed their job.

## Why?

You may want to perform an asynchronous task as the result of a Lambda trigger, but the task is too complex to run in AWS Lambda itself. AWS Lambda environments are pretty barebones and don't have some dependencies your job might need. For example (at the time of this writing), neither Git nor Ruby are installed on the AWS Lambda environment by default. To get around this, instead of trying to get AWS Lambda to perform the work itself, you could instead have AWS Lambda start up a VPS that actually does all the work.

# How to use

First, set up the function that will be starting up new workers. This Lambda function will create a new droplet in DigitalOcean using the image and other parameters provided. Your image should be configured so that your droplet performs whatever work you want it to do after it boots.

To set up this function:

1. Generate the ZIP to upload to AWS Lambda:

        git checkout lambda_digitalocean
        cd lambda_digitalocean
        ./build_zip.sh \
          -k your_digitalocean_api_key \
          -s "your_digitalocean_ssh_key_fingerprint" \
          -i your_digitalocean_image_name \
          -r region_name \
          -t maximum_time_for_your_job_to_run_before_its_killed \
          -u /path/to/file/with/your/user/data.txt

2. Create a new AWS Lambda function in the AWS Console. When you're asked to enter your code to run, upload the ZIP generated in the pervious step. Also use the following settings:
   - **Runtime**: `Python 2.7`
   - **Handler**: `handler.create`
   - **Timeout**: `10s` (should be way more than sufficient)

3. Configure what the event sources, API endpoints, etc. for your function to be triggered.

You'll also want to set up another AWS Lambda function to delete workers that have exceeded the maximum time for them to run before they're killed. To do so:

1. Create a new AWS Lambda function in the AWS Console. When you're asked to enter your code to run, upload the ZIP generated in the previous section. Also use the following settings:
   - **Runtime**: `Python 2.7`
   - **Handler**: `handler.cleanup`
   - **Timeout**: `10s` (should be way more than sufficient)
2. Navigate to the Event Sources tab of your Lambda function, and create a new event source with the following settings:
   - **Event source type**: `Scheduled event`
   - **Schedule expression****: `cron(0/15 * ? * * *)` (this will trigger a cleanup every 15 minutes, modify as needed)
   - **Enable now**
