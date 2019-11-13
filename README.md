# syncme
A simple tool to sync local files to Amazon S3.
This tool also produces a report (stdout) that shows:
- When a file is found on local filer and is identical in s3, this includes the verification of the MD5 eTag/hash of the file between S3 and locally
- A warning when it finds a new file in local filer but not in s3
- A warning when the actual content of a file has discrepancies during the sync process
- A message if a file's checksum validation fails due to file changes or network disruptions.

# prerequisites
Provide your own S3 bucket with the appropriate IAM policies

# Usage

Make sure you are logged in to aws, your ~/.aws/credentials file should have valid creds, if no region has been set the script will default to ap-southeast-2

Syncme does a dependency check so you are aware of what you need to install if running locally and makes sure that there are valid aws credentials being used.

# Running the script locally (MacOs)


There are two arguments needed for running this script: the location of the files you want to sync and the destination s3 bucket

```
./bin/syncme /some/location bucketName
```

# Running the script with docker

If you dont want to deal with dependencies, I have provided a wrapper  that runs Syncme using a lightweight alpine docker image.
Just make sure your host ~/.aws/credentials file has valid creds and run

```
 ./syncDocker.sh /some/location bucketName
```
