storage_account_name=$(echo $upload_url | awk -F'[/.]' '{print $3}')
storage_endpoint=$(echo $upload_url | awk -F'/' '{print "https://" $3}')
share_name=$(echo $upload_url | awk -F'/' '{print $4}')
folder=$(echo $upload_url | awk -F'?' '{print $1}' | awk -F'/' '{for(i=5;i<NF-1;i++) printf "%s/",$i; print $(NF-1)}')
path=$(echo $upload_url | awk -F'[/?]' '{print $(NF-1)}')
sas_token=$(echo $upload_url | awk -F'?' '{print $2}')

# Download binary
mkdir resources
echo "Downloading binary from $source_url"
if [ "$auth_header" == "no-auth" ]; then
    curl "$source_url" -o $path
else
    curl -H "Authorization: $auth_header" "$source_url" -o $path
fi

# Upload to remote
echo "Upload $source_url to $storage_account_name at $storage_endpoint/$share_name/$folder/$path"

echo "az storage file upload -s $share_name --source $path --account-name  $storage_account_name --file-endpoint $storage_endpoint --sas-token $sas_token -p $folder"

az storage file upload -s $share_name --source $path --account-name  $storage_account_name --file-endpoint "$storage_endpoint" --sas-token "$sas_token"  -p "$folder"