param cosmosaccountName string
param principalId string
param principalType string = ''
param suffix string = uniqueString(resourceGroup().id)

// DocumentDB Account Contributor
resource cosmosAccountContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('DocumentDB Account Contributor-${principalType}${principalId}${suffix}')
  scope: account
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '5bd9cd88-fe45-4216-938b-f97437e15450'
    )
    principalId: principalId
    principalType: !empty(principalType) ? principalType : 'ServicePrincipal'
  }
}

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing  = {
  name: cosmosaccountName
}
