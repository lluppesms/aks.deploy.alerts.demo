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
module logAnalyticsModule 'loganalytics.bicep' = {
  name: 'logAnalyticsWorkspace${deploymentSuffix}'
  params: {
    name: resourceNames.outputs.logAnalyticsWorkspaceName
    location: location
    commonTags: commonTags
  }
}

// This should generate a key, but I can't get that to work, so it's simulating the generate
// and just returning an existing public key
module sshKeyModule 'sshkey.bicep' = {
  name: 'sshKey${deploymentSuffix}'
  params: {
    sshKeyName: resourceNames.outputs.sshKeyName
    //location: location
  }
}

module aksModule 'aks.bicep' = {
  name: 'aks${deploymentSuffix}'
  params: {
    clusterName: resourceNames.outputs.aksClusterName
    location: location
    commonTags: commonTags
    dnsPrefix: resourceNames.outputs.aksClusterName
    linuxAdminUsername: resourceNames.outputs.linuxAdminUsername
    sshRSAPublicKey: sshKeyModule.outputs.publicKey
  }
}
