param searchName string
param principalId string
param principalType string = ''
param suffix string = uniqueString(resourceGroup().id)

// Search Index Data Contributor
resource searchindexdatacontributorassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('Search Index Data Contributor-${principalType}${principalId}${suffix}')
  scope: search
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
    )
    principalId: principalId
    principalType: !empty(principalType) ? principalType : 'ServicePrincipal'
  }
}

// Search Service Contributor
resource searchcontributorassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('Search Service Contributor-${principalType}${principalId}${suffix}')
  scope: search
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
    )
    principalId: principalId
    principalType: !empty(principalType) ? principalType : 'ServicePrincipal'
  }
}

resource search 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: searchName
}
