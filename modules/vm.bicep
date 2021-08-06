@description('Name of the Virtual Machine')
param name string

@description('Name of target region')
param location string = resourceGroup().location

@description('Name of the Network')
param network string

@description('Name of the Subnet')
param subnet string = 'default'

@description('Username to login with SSH')
param adminUser string

@description('Password to login with SSH')
@secure()
param adminPassword string

@description('VM size')
param instanceSize string = 'Standard_B2s'

@description('OS Image')
param imageRef object = {
  publisher: 'canonical'
  offer: '0001-com-ubuntu-server-focal'
  version: 'latest'
  sku: '20_04-lts'
}

// ***** Variables *****************************************************************************************************

var virtualMachineName = '${name}-vm'

var subnetId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${network}/subnets/${subnet}'

// ***** Resources *****************************************************************************************************

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  location: location
  name: virtualMachineName

  properties: {
    networkSecurityGroup: {
        id: securityGroup.id
    }

    ipConfigurations: [
      {
         name: 'ipconfig1'
         properties: {
            subnet: {
              id: subnetId
            }

            publicIPAddress: {
              id: publicIP.id
            }
         }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  location: location
  name: virtualMachineName

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${name}-${substring(uniqueString(resourceGroup().name), 0, 5)}'
    }
  }
}

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  location: location
  name: virtualMachineName

  properties: {
    securityRules: [
      {
        name: 'allow-ssh'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  location: location
  name: virtualMachineName

  properties: {
    hardwareProfile: {
      vmSize: instanceSize
    }

    osProfile: {
      computerName: name
      adminPassword: adminPassword
      adminUsername: adminUser
    }

    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: imageRef
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

// ***** Outputs *******************************************************************************************************

output connectionString string = 'ssh ${adminUser}@${publicIP.properties.dnsSettings.fqdn}'
