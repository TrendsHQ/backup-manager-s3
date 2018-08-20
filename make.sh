#!/usr/bin/env bash
PROJECT_NAME=s3-manager
PROJECT_PATH=$( cd $(dirname $0) ; cd ../; pwd -P )/$PROJECT_NAME
LIB_DIR=/usr/lib/s3

set_env()
{
    local BIN_PATH=/bin/s3 
    if [ ! -d "$LIB_DIR" ]; then
       sudo mkdir /usr/lib/s3 &&
       sudo chown -R $USER:sudo /usr/lib/s3
       mkdir /usr/lib/s3/data
    fi
    if [ ! -e "$BIN_PATH" ]; then
        chmod +x $PROJECT_PATH/bin/s3.sh &&
        sudo ln -s $PROJECT_PATH/bin/s3.sh /bin/s3 &&
        ln -s $PROJECT_PATH/lib/get.sh  /usr/lib/s3/get.sh &&
        ln -s $PROJECT_PATH/lib/post.sh /usr/lib/s3/post.sh &&
        ln -s $PROJECT_PATH/lib/common.sh /usr/lib/s3/common.sh
    fi
}
echo $PROJECT_PATH
set_env &&
which s3