# Assignment 2: Azure Infrastructure-as-Code

## Contents

- [Architecture Diagram](docs/diagram.md)
- [ACR Deployment Documentation](docs/acr.md)
- [Basic Infrastructure Documentation](docs/basic.md)
- [Full Infrastructure Documentation](docs/full.md)
- [Automatic Deployment (Recommended)](#automatic-deployment-recommended)
- [Automatic Cleanup](#automatic-cleanup)
- [Manual Deployment (Step-by-Step)](#manual-deployment-step-by-step)

---

## ✅ Automatic Deployment (Recommended)

To deploy everything automatically, simply execute:

```bash
./deploy.sh
```

### What this script does:
- Logs in to Azure (or checks if you are already logged in)
- Creates the Resource Group
- Deploys the Azure Container Registry (ACR)
- Enables Admin on ACR (for easier development)
- Builds, tags, and pushes the Docker Image to ACR
- Deploys infrastructure using your Bicep templates

> 💡 **Tip**  
> Make sure the script is executable before running it:
> ```bash
> chmod +x deploy.sh
> ```

---

## ✅ Automatic Cleanup

To remove **all resources** (Resource Group and everything inside), run:

```bash
./clean.sh
```

### What this script does:
- Deletes the entire resource group (`rg-ws-crud-iac`)
- Cleans up all Azure resources created during deployment

> 💡 **Tip**  
> Don't forget to make the script executable:
> ```bash
> chmod +x clean.sh
> ```

---

## ✅ Manual Deployment (Step-by-Step)

For those who want full control and understanding of each step:

---

### Prerequisites
Ensure the following are installed:

| Tool            | Purpose                         |
|-----------------|---------------------------------|
| Azure CLI       | For Azure resource management  |
| Docker          | To build and manage containers |
| jq *(optional)* | For JSON parsing in terminal   |
| Azure Subscription | To deploy the infrastructure |

---

### Step 1 - Login to Azure

```bash
az login
```

Follow the prompt to authenticate.

> ✅ **Check:** Verify your account and subscription:
> ```bash
> az account show
> ```

---

### Step 2 - Create Resource Group

```bash
az group create --name rg-ws-crud-iac --location westeurope
```

> ✅ **Check:** Confirm resource group creation:
> ```bash
> az group show --name rg-ws-crud-iac
> ```

---

### Step 3 - Deploy Azure Container Registry (ACR)

```bash
az deployment group create \
    --resource-group rg-ws-crud-iac \
    --template-file ./infra/acr.bicep \
    --parameters acrName=acrwscrud
```

> ⚠ **Note:**  
> `acrName` must be globally unique across Azure.

> ✅ **Check:** Verify ACR deployment:
> ```bash
> az acr show --name acrwscrud
> ```

---

### Step 4 - Enable Admin User on ACR (Recommended for Testing)

```bash
az acr update -n acrwscrud --admin-enabled true
```

---

### Step 5 - Login to ACR

```bash
az acr login --name acrwscrud
```

---

### Step 6 - Get ACR Login Server URL

```bash
az acr show --name acrwscrud --query loginServer --output table
```

Expected output:

```text
Result
------------------------
acrwscrud.azurecr.io
```

---

### Step 7 - Build Docker Image Locally

Ensure you are in the **project root** (where the `src/` folder is located).

```bash
docker build -t example-flask-crud ./src
```

> ✅ **Check:** Confirm the image is built:
> ```bash
> docker images
> ```

---

### Step 8 - Tag Docker Image for ACR

```bash
docker tag example-flask-crud acrwscrud.azurecr.io/example-flask-crud:v1
```

---

### Step 9 - Push Docker Image to ACR

```bash
docker push acrwscrud.azurecr.io/example-flask-crud:v1
```

> ✅ **Check:** List repositories inside your ACR:
> ```bash
> az acr repository list --name acrwscrud --output table
> ```

---

### Step 10 - Retrieve ACR Credentials (for Infrastructure Deployment)

```bash
az acr credential show -n acrwscrud --query "{username:username, password:passwords[0].value}"
```

Save these for the next step.

> ⚠ **Security Tip:**  
> Never commit these credentials into Git or share them.

---

### Step 11 - Deploy Infrastructure

#### Option A - Basic Infrastructure Deployment

```bash
az deployment group create \
    --resource-group rg-ws-crud-iac \
    --template-file ./infra/basic.bicep \
    --parameters acrUsername=<username> acrPassword=<password>
```

#### Option B - Full Infrastructure Deployment

```bash
az deployment group create \
    --resource-group rg-ws-crud-iac \
    --template-file ./infra/full.bicep \
    --parameters acrUsername=<username> acrPassword=<password>
```

> 💡 **Tip:**  
> Replace `<username>` and `<password>` with actual values from **Step 10**.

> ✅ **Check:** Confirm deployment success:
> ```bash
> az deployment group show --resource-group rg-ws-crud-iac
> ```

---

### Optional - Full Cleanup (Manual)

```bash
az group delete --name rg-ws-crud-iac --yes
```

> ⚠ **Warning:**  
> This will **irreversibly delete** all resources inside `rg-ws-crud-iac`.
