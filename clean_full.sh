#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Variables (adjust if needed)
RESOURCE_GROUP="rg-ws-crud-iac"
ACI_NAME="acigroup-ws"
VNET_NAME="vnet-ws"
NSG_NAME="nsg-ws"
LOG_ANALYTICS_NAME="logs-ws"

# Delete Container Group
echo -e "${RED}==> Deleting Container Group: ${ACI_NAME}${NC}"
az container delete --name ${ACI_NAME} --resource-group ${RESOURCE_GROUP} --yes

# Delete NSG
echo -e "${RED}==> Deleting Network Security Group: ${NSG_NAME}${NC}"
az network nsg delete --name ${NSG_NAME} --resource-group ${RESOURCE_GROUP}

# Delete VNet
echo -e "${RED}==> Deleting Virtual Network: ${VNET_NAME}${NC}"
az network vnet delete --name ${VNET_NAME} --resource-group ${RESOURCE_GROUP}

# Delete Log Analytics Workspace
echo -e "${RED}==> Deleting Log Analytics Workspace: ${LOG_ANALYTICS_NAME}${NC}"
az monitor log-analytics workspace delete --resource-group ${RESOURCE_GROUP} --workspace-name ${LOG_ANALYTICS_NAME} --yes

echo -e "${GREEN}==> Cleanup completed!${NC}"
