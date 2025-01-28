param identityName string
param location string = resourceGroup().location
param containerAppsEnvironmentName string
param imageName string

@description('The tags to be assigned to the created resources.')
param tags object  = {}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

param containerRegistryName string
param kmServiceName string = 'km-service'

@description('The name of the application insights resource create in another module.')
param applicationInsightsName string

param AzureBlobs_Account string
param AzureBlobs_Container string
param AzureQueues_Account string
param AzureQueues_QueueName string
param AzureAISearch_Endpoint string
param AzureOpenAIText_Endpoint string
param AzureOpenAIText_Deployment string
param AzureOpenAIEmbedding_Endpoint string
param AzureOpenAIEmbedding_Deployment string
param AzureAIDocIntel_Endpoint string

param KernelMemory__ServiceAuthorization__AccessKey1 string = '${uniqueString(resourceGroup().id)}-${kmServiceName}-${uniqueString(resourceGroup().id)}'
param KernelMemory__ServiceAuthorization__AccessKey2 string = '${uniqueString(resourceGroup().id)}-${kmServiceName}-${uniqueString(resourceGroup().id)}'

//////// Previously created resources

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

////////

resource kmService 'Microsoft.App/containerApps@2023-05-01' = {
  name: kmServiceName
  location: location
  tags: tags
  properties: {
    environmentId: containerAppsEnvironment.id
    configuration: {
      secrets: [
        {
          name: 'appinsights-key'
          value: applicationInsights.properties.InstrumentationKey
        }
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          identity: userIdentity.id
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        transport: 'Auto'
        allowInsecure: false
        targetPort: 9001
        stickySessions: {
          affinity: 'none'
        }
        // additionalPortMappings: []
        
      }
    }

    template: {
      containers: [
        {
          name: 'kernelmemory-service'
          image: imageName
          command: []
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Production'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsights.properties.ConnectionString
            }

            {
              name: 'AZURE_CLIENT_ID'
              value: userIdentity.properties.clientId
            }
            {
              name: 'KernelMemory__Service__OpenApiEnabled'
              value: 'true'
            }
            {
              name: 'KernelMemory__DocumentStorageType'
              value: 'AzureBlobs'
            }
            {
              name: 'KernelMemory__TextGeneratorType'
              value: 'AzureOpenAIText'
            }
            {
              name: 'KernelMemory__DefaultIndexName'
              value: 'default'
            }
            {
              name: 'KernelMemory__ServiceAuthorization__Enabled'
              value: 'true'
            }
            {
              name: 'KernelMemory__ServiceAuthorization__AuthenticationType'
              value: 'APIKey'
            }
            {
              name: 'KernelMemory__ServiceAuthorization__HttpHeaderName'
              value: 'Authorization'
            }
            {
              name: 'KernelMemory__ServiceAuthorization__AccessKey1'
              value: KernelMemory__ServiceAuthorization__AccessKey1
            }
            {
              name: 'KernelMemory__ServiceAuthorization__AccessKey2'
              value: KernelMemory__ServiceAuthorization__AccessKey2
            }
            {
              name: 'KernelMemory__DataIngestion__DistributedOrchestration__QueueType'
              value: 'AzureQueues'
            }
            {
              name: 'KernelMemory__DataIngestion__EmbeddingGeneratorTypes__0'
              value: 'AzureOpenAIEmbedding'
            }
            {
              name: 'KernelMemory__DataIngestion__MemoryDbTypes__0'
              value: 'AzureAISearch'
            }
            {
              name: 'KernelMemory__DataIngestion__ImageOcrType'
              value: 'AzureAIDocIntel'
            }
            {
              name: 'KernelMemory__Retrieval__EmbeddingGeneratorType'
              value: 'AzureOpenAIEmbedding'
            }
            {
              name: 'KernelMemory__Retrieval__MemoryDbType'
              value: 'AzureAISearch'
            }
            {
              name: 'KernelMemory__Services__AzureBlobs__Account'
              value: AzureBlobs_Account
            }
            {
              name: 'KernelMemory__Services__AzureBlobs__Container'
              value: AzureBlobs_Container
            }
            {
              name: 'KernelMemory__Services__AzureQueues__Account'
              value: AzureQueues_Account
            }
            {
              name: 'KernelMemory__Services__AzureQueues__QueueName'
              value: AzureQueues_QueueName
            }
            {
              name: 'KernelMemory__Services__AzureAISearch__Endpoint'
              value: AzureAISearch_Endpoint
            }
            {
              name: 'KernelMemory__Services__AzureAISearch__UseHybridSearch'
              value: 'true'
            }
            {
              name: 'KernelMemory__Services__AzureOpenAIText__Endpoint'
              value: AzureOpenAIText_Endpoint
            }
            {
              name: 'KernelMemory__Services__AzureOpenAIText__Deployment'
              value: AzureOpenAIText_Deployment
            }
            {
              name: 'KernelMemory__Services__AzureOpenAIEmbedding__Endpoint'
              value: AzureOpenAIEmbedding_Endpoint
            }
            {
              name: 'KernelMemory__Services__AzureOpenAIEmbedding__Deployment'
              value: AzureOpenAIEmbedding_Deployment
            }
            {
              name: 'KernelMemory__Services__AzureAIDocIntel__Auth'
              value: 'AzureIdentity'
            }
            {
              name: 'KernelMemory__Services__AzureAIDocIntel__Endpoint'
              value: AzureAIDocIntel_Endpoint
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}

output kmServiceName string = kmService.name
output kmServiceId string = kmService.id
output kmServiceAccessKey1 string = KernelMemory__ServiceAuthorization__AccessKey1
output kmServiceAccessKey2 string = KernelMemory__ServiceAuthorization__AccessKey2
@description('The FQDN of the frontend web app service.')
output kmServiceFQDN string = kmService.properties.configuration.ingress.fqdn
