#!/bin/sh

echo "Azure Resource Graph queries";

# Login to Azure using Service principal
az login --service-principal --username $service_principal_username --password $service_principal_password --tenant $service_principal_tenant

# Install Resource Graph Plugin
az extension add --name resource-graph

##################
# Summary
##################

# Subscription Queries
az account list

# Total number of resources
az graph query -q 'count' 

# Total number of resources by type
az graph query -q 'summarize count() by type | order by type' 

# Total number of resources by subscriptionId
az graph query -q 'summarize count() by subscriptionId | order by subscriptionId'

# Total number of resources by location
az graph query -q 'summarize count() by location | order by location'

# Least used resource location
az graph query -q 'summarize count() by location | top 5 by count_ asc'

# Count of specific resource type across subscriptions
az graph query -q 'where type == "microsoft.storage/storageaccounts" | count' 

##################
# Storage Accounts
##################

# Storage accounts exposed to internet
az graph query -q "where type == 'microsoft.storage/storageaccounts' | where properties.networkAcls.defaultAction != 'Deny' | count" 

# Storage accounts without https traffic support
az graph query -q "where type == 'microsoft.storage/storageaccounts' | where properties.supportsHttpsTrafficOnly == true | count"

# Storage account without blob/file encryption
az graph query -q "where type == 'microsoft.storage/storageaccounts' | where properties.encryption.services.blob.enabled == false | count"
az graph query -q "where type == 'microsoft.storage/storageaccounts' | where properties.encryption.services.file.enabled == false | count"

# Strorage accounts without IP rules
az graph query -q "where type == 'microsoft.storage/storageaccounts' | where array_length(properties.networkAcls.ipRules) == 0 | count"

# Storage accounts without VNET restrictions
az graph query -q "where type == 'microsoft.storage/storageaccounts' | where array_length(properties.networkAcls.virtualNetworkRules) == 0 | count"

# Storage accounts without VNET restrictions and IP restrictions
az graph query -q "where type == 'microsoft.storage/storageaccounts' | where array_length(properties.networkAcls.ipRules) == 0 and array_length(properties.networkAcls.virtualNetworkRules) == 0 | count"

# Storage account allowing Azure resources to connect
az graph query -q "where type == 'microsoft.storage/storageaccounts' | where properties.networkAcls.bypass == 'AzureServices' | count"

# Storage accounts created n days ago
az graph query -q "where type == 'microsoft.storage/storageaccounts' | sort by id asc | where properties.creationTime < ago(1500d) | project id, properties.creationTime"

exit 0;
