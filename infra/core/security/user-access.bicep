
param openaiName string
param searchName string
param documentIntelName string
param storageAccountName string
param containerRegistryName string
param cosmosaccountName string
param principalType string = 'User'
param userPrincipalId string

module openaiAccess '../security/openai-access.bicep' = {
  name: '${deployment().name}-openai-access'
  params: {
    openAiName: openaiName
    principalType: principalType
    principalId: userPrincipalId
  }
}

module containerRegistryAccess '../security/registry-access.bicep' = {
  name: '${deployment().name}-registry-access'
  params: {
    containerRegistryName: containerRegistryName
    principalType: principalType
    principalId: userPrincipalId
  }
}

module searchAccess '../security/search-access.bicep' = {
  name: '${deployment().name}-search-access'
  params: {
    searchName: searchName
    principalType: principalType
    principalId: userPrincipalId
  }
}

module docIntel '../security/docintel-access.bicep' = {
  name: '${deployment().name}-docintel-access'
  params: {
    documentIntelName: documentIntelName
    principalType: principalType
    principalId: userPrincipalId
  }
}

module storage '../security/storage-access.bicep' = {
  name: '${deployment().name}-storage-access'
  params: {
    storageAccountName: storageAccountName
    principalType: principalType
    principalId: userPrincipalId
  }
}

module cosmos '../security/cosmos-access.bicep' = {
  name: '${deployment().name}-cosmos-access'
  params: {
    cosmosaccountName: cosmosaccountName
    principalType: principalType
    principalId: userPrincipalId
  }
}
