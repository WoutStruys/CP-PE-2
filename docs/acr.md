# Azure Container Registry (ACR) Deployment - Bicep Template

This Bicep template provisions an **Azure Container Registry (ACR)** in your Azure subscription.

## 📄 What does this template do?

This template will:

- Create an Azure Container Registry (ACR) instance.
- Allow you to configure:
    - A globally unique registry name.
    - The Azure region (location) where the registry will be created.
    - The SKU (tier) of the registry (default is `Basic`).
- Output the login server URL of the created registry for later use.

---

## 🧩 Parameters

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|-------|
| `acrName` | Globally unique name for your ACR | `acr${uniqueString(resourceGroup().id)}` | Automatically generated using the resource group ID if not specified. Must be 5-50 characters. |
| `location` | Azure region for the registry | Same as the resource group's location | You can override this if needed. |
| `acrSku` | Pricing tier of ACR | `Basic` | Allowed values: `Basic`, `Standard`, `Premium` |

---

## 🏗️ Resources Deployed

| Resource | Resource Type |
|----------|---------------|
| Azure Container Registry | `Microsoft.ContainerRegistry/registries@2023-01-01-preview` |

The registry will have:
- Admin user **disabled** by default for improved security.

---

## 💡 Output

| Output | Description |
|--------|-------------|
| `loginServer` | The login server URL (e.g., `myregistry.azurecr.io`) to use for Docker or other container tools |

---

## ✅ Example usage (CLI)

```bash
az deployment group create \
  --resource-group <YourResourceGroup> \
  --template-file ./main.bicep
```

---

Do you want me also to show you a short version or a more production-style version? Some teams prefer a more minimal or professional format depending on where you are going to use it. Just say *yes* if you want it.