┌────────────────────────────────────────────────────────────┐
│                    Azure Resource Group                    │
│                       (rg-crudapp-ws)                      │
│                                                            │
│   ┌────────────────────────────────────────────────────┐   │
│   │                Virtual Network (vnet-ws)           │   │
│   │                Address Space: 10.0.0.0/16          │   │
│   │ ┌──────────────────┐   ┌────────────────────────┐ │   │
│   │ │ Subnet: subnet-ws│   │ Subnet: subnet-appgw-ws│ │   │
│   │ │ 10.0.1.0/24      │   │ 10.0.2.0/24            │ │   │
│   │ │ ┌──────────────┐ │   │ ┌───────────────────┐  │ │   │
│   │ │ │  NSG: nsg-ws │ │   │ │ Application      │  │ │   │
│   │ │ │              │ │   │ │ Gateway (appgw)  │  │ │   │
│   │ │ └──────────────┘ │   │ │ Private IP:      │  │ │   │
│   │ │                  │   │ │ 10.0.2.x         │  │ │   │
│   │ │ ┌──────────────┐  │   │ │ Public IP:      │  │ │   │
│   │ │ │  ACI Group   │  │   │ │ appgw-publicip  │  │ │   │
│   │ │ │ (acigroup-ws)│  │   │ │ Exposes port 80 │  │ │   │
│   │ │ │ Private IP:  │  │   │ └───────────────────┘ │   │
│   │ │ │ 10.0.1.x     │  │   │                      │   │
│   │ │ │ Port: 80     │  │   │                      │   │
│   │ │ └──────────────┘  │   └────────────────────────┘   │
│   │                  │                                 │
│   └──────────────────┘─────────────────────────────────┘
│                                                            │
│   ┌──────────────────────────────┐                         │
│   │ Azure Container Registry     │                         │
│   │ (acrwscrud)                  │                         │
│   │ Stores app image             │                         │
│   └──────────────────────────────┘                         │
│                                                            │
│   ┌──────────────────────────────┐                         │
│   │ Log Analytics Workspace      │                         │
│   │ (logs-ws)                    │                         │
│   │ Collects logs from ACI       │                         │
│   └──────────────────────────────┘                         │
│                                                            │
└────────────────────────────────────────────────────────────┘


                  ┌───────────────────┐
                  │   Internet        │
                  └────────┬──────────┘
                           │
                   [ Public IP of AppGW ]
                           │
                  ┌─────────▼────────┐
                  │ Application GW   │
                  │ Forwards to      │
                  │ ACI Private IP   │
                  └─────────┬────────┘
                            │
                  ┌─────────▼────────┐
                  │  Azure Container │
                  │  Instance (ACI)  │
                  │  Private IP Only │
                  └──────────────────┘





### 🟣 Routing Table

| Source               | Destination              | Protocol | Port | Action  | Notes                                    |
|----------------------|-------------------------|----------|------|---------|------------------------------------------|
| Internet             | Application Gateway     | HTTP     | 80   | Allow   | Public IP (appgw-publicip-ws) receives traffic |
| Application Gateway  | Azure Container Instance| HTTP     | 80   | Allow   | Forwards to ACI private IP via backend pool |
| ACI                  | Internet (Outbound)     | Any      | Any  | Allow   | Allowed by NSG outbound rule             |
| Internet             | ACI (Direct)            | -        | -    | Deny    | No Public IP exposed on ACI              |
| Subnet-ws            | Application Gateway     | -        | -    | Allow   | Internal Azure routing                  |


