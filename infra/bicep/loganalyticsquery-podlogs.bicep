// --------------------------------------------------------------------------------
// Creates a Log Analytics Query - Logs for a Pod
// --------------------------------------------------------------------------------
@description('Log Analytics Query Pack Name')
param queryPackName string = ''
@description('String List of Pod Names')
param podsToQuery array = []
@description('String List of Pod NamesSpaces')
param podsNamespacesToQuery array = []
@description('Key/Value of Pod Labels')
param podLabels array = []

@description('String List of computers/nodes')
param computersToQuery array = []
@description('String List of Kube NamesSpaces')
param kubeNamespacesToQuery array = []
@description('String List of Kube Service Names')
param kubeServiceNamesToQuery array = []

@description('Error message to search for')
param errorsToSearchFor array = []
@description('Length of error message that signals a problem')
param logMessageLength int = 5000
@description('Restart count that signals a problem')
param PodRestartCount int = 3

param commonTags object = {}

// --------------------------------------------------------------------------------
var templateTag = { TemplateFile: '~loganalyticsquery-podlogs.bicep' }
var tags = union(commonTags, templateTag)

// --------------------------------------------------------------------------------
resource queryPackResource 'Microsoft.OperationalInsights/querypacks@2019-09-01' existing = { name: queryPackName }

// --------------------------------------------------------------------------------
// 1. **Fetch the latest logs for a specific pod:**
// ContainerLogV2\r\n| where PodName == "${pod}"\r\n| project TimeGenerated, LogMessage, ContainerName\r\n| order by TimeGenerated desc\r\n| take 50
resource podsQuery1 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for pod in podsToQuery: {
  parent: queryPackResource
  name: guid('Pod Log Messages: ${pod}') // pod.queryId
  properties: {
    displayName: 'Pod Log Messages: ${pod}'
    body: 'ContainerLogV2\r\n| where PodName == "${pod}"\r\n| project TimeGenerated, LogMessage, ContainerName\r\n| order by TimeGenerated desc\r\n| take 50'
    related: {
      categories: []
      resourceTypes: [
        'microsoft.operationalinsights/workspaces'
      ]
    }
    tags: tags
  }
}]

// --------------------------------------------------------------------------------
//5. **Count of log entries per pod in the last hour:**
resource podsQuery2 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Count of log entries per pod in the last hour')
  properties: {
    displayName: 'Count of log entries per pod in the last hour'
    body: 'ContainerLogV2\r\n| where TimeGenerated > ago(1h)\r\n| summarize count() by PodName\r\n| order by count_ desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}

// 3. **Identify logs with a specific error keyword:**
// ContainerLogV2\r\n| where LogMessage contains "ERROR"\r\n| project TimeGenerated, PodName, ContainerName, LogMessage\r\n| order by TimeGenerated desc\r\n| take 100
resource podsQuery3 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for error in errorsToSearchFor: {
  parent: queryPackResource
  name: guid('Identify logs with error "${error}"')
  properties: {
    displayName: 'Identify logs with error "${error}"'
    body: 'ContainerLogV2\r\n| where LogMessage contains "${error}"\r\n| project TimeGenerated, PodName, ContainerName, LogMessage\r\n| order by TimeGenerated desc\r\n| take 100'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]

// 8. **Log entries that have a larger than usual size (to identify potential issues or large error dumps):**
// ContainerLogV2\r\n| where strlen(LogMessage) > ${logMessageLength}\r\n| project TimeGenerated, PodName, LogMessage\r\n| order by TimeGenerated desc
resource podsQuery8 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Log entries that have a larger than usual size')
  properties: {
    displayName: 'Log entries that have a larger than usual size'
    body: 'ContainerLogV2\r\n| where strlen(LogMessage) > ${logMessageLength}\r\n| project TimeGenerated, PodName, LogMessage\r\n| order by TimeGenerated desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}

// 2. **Find pods that have restarted more than a specific number of times:**
// KubePodInventory\r\n| where PodRestartCount > ${PodRestartCount}\r\n| project Name, Namespace, PodRestartCount\r\n| order by PodRestartCount desc
resource podsQuery2b 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Find pods that have restarted more than a specific number of times')
  properties: {
    displayName: 'Find pods that have restarted more than a specific number of times'
    body: 'KubePodInventory\r\n| where PodRestartCount > ${PodRestartCount}\r\n| project Name, Namespace, PodRestartCount\r\n| order by PodRestartCount desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}

// 	4. **Pods created in the last 24 hours:**
// KubePodInventory\r\n| where PodCreationTimeStamp > ago(24h)\r\n| project Name, Namespace, PodCreationTimeStamp\r\n| order by PodCreationTimeStamp desc
resource podsQuery4 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Pods created in the last 24 hours')
  properties: {
    displayName: 'Pods created in the last 24 hours'
    body: 'KubePodInventory\r\n| where PodCreationTimeStamp > ago(24h)\r\n| project Name, Namespace, PodCreationTimeStamp\r\n| order by PodCreationTimeStamp desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}
	
// 6. **Identify nodes with the highest number of pods overtime:**
// KubePodInventory\r\n| summarize PodCount=count() by Computer\r\n| order by PodCount desc
resource podsQuery6 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Identify nodes with the highest number of pods overtime')
  properties: {
    displayName: 'Identify nodes with the highest number of pods overtime'
    body: 'KubePodInventory\r\n| summarize PodCount=count() by Computer\r\n| order by PodCount desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}

// 4. **Logs from all pods within a specific namespace:**
// ContainerLogV2\r\n| where PodNamespace == "your-namespace"\r\n| project TimeGenerated, PodName, LogMessage\r\n| order by TimeGenerated desc
resource podsQuery4b 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for pns in podsNamespacesToQuery: {
  parent: queryPackResource
  name: guid('Logs from all pods in namespace ${pns}')
  properties: {
    displayName: 'Logs from all pods in namespace ${pns}'
    body: 'ContainerLogV2\r\n| where PodNamespace == "${pns}"\r\n| project TimeGenerated, PodName, LogMessage\r\n| order by TimeGenerated desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]

// 7. **Logs from a specific computer/node:**
// ContainerLogV2\r\n| where Computer == "your-node-name"\r\n| project TimeGenerated, PodName, LogMessage\r\n| order by TimeGenerated desc
resource podsQuery7 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for comp in computersToQuery: {
  parent: queryPackResource
  name: guid('Logs from computer ${comp}')
  properties: {
    displayName: 'Logs from computer ${comp}'
    body: 'ContainerLogV2\r\n| where Computer == "${comp}"\r\n| project TimeGenerated, PodName, LogMessage\r\n| order by TimeGenerated desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]

// 1. **List all pods with their status in a given namespace:**
// KubePodInventory\r\n| where Namespace == "your-namespace"\r\n| project Name, PodStatus\r\n| order by Name
resource podsQuery1b 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for kns in kubeNamespacesToQuery: {
  parent: queryPackResource
  name: guid('List pods and status in namespace ${kns}')
  properties: {
    displayName: 'List pods and status in namespace ${kns}'
    body: 'KubePodInventory\r\n| where Namespace == "${kns}"\r\n| project Name, PodStatus\r\n| order by Name'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]
	
// 7. **Pod containers associated with a specific service:**
// KubePodInventory\r\n| where ServiceName == "your-service-name"\r\n| project Name, Namespace, ServiceName
resource podsQuery7b 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for ksn in kubeServiceNamesToQuery: {
  parent: queryPackResource
  name: guid('Pod containers associated with service ${ksn}')
  properties: {
    displayName: 'Pod containers associated with service ${ksn}'
    body: 'KubePodInventory\r\n| where ServiceName == "${ksn}"\r\n| project Name, Namespace, ServiceName'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]
	
// 8. **Get pods with specific labels:**
// KubePodInventory\r\n| where PodLabel == "your-label-key=your-label-value"\r\n| project Name, Namespace, PodLabel
resource podsQuery8b 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for label in podLabels: {
  parent: queryPackResource
  name: guid('Get pods with label ${label.key}=${label.value}')
  properties: {
    displayName: 'Get pods with label ${label.key}=${label.value}'
    body: 'KubePodInventory\r\n| where PodLabel == "${label.key}=${label.value}"\r\n| project Name, Namespace, PodLabel'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]
