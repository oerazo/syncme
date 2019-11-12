# syncme
A simple tool to sync local files to Amazon S3


# Usage

Make sure you are logged in to aws, your ~/.aws/credentials file should have valid creds, if no region has been set the script will default to ap-southeast-2

There are two arguments needed for running this script: the location of your local filer and the destination s3 bucket that contains the data you want to sync to amazon s3

```
./bin/syncme /local/filer bucketName
```
