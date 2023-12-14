// ------------------------------------------------------------------------------------------------------------------------
// Main Bicep File for Dashboard
// ------------------------------------------------------------------------------------------------------------------------
param appName string = ''
param envName string = '' // 'DEMO'

param runDateTime string = utcNow()
param location string = resourceGroup().location

// ------------------------------------------------------------------------------------------------------------------------
// Setup
// ------------------------------------------------------------------------------------------------------------------------
var deploymentSuffix = '-${runDateTime}'
var commonTags = {         
  LastDeployed: runDateTime
  Organization: appName
  Environment: envName
}
module resourceNames 'resourcenames.bicep' = {
  name: 'resourceNames${deploymentSuffix}'
  params: {
    appName: appName
    environmentName: toLower(envName)
  }
}

// ------------------------------------------------------------------------------------------------------------------------
// Create Action Group
// ------------------------------------------------------------------------------------------------------------------------
module dashboardModule 'dashboard.bicep' = {
  name: 'dashboard${deploymentSuffix}'
  params: {
     dashboardName: resourceNames.outputs.dashboardName
     dashboardDisplayName: resourceNames.outputs.dashboardDisplayName
     clusterName: resourceNames.outputs.aksClusterName
     clusterResourceGroup: resourceGroup().name
     location: location
     commonTags: commonTags
   }
}
