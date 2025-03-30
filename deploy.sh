#!/bin/bash

set -e  # stop on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Config
RESOURCE_GROUP="rg-ws-crud-iac"
LOCATION="westeurope"
ACR_NAME="acrwscrud" # randomize to avoid global name conflict
IMAGE_NAME="example-flask-crud"
IMAGE_TAG="v1"


# Parse resource group creation output
parse_rg_output() {
    local output="$1"
    local state=$(echo "$output" | jq -r '.properties.provisioningState // empty')
    local name=$(echo "$output" | jq -r '.name // empty')
    local location=$(echo "$output" | jq -r '.location // empty')

    if [[ "$state" == "Succeeded" ]]; then
        echo -e "${GREEN}==> Resource Group '$name' created successfully in '$location'${NC}"
    else
        echo -e "${RED}==> Failed to create Resource Group. Status: $state${NC}"
        exit 1
    fi
}

# Parse ACR deployment output
parse_acr_output() {
    local output="$1"
    local state=$(echo "$output" | jq -r '.properties.provisioningState // empty')
    local login_server=$(echo "$output" | jq -r '.properties.outputs.loginServer.value // empty')

    if [[ "$state" == "Succeeded" && -n "$login_server" ]]; then
        echo -e "${GREEN}==> ACR Deployment succeeded! Login Server: $login_server${NC}"
    elif [[ "$state" != "Succeeded" ]]; then
        echo -e "${RED}==> ACR Deployment failed! Status: $state${NC}"
        exit 1
    else
        echo -e "${YELLOW}==> Deployment succeeded, but no login server found.${NC}"
        exit 1
    fi
}

# Parse ACR Admin Enable output
parse_acr_admin_output() {
    local output="$1"
    local state=$(echo "$output" | jq -r '.provisioningState // empty')
    local admin_enabled=$(echo "$output" | jq -r '.adminUserEnabled // false')
    local login_server=$(echo "$output" | jq -r '.loginServer // empty')

    if [[ "$state" == "Succeeded" && "$admin_enabled" == "true" ]]; then
        echo -e "${GREEN}==> ACR Admin enabled successfully! Login Server: $login_server${NC}"
    elif [[ "$state" != "Succeeded" ]]; then
        echo -e "${RED}==> Failed to enable ACR Admin! Status: $state${NC}"
        exit 1
    else
        echo -e "${YELLOW}==> Admin is not enabled!${NC}"
        exit 1
    fi
}

# Parse Docker build output
parse_docker_build_output() {
    local output="$1"
    if echo "$output" | grep -q "naming to"; then
        echo -e "${GREEN}==> Docker Image built successfully!${NC}"
    else
        echo -e "${RED}==> Docker Image build failed!${NC}"
        exit 1
    fi
}


# Parse deployment output
parse_deploy_output() {
    local output="$1"
    local ip=$(echo "$output" | jq -r '.properties.outputs.publicIpAddress.value // empty')
    local state=$(echo "$output" | jq -r '.properties.provisioningState // empty')

    if [[ "$state" == "Succeeded" && -n "$ip" ]]; then
        echo -e "${GREEN}==> Deployment succeeded! Public IP: http://$ip${NC}"
    elif [[ "$state" != "Succeeded" ]]; then
        echo -e "${RED}==> Deployment failed! Status: $state${NC}"
        exit 1
    else
        echo -e "${YELLOW}==> Deployment succeeded, but no public IP found.${NC}"
        exit 1
    fi
}

echo -e "${BLUE}==> Checking Azure Login...${NC}"
az account show > /dev/null 2>&1 || az login

echo -e "${BLUE}==> Creating Resource Group...${NC}"
rg_output=$(az group create --name $RESOURCE_GROUP --location $LOCATION)

parse_rg_output "$rg_output"

echo -e "${BLUE}==> Creating ACR...${NC}"
acr_output=$(az deployment group create --resource-group $RESOURCE_GROUP --template-file ./infra/acr.bicep --parameters acrName=$ACR_NAME)

parse_acr_output "$acr_output"

echo -e "${BLUE}==> Enable Admin on ACR...${NC}"
acr_admin_output=$(az acr update -n acrwscrud --admin-enabled true)

parse_acr_admin_output "$acr_admin_output"

echo -e "${BLUE}==> Logging into ACR...${NC}"
az acr login --name $ACR_NAME

echo -e "${BLUE}==> Getting ACR Login Server...${NC}"
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

echo -e "${BLUE}==> Building Docker Image...${NC}"
docker_build_output=$(docker build -t $IMAGE_NAME ./src 2>&1)

parse_docker_build_output "$docker_build_output"

echo -e "${BLUE}==> Tagging Docker Image...${NC}"
docker tag $IMAGE_NAME $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG

echo -e "${BLUE}==> Pushing Docker Image to ACR...${NC}"
docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG

echo -e "${BLUE}==> Retrieving ACR Credentials...${NC}"
ACR_CREDENTIALS=$(az acr credential show -n $ACR_NAME --query "{username:username, password:passwords[0].value}" -o json)
ACR_USERNAME=$(echo $ACR_CREDENTIALS | jq -r '.username')
ACR_PASSWORD=$(echo $ACR_CREDENTIALS | jq -r '.password')

echo -e "${GREEN}ACR Username: $ACR_USERNAME${NC}"
echo -e "${GREEN}ACR Password: $ACR_PASSWORD${NC}"

echo -e "${BLUE}==> Deploying Basis Setup...${NC}"
output=$(az deployment group create \
  --resource-group rg-ws-crud-iac \
  --template-file ./infra/basic.bicep \
  --parameters acrUsername=$ACR_USERNAME acrPassword=$ACR_PASSWORD)

parse_deploy_output "$output"

# echo -e "${BLUE}==> Deploying ACR, VNET, Subnet, Public IP, Log Analytics...${NC}"
# az deployment group create --resource-group $RESOURCE_GROUP --template-file ./infra/main.bicep --parameters acrName=$ACR_NAME

# echo -e "${BLUE}==> Deploying Container Instance + Networking...${NC}"
# az deployment group create \
#   --resource-group $RESOURCE_GROUP \
#   --template-file ./infra/deploy-aci.bicep \
#   --parameters acrName=$ACR_NAME imageName=$IMAGE_NAME imageTag=$IMAGE_TAG