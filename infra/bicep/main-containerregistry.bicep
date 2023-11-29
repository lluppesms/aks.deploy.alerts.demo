// ------------------------------------------------------------------------------------------------------------------------
// Main Bicep File for Azure Container App Project
// ------------------------------------------------------------------------------------------------------------------------
param appName string = ''
param envName string = 'DEMO'

param runDateTime string = utcNow()
param location string = resourceGroup().location

// ------------------------------------------------------------------------------------------------------------------------
var deploymentSuffix = '-${runDateTime}'
var commonTags = {         
  LastDeployed: runDateTime
  Organization: appName
  Environment: envName
}

// --------------------------------------------------------------------------------
module resourceNames 'resourcenames.bicep' = {
  name: 'resourceNames${deploymentSuffix}'
  params: {
    appName: appName
    environmentName: toLower(envName)
  }
}

// ------------------------------------------------------------------------------------------------------------------------
module containerRegistryModule 'containerregistry.bicep' = {
  name: 'containerRegistry${deploymentSuffix}'
  params: {
    containerRegistryName: resourceNames.outputs.containerRegistryName
    location: location
    skuName: 'Premium'
    commonTags: commonTags
  }
}
