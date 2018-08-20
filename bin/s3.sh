#!/bin/bash
PROJECT_PATH=/usr/lib/s3
DATA_DIR=$PROJECT_PATH/data
datetime=$(date +%s)
backupFileName=$dirName.$datetime.tar.gz
# Includes
source ${PROJECT_PATH}/*
# s3 -k AKIAIXLRQPF7NBPK3DYA -s RA9K7Hhb+PB78JNt+A9dAZZBbOaBx1giXX/HHS/u -b test-bucket -d /home/$USER/test-own

while getopts "vk:s:d:e:pb:r::l:" optionName; do
    case "$optionName" in
        b)  awsBucket="$OPTARG";;
        v)	verbose="-v";;
        k)	awsAccessKeyId="$OPTARG";;
        s)	awsAccessSecretKey="$OPTARG";;
        d)	directoryToBackup="$OPTARG";;
        r)	vrsion="$OPTARG";;
        l)  location="$OPTARG";;
        h)  echo '-h for help'
            echo '-b for bucket name'
            echo '-v for vorboose mode'
            ;;
        [?])	echo "Option not recognised";;
    esac
done

dirName=$(string="$directoryToBackup" && printf "%s\n" "${string##*/}")

setBackupFile()
{ 
  echo 'Creating Tarball....'
  cd $directoryToBackup/ && cd .. &&
  env GZIP=-9 tar -cvvf $backupFileName $dirName --listed-incremental=$DATA_DIR/data.snar &&
  mv $backupFileName $DATA_DIR/
}
getBackupFile(){
   echo 'getbackup file'
   tar -xzvf $backupFileName.tar.gz &&
   mv $backupFileName $directoryToBackup
}

if [ -d "$directoryToBackup" ]; then
  setBackupFile &&
#   echo $awsAccessSecretKey >> /home/zeeshan/Downloads/rootkey.csv
  $PROJECT_PATH/post.sh -k $awsAccessKeyId -s $awsAccessSecretKey -r $location -T $DATA_DIR/$backupFileName /$awsBucket/$dirName
elif [ -z "$vrsion" ]; then
  getBackupFile &&
  $PROJECT_PATH/get.sh -k $awsAccessKeyId -s $awsAccessSecretKey -r $location /$awsBucket/$dirName
fi