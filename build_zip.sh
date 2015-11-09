#!/bin/sh

PIP_DEPENDENCIES="python-digitalocean"

[ $# -eq 0 ] && { echo "Usage: $0 api_key image_name region user_data_filename"; exit 1; }

BUILD_ID=`date +%s`
API_KEY=$1
IMAGE_NAME=$2
REGION=$3
USER_DATA_FILENAME=$4

TMP_DIR="/tmp/tmp_ld_$BUILD_ID"

mkdir $TMP_DIR
mkdir $TMP_DIR/lambda_digitalocean
cp -r lambda_digitalocean/*.py $TMP_DIR/lambda_digitalocean
cp handler.py $TMP_DIR
pip install --target $TMP_DIR $PIP_DEPENDENCIES

cp $USER_DATA_FILENAME $TMP_DIR

cp templates/config_template.py $TMP_DIR/config.py
sed -i "s#{api_key}#$API_KEY#" $TMP_DIR/config.py
sed -i "s#{image_name}#$IMAGE_NAME#" $TMP_DIR/config.py
sed -i "s#{region}#$REGION#" $TMP_DIR/config.py
sed -i "s#{user_data_filename}#`basename $USER_DATA_FILENAME`#" $TMP_DIR/config.py

ZIPFILE_NAME=`pwd`/"lambda_digitalocean_`date +%s`"

cd $TMP_DIR
zip -r $ZIPFILE_NAME .
cd
rm -r $TMP_DIR

echo "Output: $ZIPFILE_NAME.zip"