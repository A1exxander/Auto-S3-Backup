#!/bin/bash
# Bash Script to automate backups to S3

if ! command -v aws >/dev/null 2>&1; then # Does not need [] when simply looking at exit code
    echo "AWS CLI not installed locally!"
    exit 1
fi

if [ -z "$(aws configure list)" ]; then
    echo "AWS not configured properly"
    exit 2
fi

CONFIG_FILE="config_file.cfg"

# Check config file exists and is not empty
if [ ! -f "$CONFIG_FILE" -o ! -s "$CONFIG_FILE" ]; then
    echo "Configuration file named $CONFIG_FILE does not exist or is empty"
    exit 3
fi

backup_name="$(date +%Y%m%d_%H%M%S)_BACKUP"
mkdir "$backup_name"

# Read backup paths from config
while IFS= read -r backup_path
do
    if [ -n "$backup_path" ]; then
	cp -r "$backup_path" "$backup_name"    		
    fi
done < "$CONFIG_FILE" # Feeds the input into the while loop

# Create tar of file
tar -czvf "$backup_name.tar.gz" "$backup_name"

# Upload tar to S3 storage
aws s3 cp "$backup_name.tar.gz" "s3://my-backups/$backup_name"

# Cleanup temp files & folders
rm -rf "$backup_name"
rm "$backup_name.tar.gz"
