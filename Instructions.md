# How to use
This Porject uploads the Files to s3 and rollback those files

  - go to project dir
  - make make.sh file executable
  - execute make.sh file in bash
## Start
```bash
 sudo chmod +x make.sh &&
 ./make.sh
```
## Use
```bash  
# to upload
s3 -k KeyId -s SecretKeyfilePath -b bucket-name -d directory name -l server-region
```
```bash  
# to download
s3 -k KeyId -s SecretKeyfilePath -b bucket-name -r 1.0 -l server-region
```