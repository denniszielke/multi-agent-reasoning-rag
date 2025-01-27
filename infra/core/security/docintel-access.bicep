param documentIntelName string
param principalId string
param suffix string = uniqueString(resourceGroup().id)

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// Cognitive Services OpenAI User
var openAiUserRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')

resource docintelopenaiuser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: account // Use when specifying a scope that is different than the deployment scope
  name: guid(subscription().id, resourceGroup().id, principalId, openAiUserRole, 'docintel')
  properties: {
    roleDefinitionId: openAiUserRole
    principalType: 'ServicePrincipal'
    principalId: principalId
  }
}

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: documentIntelName
}
