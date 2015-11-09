#!/bin/sh

usage() {
    echo "Usage: $0 -k api_key -s ssh_key_fingerprint -i image_name -r region -t lifespan_in_seconds -u user_data_filename" 1>&2;
    exit 1;
}

while getopts "k:s:i:r:t:u:" o; do
    case "${o}" in
        k)
            API_KEY=${OPTARG}
            ;;
        s)
            SSH_KEY_FINGERPRINT=${OPTARG}
            ;;
        i)
            IMAGE_NAME=${OPTARG}
            ;;
        r)
            REGION=${OPTARG}
            ;;
        t)
            LIFESPAN_IN_SECONDS=${OPTARG}
            ;;
        u)
            USER_DATA_FILENAME=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo "$API_KEY , $SSH_KEY_FINGERPRINT , $IMAGE_NAME , $REGION , $LIFESPAN_IN_SECONDS , $USER_DATA_FILENAME"

if [ -z "${API_KEY}" ] || [ -z "${SSH_KEY_FINGERPRINT}" ] || [ -z "${IMAGE_NAME}" ] \
  || [ -z "${REGION}" ] || [ -z "${LIFESPAN_IN_SECONDS}" ] || [ -z "${USER_DATA_FILENAME}" ]; then
    usage
fi

BUILD_ID=`date +%s`
PIP_DEPENDENCIES="python-digitalocean"
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