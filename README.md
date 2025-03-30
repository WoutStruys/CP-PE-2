# CP-PE-2



Login to Azure

    az login

Press enter for no changes when prompted for a subscription


    Select a subscription and tenant (Type a number or Enter for no changes): 


Create a resource group

    az group create --name rg-ws-crud-iac --location westeurope

Create azure container registry

    az deployment group create --resource-group rg-ws-crud-iac --template-file acr.bicep --parameters acrName=acrwscrud


Login to the Azure Container Registry

    az acr login --name acrwscrud

Show the login server name

    az acr show --name acrwscrud --query loginServer --output table

This is the name of the ACR login server. You will need this to tag your image.

```bash
Result
--------------------
acrwscrud.azurecr.io
```

Check docker images

    docker images

This is the output of the command

```bash
REPOSITORY                TAG         IMAGE ID       CREATED             SIZE
example-flask-crud       latest      9e6f52442326   About an hour ago   169MB
```


Tag the image with the ACR login server name

    docker tag example-flask-crud acrwscrud.azurecr.io/example-flask-crud:v1


Now Push the image to the ACR

    docker push acrwscrud.azurecr.io/example-flask-crud:v1


check the images in the ACR

    az acr repository list --name acrwscrud --output table

Deploy the basic infrastructure




```bash
az deployment group create \
  --resource-group rg-ws-crud-iac \
  --template-file ./infra/basic.bicep \
  --parameters acrUsername=<username> acrPassword=<password>
```

delete everything

    az group delete --name rg-ws-crud-iac --yes



