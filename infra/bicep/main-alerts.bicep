// ------------------------------------------------------------------------------------------------------------------------
// Main Bicep File for Alerts and Alert Groups
// ------------------------------------------------------------------------------------------------------------------------
param appName string = ''
param envName string = '' // 'DEMO'

param notificationEmail string = ''
param actionGroupName string = '' // 'AKSAlertGroup1'
param actionGroupShortName string = '' // 'aksalertgrp1'

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
module actionGroupsModule 'actiongroups.bicep' = {
  name: 'actionGroups${deploymentSuffix}'
  params: {
    actionGroupName: actionGroupName
    actionGroupShortName: actionGroupShortName
    notificationEmail: notificationEmail
  }
}

// ------------------------------------------------------------------------------------------------------------------------
// Create Log Analytics Query Pack to contain queries
// ------------------------------------------------------------------------------------------------------------------------
module queryPackModule 'loganalyticsquery_pack.bicep' = {
  name: 'lawQuery_Pack${deploymentSuffix}'
  params: {
    name: resourceNames.outputs.queryPackName
    location: location
    commonTags: commonTags
  }
}

// ------------------------------------------------------------------------------------------------------------------------
// Create general Log Analytics Alerts
// ------------------------------------------------------------------------------------------------------------------------
module lawAlertsModule 'loganalyticsalerts.bicep' = {
  name: 'lawAlerts${deploymentSuffix}'
  params: {
    workspaceName: resourceNames.outputs.logAnalyticsWorkspaceName
    actionGroupId: actionGroupsModule.outputs.id
    location: location
  }
}

// ------------------------------------------------------------------------------------------------------------------------
// Deploy AKS Alerts
// ------------------------------------------------------------------------------------------------------------------------
module aksAlertsModule 'aksalerts.bicep' = {
  name: 'akwAlerts${deploymentSuffix}'
  params: {
    aksClusters: [ 
      resourceNames.outputs.aksClusterName
    ]
    lawWorkspaceName: resourceNames.outputs.logAnalyticsWorkspaceName
    actionGroupId: actionGroupsModule.outputs.id
    location: location
  }
}

// ------------------------------------------------------------------------------------------------------------------------
// Deploy Pod Log Queries
// ------------------------------------------------------------------------------------------------------------------------
module queryPodLogsModule 'loganalyticsquery-podlogs.bicep' = {
  name: 'lawQuery_PodLogs${deploymentSuffix}'
  params: {
    queryPackName: queryPackModule.outputs.name
    podsToQuery: [ 'store-front-797fddd765-kr4xx','bogus-store-123fddd765-kr4xx' ]
    podsNamespacesToQuery: [ 'store-front','bogus-store' ]
    podLabels: [
      {
        key: 'Pod Log Messages: store-front-kr4xx'
        value: 'store-front-797fddd765-kr4xx'
      },{
        key: 'Pod Log Messages: bogus-store-kr4xx'
        value: 'bogus-store-123fddd765-kr4xx'
      }
    ]
    computersToQuery: [ 'computer1','computer2' ]
    kubeNamespacesToQuery: [ 'kubns1','kubns2' ]
    kubeServiceNamesToQuery: [ 'kubesn1','kubesn2' ]
    errorsToSearchFor: [ 'ERROR' ]
    logMessageLength: 5000
    PodRestartCount: 3
    commonTags: commonTags
  }
}

// ------------------------------------------------------------------------------------------------------------------------
// Deploy Container Log Queries
// ------------------------------------------------------------------------------------------------------------------------
module queryContainerLogsModule 'loganalyticsquery-containerlogs.bicep' = {
  name: 'lawQuery_ContainerLogs${deploymentSuffix}'
  params: {
    queryPackName: queryPackModule.outputs.name
    containersToQuery: [ 'store-front', 'bogus-front' ]
    commonTags: commonTags
  }
}

// ------------------------------------------------------------------------------------------------------------------------
// Deploy KubeEvents Log Queries
// ------------------------------------------------------------------------------------------------------------------------
module queryKubeEventsLogsModule 'loganalyticsquery-kubeeventslogs.bicep' = {
  name: 'lawQuery_KubeEventsLogs${deploymentSuffix}'
  params: {
    queryPackName: queryPackModule.outputs.name
    eventsForKind: [ 'pod' ]
    namespaceEvents: [ 'namespace1', 'namespace2' ]
    componentEvents: [ 'kubelet', 'scheduler' ]
    commonTags: commonTags
  }
}
