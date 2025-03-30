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

@description('ACR username')
param acrUsername string

@description('ACR password')
@secure()
param acrPassword string

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
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
    imageRegistryCredentials: [
      {
        server: 'acrwscrud.azurecr.io'
        username: acrUsername
        password: acrPassword
      }
    ]
  }
}


// Output Public IP address
output publicIpAddress string = containerGroup.properties.ipAddress.ip
