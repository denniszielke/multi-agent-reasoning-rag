param storageAccountName string
param principalId string
param principalType string = ''
param suffix string = uniqueString(resourceGroup().id)

// Storage Queue Data Contributor
resource storagequeuedatacontributorassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('Storage Queue Data Contributor-${principalType}${principalId}${suffix}')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
    )
    principalId: principalId
    principalType: !empty(principalType) ? principalType : 'ServicePrincipal'
  }
}

// Storage Blob Data Contributor
resource storageblobdatacontributorassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('Storage Blob Data Contributor-${principalType}${principalId}${suffix}')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    )
    principalId: principalId
    principalType: !empty(principalType) ? principalType : 'ServicePrincipal'
  }
}

// Storage Blob Data Owner
resource storageblobdataownerassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('Storage Blob Data Owner-${principalType}${principalId}${suffix}')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
    )
    principalId: principalId
    principalType: !empty(principalType) ? principalType : 'ServicePrincipal'
  }
}

// Storage Queue Data Message Sender
resource storagequeuedatasenderassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('Storage Queue Data Message Sender-${principalType}${principalId}${suffix}')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
    )
    principalId: principalId
    principalType: !empty(principalType) ? principalType : 'ServicePrincipal'
  }
}

// Storage Queue Data Message Processor
resource storagedataqueueprocessorassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('Storage Queue Data Message Processor-${principalType}${principalId}${suffix}')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '8a0f0c08-91a1-4084-bc3d-661d67233fed'
    )
    principalId: principalId
    principalType: !empty(principalType) ? principalType : 'ServicePrincipal'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01'existing  = {
  name: storageAccountName
}
