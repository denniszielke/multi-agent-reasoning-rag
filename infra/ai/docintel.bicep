param name string
param location string = resourceGroup().location
param tags object = {}
param kind string = 'FormRecognizer'

@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'
param sku object = {
  name: 'S0'
}

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: true
  }
  sku: sku
}

output accountName string = account.name
output endpoint string = account.properties.endpoint
