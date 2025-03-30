# Azure Container Instance (ACI) + Application Gateway + Log Analytics + VNet - Bicep Template

This Bicep template deploys a secure and scalable Azure infrastructure including:

- Azure Virtual Network (VNet) with subnets
- Azure Container Instance (ACI) running a container from Azure Container Registry (ACR)
- Azure Application Gateway as a reverse proxy with public IP
- Network Security Group (NSG) for traffic control
- Log Analytics Workspace for container monitoring

---

## ✅ Purpose

This setup provides a basic architecture to expose a private Azure Container Instance via an Application Gateway, ensuring network isolation and observability through Log Analytics.

---

## 🧩 Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `name` | Name of the container group | `acigroup-ws` |
| `location` | Location for all resources | `resourceGroup().location` |
| `image` | ACR login server URI for your container | `acrwscrud.azurecr.io/example-flask-crud:v1` |
| `cpuCores` | CPU allocated to container | `1` |
| `memoryInGb` | Memory allocated to container | `2` |
| `vnetName` | Name for the virtual network | `vnet-ws` |
| `subnetName` | Name of the container subnet | `subnet-ws` |
| `appGwSubnetName` | Name of the Application Gateway subnet | `subnet-appgw-ws` |
| `logAnalyticsName` | Name for the Log Analytics workspace | `logs-ws` |
| `acrUsername` | ACR username | (required) |
| `acrPassword` | ACR password (secure) | (required) |

---

## 🏗️ Resources Created

| Resource | Type |
|----------|------|
| Virtual Network | `Microsoft.Network/virtualNetworks` |
| Subnet for ACI | `Microsoft.Network/virtualNetworks/subnets` (delegated) |
| Subnet for Application Gateway | `Microsoft.Network/virtualNetworks/subnets` |
| Network Security Group | `Microsoft.Network/networkSecurityGroups` |
| Public IP for App Gateway | `Microsoft.Network/publicIPAddresses` |
| Application Gateway | `Microsoft.Network/applicationGateways` |
| Container Group (ACI) | `Microsoft.ContainerInstance/containerGroups` |
| Log Analytics Workspace | `Microsoft.OperationalInsights/workspaces` |

---

## ⚙️ Details

### Network
- Container is deployed in a **private subnet**.
- Application Gateway is deployed in a separate subnet with a **public static IP**.
- NSG allows:
    - Inbound HTTP (port 80) traffic.
    - Outbound traffic to the internet.

### Application Gateway
- Acts as a reverse proxy for the container.
- Routes traffic from public IP to the private IP of the ACI.
- Uses backend HTTP settings on port `80`.

### Azure Container Instance
- Pulls image securely from ACR.
- Private IP only (no direct public exposure).
- Logs sent to **Log Analytics**.

### Log Analytics
- Retains logs for **30 days**.
- Connected to ACI diagnostics for monitoring.

---

## 🟣 Output

| Output | Description |
|--------|-------------|
| `publicIpAddress` | The static public IP assigned to the Application Gateway |

---

## ✅ Example CLI deployment

```bash
az deployment group create \
    --resource-group <YourResourceGroup> \
    --template-file ./main.bicep \
    --parameters acrUsername=<acr-user> acrPassword=<acr-password>
```

---

If you want, I can also show you:
1. a **diagram** version (architecture diagram)
2. a **security recommendations** section (good for production)
3. a **mini README** if you prefer it lightweight

Just say *yes*, and I'll continue.