// Parameters
@description('Name for the container group')
param name string = 'acigroup-ws'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('ACR login server URI')
param image string = 'acrwscrud.azurecr.io/example-flask-crud:v1'

@description('Container CPU')
param cpuCores int = 1

@description('Container Memory')
param memoryInGb int = 2

@description('VNet Name')
param vnetName string = 'vnet-ws'

@description('Subnet Name')
param subnetName string = 'subnet-ws'

@description('Log Analytics Workspace Name')
param logAnalyticsName string = 'logs-ws'

@description('ACR username')
param acrUsername string

@description('ACR password')
@secure()
param acrPassword string

// Log Analytics Workspace
var logAnalyticsSharedKeys = logAnalytics.listKeys()
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'nsg-ws'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Virtual Network + Subnet
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// Container Group (ACI)
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: name
  location: location
  properties: {
    containers: [
      {
        name: name
        properties: {
          image: image
          ports: [
            {
              port: 80
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    imageRegistryCredentials: [
      {
        server: 'acrwscrud.azurecr.io'
        username: acrUsername
        password: acrPassword
      }
    ]
    diagnostics: {
      logAnalytics: {
        workspaceId: logAnalytics.properties.customerId
        workspaceKey: logAnalyticsSharedKeys.primarySharedKey
      }
    }
  }
}

// Output Public IP
output publicIpAddress string = containerGroup.properties.ipAddress.ip
