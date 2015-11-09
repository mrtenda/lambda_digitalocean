#!/bin/sh

PIP_DEPENDENCIES="python-digitalocean"

[ $# -eq 0 ] && { echo "Usage: $0 api_key ssh_key_fingerprint image_name region user_data_filename lifespan_in_seconds"; exit 1; }

BUILD_ID=`date +%s`
API_KEY=$1
SSH_KEY_FINGERPRINT=$2
IMAGE_NAME=$3
REGION=$4
USER_DATA_FILENAME=$5
LIFESPAN_IN_SECONDS=$6

TMP_DIR="/tmp/tmp_ld_$BUILD_ID"

mkdir $TMP_DIR
mkdir $TMP_DIR/lambda_digitalocean
cp -r lambda_digitalocean/*.py $TMP_DIR/lambda_digitalocean
cp handler.py $TMP_DIR
pip install --target $TMP_DIR $PIP_DEPENDENCIES

cp $USER_DATA_FILENAME $TMP_DIR

cp templates/config_template.py $TMP_DIR/config.py
sed -i "s#{api_key}#$API_KEY#" $TMP_DIR/config.py
sed -i "s#{ssh_key_fingerprint}#$SSH_KEY_FINGERPRINT#" $TMP_DIR/config.py
sed -i "s#{image_name}#$IMAGE_NAME#" $TMP_DIR/config.py
sed -i "s#{region}#$REGION#" $TMP_DIR/config.py
sed -i "s#{user_data_filename}#`basename $USER_DATA_FILENAME`#" $TMP_DIR/config.py
sed -i "s#{lifespan_in_seconds}#$LIFESPAN_IN_SECONDS#" $TMP_DIR/config.py

ZIPFILE_NAME=`pwd`/"lambda_digitalocean_`date +%s`"

cd $TMP_DIR
zip -r $ZIPFILE_NAME .
cd
rm -r $TMP_DIR

echo "Output: $ZIPFILE_NAME.zip"