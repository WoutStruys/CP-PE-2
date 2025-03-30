# Assignment 2: Azure Infrastructure-as-Code

# Inhoud

- [Diagram](#diagram)
- [Automatic Deployment](#automatic-deployment-recommended)
- [Automatic Cleanup](#automatic-cleanup)
- [Manual Deployment (Step by Step)](#manual-deployment-step-by-step)


## Diagram

### [📄 View the Architecture Diagram](./diagram.md)

## Automatic Deployment (Recommended)

If you want to deploy everything automatically, just run:

```bash
bash deploy.sh
```

This script will:

- Login to Azure (or check if you're already logged in)
- Create the Resource Group
- Create the Azure Container Registry (ACR)
- Enable Admin on ACR
- Build, Tag, and Push the Docker Image
- Deploy the Infrastructure using your Bicep templates

> **Tip:** Make sure `deploy.sh` is executable:
> ```bash
> chmod +x deploy.sh
> ```

---

## Automatic Cleanup

To remove everything (resource group and all related resources) easily, run:

```bash
bash clean.sh
```

This script will:

- Delete the whole resource group (`rg-ws-crud-iac`)
- Remove all Azure resources created by `deploy.sh`

> **Tip:** Make sure `clean.sh` is executable:
> ```bash
> chmod +x clean.sh
> ```

---

## Manual Deployment (Step by Step)

If you prefer to deploy step by step, follow the instructions below:

## Prerequisites
Make sure you have the following installed and configured:

- Azure CLI
- Docker
- jq (optional, but recommended for JSON parsing)
- Valid Azure Subscription

---

## Step 1 - Login to Azure

```bash
az login
```

Follow the prompt and select your subscription.

---

## Step 2 - Create Resource Group

```bash
az group create --name rg-ws-crud-iac --location westeurope
```

---

## Step 3 - Deploy Azure Container Registry (ACR)

```bash
az deployment group create \
    --resource-group rg-ws-crud-iac \
    --template-file ./infra/acr.bicep \
    --parameters acrName=acrwscrud
```

---

## Step 4 - Enable Admin on ACR (Optional but recommended)

```bash
az acr update -n acrwscrud --admin-enabled true
```

---

## Step 5 - Login to ACR

```bash
az acr login --name acrwscrud
```

---

## Step 6 - Get ACR Login Server

```bash
az acr show --name acrwscrud --query loginServer --output table
```

You will get output like:

```text
Result
------------------------
acrwscrud.azurecr.io
```

---

## Step 7 - Build Docker Image Locally

Make sure you are in the project root directory where the `src/` folder is located.

```bash
docker build -t example-flask-crud ./src
```

Check if the image is built:

```bash
docker images
```

Example output:

```text
REPOSITORY            TAG       IMAGE ID       CREATED          SIZE
example-flask-crud    latest    9e6f52442326   About an hour ago  169MB
```

---

## Step 8 - Tag the Docker Image for ACR

```bash
docker tag example-flask-crud acrwscrud.azurecr.io/example-flask-crud:v1
```

---

## Step 9 - Push the Image to ACR

```bash
docker push acrwscrud.azurecr.io/example-flask-crud:v1
```

---

## Step 10 - Verify Image in ACR

```bash
az acr repository list --name acrwscrud --output table
```

---

## Step 11 - Retrieve ACR Credentials (needed for deployment)

```bash
az acr credential show -n acrwscrud --query "{username:username, password:passwords[0].value}"
```

---

## Step 12 - Deploy the Basic Infrastructure

Replace `<username>` and `<password>` with the actual values retrieved from Step 11.

```bash
az deployment group create \
    --resource-group rg-ws-crud-iac \
    --template-file ./infra/basic.bicep \
    --parameters acrUsername=<username> acrPassword=<password>
```

---

## Optional - Clean up (Delete Everything)

```bash
az group delete --name rg-ws-crud-iac --yes
```

---

Would you like me also to make it even more professional with:
1. ✅ Command explanations inline  
2. ✅ Optional validation commands between steps  
3. ✅ Tip boxes (like best practices, common errors, etc.)  

It could make it perfect for sharing with your team or future you. Just say *yes*, and I’ll polish it more!