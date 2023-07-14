This module will call the `getUploadResourceUrl` for a given resource. The resource could be a `Microsoft.AppPlatform/Spring/Apps` in Standard or Basic tier. Or it can be `Microsoft.AppPlatform/Spring/BuildServices` resource.
After getting the `getUploadResourceUrl`, it upload the local_path jar file to the remote resource.

## TODO
- Terraform deployment resource cannot modify `relative_path`.
- Azure CLI cannot upload file with an `upload_url`. This will be released in August.