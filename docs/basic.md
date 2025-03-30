# Azure Container Instance (ACI) Deployment - Bicep Template

This Bicep template deploys an **Azure Container Instance (ACI)** that pulls a container image from an Azure Container Registry (ACR) and exposes it publicly.

---

## 📄 What does this template do?

This template will:

- Create an Azure Container Instance (ACI).
- Deploy a container based on a specified image from an Azure Container Registry (ACR).
- Expose the container on **port 80** to the internet with a public IP.
- Allow you to configure CPU, memory, and ACR credentials.

---

## 🧩 Parameters

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|-------|
| `name` | Name for the container group | `acigroup-ws` | Can be customized. |
| `location` | Deployment location | Resource group's location | You may override it. |
| `image` | Full image URI (including tag) | `acrwscrud.azurecr.io/example-flask-crud:v1` | Must be a valid ACR-hosted image. |
| `cpuCores` | Number of CPU cores | `1` | Minimum `1`. |
| `memoryInGb` | Amount of memory (GB) | `2` | Minimum `1`. |
| `acrUsername` | ACR username | (no default) | Required for pulling private images. |
| `acrPassword` | ACR password | (no default, secure) | Required for pulling private images. |

---

## 🏗️ Resources Deployed

| Resource | Type |
|----------|------|
| Azure Container Group | `Microsoft.ContainerInstance/containerGroups@2023-05-01` |

---

## ⚙️ Container Configuration

- Runs on **Linux**.
- Image is pulled securely from ACR using provided credentials.
- Container exposes **port 80**.
- `restartPolicy` is set to `Always`.
- Public IP will be automatically assigned.

---

## 💡 Output

| Output | Description |
|--------|-------------|
| `publicIpAddress` | The public IP address where your container is reachable on port 80 |

---

## ✅ Example usage (CLI)

```bash
az deployment group create \
  --resource-group <YourResourceGroup> \
  --template-file ./container.bicep \
  --parameters acrUsername=<acr-user> acrPassword=<acr-password>
```

---

If you want, I can also show you:
- a production-grade README (with security notes, tips, and recommendations)
- or a minimalist version

Just say *yes* if you want me to extend it.