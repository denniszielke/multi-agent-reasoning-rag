#!/bin/bash

set -e

AZURE_ENV_NAME="$1"

if [ "$AZURE_ENV_NAME" == "" ]; then
echo "No environment name provided - aborting"
exit 0;
fi

SERVICE_NAME="km-service"

RESOURCE_GROUP="rg-$AZURE_ENV_NAME"

if [ $(az group exists --name $RESOURCE_GROUP) = false ]; then
    echo "resource group $RESOURCE_GROUP does not exist"
    error=1
else   
    echo "resource group $RESOURCE_GROUP already exists"
    LOCATION=$(az group show -n $RESOURCE_GROUP --query location -o tsv)
fi

APPINSIGHTS_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.Insights/components" --query "[0].name" -o tsv)
AZURE_CONTAINER_REGISTRY_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.ContainerRegistry/registries" --query "[0].name" -o tsv)
OPENAI_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.CognitiveServices/accounts" --query "[0].name" -o tsv)
DOC_INTEL_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.CognitiveServices/accounts" --query "[1].name" -o tsv)
ENVIRONMENT_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.App/managedEnvironments" --query "[0].name" -o tsv)
IDENTITY_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.ManagedIdentity/userAssignedIdentities" --query "[0].name" -o tsv)
SEARCH_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.Search/searchServices" --query "[0].name" -o tsv)
COSMOSDB_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.DocumentDB/databaseAccounts" --query "[0].name" -o tsv)
STORAGE_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.Storage/storageAccounts" --query "[0].name" -o tsv)
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

SEARCH_ENDPOINT=$(echo "https://$SEARCH_NAME.search.windows.net")
OPENAI_ENDPOINT=$(az cognitiveservices account show -n $OPENAI_NAME -g $RESOURCE_GROUP --query properties.endpoint -o tsv)
DOC_INTEL_ENDPOINT=$(az cognitiveservices account show -n $DOC_INTEL_NAME -g $RESOURCE_GROUP --query properties.endpoint -o tsv)
AI_TEXT_DEPLOYMENT="gpt-4o"
AI_EMBEDDING_DEPLOYMENT="text-embedding-ada-002"

echo "container registry name: $AZURE_CONTAINER_REGISTRY_NAME"
echo "application insights name: $APPINSIGHTS_NAME"
echo "openai name: $OPENAI_NAME"
echo "doci name: $DOC_INTEL_NAME"
echo "cosmosdb name: $COSMOSDB_NAME"
echo "search name: $SEARCH_NAME"
echo "identity name: $IDENTITY_NAME"
echo "storage name: $STORAGE_NAME"
echo "search endpoint: $SEARCH_ENDPOINT"
echo "openai endpoint: $OPENAI_ENDPOINT"
echo "doc intel endpoint: $DOC_INTEL_ENDPOINT"
echo "ai text deployment: $AI_TEXT_DEPLOYMENT"
echo "ai embedding deployment: $AI_EMBEDDING_DEPLOYMENT"


CONTAINER_APP_EXISTS=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.App/containerApps" --query "[?contains(name, '$SERVICE_NAME')].id" -o tsv)
EXISTS="false"

if [ "$CONTAINER_APP_EXISTS" == "" ]; then
    echo "container app $SERVICE_NAME does not exist"
else
    echo "container app $SERVICE_NAME already exists"
    EXISTS="true"
fi

IMAGE_TAG=$(date '+%m%d%H%M%S')

#az acr import -n $AZURE_CONTAINER_REGISTRY_NAME --source  docker.io/library/kernelmemory/service
#docker tag kernelmemory/service "${AZURE_CONTAINER_REGISTRY_NAME}.azurecr.io/kernelmemory/service"
IMAGE_NAME="${AZURE_CONTAINER_REGISTRY_NAME}.azurecr.io/kernelmemory/service"

echo "deploying image: $IMAGE_NAME"

az deployment group create -g $RESOURCE_GROUP -f ./infra/app/kernelservice.bicep \
          -p kmServiceName=$SERVICE_NAME -p location=$LOCATION -p containerAppsEnvironmentName=$ENVIRONMENT_NAME \
          -p containerRegistryName=$AZURE_CONTAINER_REGISTRY_NAME -p applicationInsightsName=$APPINSIGHTS_NAME \
          -p AzureBlobs_Account=$STORAGE_NAME -p AzureBlobs_Container="documents" -p AzureQueues_Account=$STORAGE_NAME -p AzureQueues_QueueName="requests" \
          -p AzureAISearch_Endpoint=$SEARCH_ENDPOINT -p AzureOpenAIText_Endpoint=$OPENAI_ENDPOINT -p AzureOpenAIText_Deployment=$AI_TEXT_DEPLOYMENT \
          -p AzureOpenAIEmbedding_Endpoint=$OPENAI_ENDPOINT -p AzureOpenAIEmbedding_Deployment=$AI_EMBEDDING_DEPLOYMENT \
          -p AzureAIDocIntel_Endpoint=$DOC_INTEL_ENDPOINT \
          -p identityName=$IDENTITY_NAME -p imageName=$IMAGE_NAME
