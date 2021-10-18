targetScope = 'resourceGroup'

param location string = 'Switzerland Nort'
param stoName string = 'pdcosto1csn'

resource sto 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: stoName
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'StorageV2'
  location: location
}
