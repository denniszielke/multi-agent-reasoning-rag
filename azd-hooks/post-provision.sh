#!/bin/bash
echo  "Deployed environment $AZURE_ENV_NAME successfully."

RESOURCE_GROUP="rg-$AZURE_ENV_NAME"
COSMOSDB_NAME=$(az cosmosdb list --resource-group ${RESOURCE_GROUP} --query "[0].name" -o tsv)
PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)

IDENTITY_NAME=$(az resource list -g $RESOURCE_GROUP --resource-type "Microsoft.ManagedIdentity/userAssignedIdentities" --query "[0].name" -o tsv)

az cosmosdb sql role assignment create \
        --account-name "${COSMOSDB_NAME}" \
        --resource-group "${RESOURCE_GROUP}" \
        --role-definition-id "00000000-0000-0000-0000-000000000002" \
        --scope /"/" \
        --principal-id "${PRINCIPAL_ID}" 

UMI_PRINCIPAL=$(az identity show --resource-group $RESOURCE_GROUP --name $IDENTITY_NAME --query principalId --output tsv)

az cosmosdb sql role assignment create \
        --account-name "${COSMOSDB_NAME}" \
        --resource-group "${RESOURCE_GROUP}" \
        --role-definition-id "00000000-0000-0000-0000-000000000002" \
        --scope /"/" \
        --principal-id "${UMI_PRINCIPAL}" 