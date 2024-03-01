TF_ORGANIZATION=$1
TERRAFORM_REGISTRY_TOKEN=$2
WORKING_DIRECTORY=$3

###
#Loop through folder structure and iterate over each module
#For each module, check for existing module reference. If no module reference is found create new empty module.
#Once the module reference has been created, create a tarball of module content and push to Terraform Registry.
###

for dir in $WORKING_DIRECTORY/modules/*
do
    cd $dir
    current_folder=$(basename "$dir")

    echo "Creating module reference for $current_folder"
    curl  --header "Authorization: Bearer $TERRAFORM_REGISTRY_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @module.json  https://app.terraform.io/api/v2/organizations/$TF_ORGANIZATION/registry-modules | jq -r
    echo "Module reference created for $current_folder"

    echo "Creating tarball for $current_folder module"
    tar cvfz $current_folder.tar.gz content/*
    echo "Tarball created for $current_folder module"

    echo "Pushing tarball to Terraform Registry for $current_folder module"
    export version_url="https://app.terraform.io/api/v2/organizations/$TF_ORGANIZATION/registry-modules/private/$TF_ORGANIZATION/$current_folder/azurerm/versions"
    export push_url=$(curl --location {$version_url} --header 'Content-Type: application/vnd.api+json' --header "Authorization: Bearer $TERRAFORM_REGISTRY_TOKEN" --data @content/version.json | jq -r '.data.links.upload')
    curl --location $push_url --request PUT  --header 'Content-Type: application/octet-stream'  --data-binary @$current_folder.tar.gz
    echo "Tarball pushed to Terraform Registry for $current_folder module"
done