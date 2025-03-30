#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

RESOURCE_GROUP="rg-ws-crud-iac"

echo -e "${RED}==> Deleting Resource Group: $RESOURCE_GROUP${NC}"
az group delete --name $RESOURCE_GROUP --yes

echo -e "${GREEN}==> Cleanup initiated!${NC}"
