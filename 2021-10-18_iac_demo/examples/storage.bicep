targetScope = 'resourceGroup'

@description('Deployment Location')
param location string = 'Switzerland North'

param accountName string = 'pdcosto1csn'

// Storage Account deployment
resource sto 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: accountName
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'StorageV2'
  location: location
  properties: {
    minimumTlsVersion: 'TLS1_2'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${sto.name}/default/templates'
  properties: {
    publicAccess: 'None'
  }
}
