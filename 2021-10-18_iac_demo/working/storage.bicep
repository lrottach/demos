param location string = 'Switzerland North'

@description('Name of the Azure storage account')
param accountName string = 'pdcodemosto5csn'

// Storage Account Deployment
resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: accountName
  location: location
  properties: {
    minimumTlsVersion: 'TLS1_2'
  }
  tags: {
    'Creator': 'lrottach@baggenstos.ch'
    'Environment': 'Production'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${storage.name}/default/templates'
}
