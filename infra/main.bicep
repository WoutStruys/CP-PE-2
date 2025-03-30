@description('Name for the container group')
param name string = 'acigroup-ws'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('ACR login server URI')
param image string = 'acrwscrud.azurecr.io/example-flask-crud:v1'

@description('VNet name')
param vnetName string = 'aci-vnet-ws'

@description('Subnet name')
param subnetName string = 'aci-subnet-ws'

@description('Container CPU')
param cpuCores int = 1

@description('Container Memory')
param memoryInGb int = 2

// NSG allowing HTTP
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: '${name}-nsg'
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

// VNet + Subnet + NSG
resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// Public IP for Load Balancer
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: '${name}-pip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Load Balancer (base)
resource lb 'Microsoft.Network/loadBalancers@2023-02-01' = {
  name: '${name}-lb'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

// Backend Pool (child of LB)
resource backendPool 'Microsoft.Network/loadBalancers/backendAddressPools@2023-02-01' = {
  parent: lb
  name: 'BackendPool'
}

// Health Probe (child of LB)
resource probe 'Microsoft.Network/loadBalancers/probes@2023-02-01' = {
  parent: lb
  name: 'httpProbe'
  properties: {
    protocol: 'Http'
    port: 80
    requestPath: '/'
    intervalInSeconds: 5
    numberOfProbes: 2
  }
}

// Load Balancing Rule (child of LB)
resource lbRule 'Microsoft.Network/loadBalancers/loadBalancingRules@2023-02-01' = {
  parent: lb
  name: 'HTTPRule'
  properties: {
    frontendIPConfiguration: {
      id: lb.properties.frontendIPConfigurations[0].id
    }
    backendAddressPool: {
      id: backendPool.id
    }
    probe: {
      id: probe.id
    }
    protocol: 'Tcp'
    frontendPort: 80
    backendPort: 80
    enableFloatingIP: false
    idleTimeoutInMinutes: 4
    loadDistribution: 'Default'
  }
}

// Container Group (inside VNet with private IP)
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
          environmentVariables: []
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    subnetIds: [
      {
        id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
      }
    ]
    ipAddress: {
      type: 'Private'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
  }
}

// Register ACI's private IP in the Backend Pool
resource backendAddress 'Microsoft.Network/loadBalancers/backendAddressPools/backendAddresses@2023-02-01' = {
  parent: backendPool
  name: 'aci-backend'
  properties: {
    ipAddress: containerGroup.properties.ipAddress.ip
  }
}

output publicIpAddress string = publicIP.properties.ipAddress
output containerPrivateIP string = containerGroup.properties.ipAddress.ip
