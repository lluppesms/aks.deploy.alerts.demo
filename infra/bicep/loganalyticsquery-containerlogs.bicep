// --------------------------------------------------------------------------------
// Creates a Log Analytics Query - Logs for a Container last 24 Hours
// --------------------------------------------------------------------------------
@description('Log Analytics Query Pack Name')
param queryPackName string = ''
@description('String List of Container Names')
param containersToQuery array = []

param commonTags object = {}

// --------------------------------------------------------------------------------
var templateTag = { TemplateFile: '~loganalyticsquery-containerlogs.bicep' }
var tags = union(commonTags, templateTag)
  
// --------------------------------------------------------------------------------
resource queryPackResource 'Microsoft.OperationalInsights/querypacks@2019-09-01' existing = { name: queryPackName }

// --------------------------------------------------------------------------------
// 2. **Logs of a specific container over the last 24 hours:**
// ContainerLogV2\r\n| where ContainerName == "${container}" and TimeGenerated > ago(24h)\r\n| project TimeGenerated, LogMessage\r\n| order by TimeGenerated desc\r\n'
resource containersQuery2 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for container in containersToQuery: {
  parent: queryPackResource
  name: guid('Container Log Messages: ${container}')
  properties: {
    displayName: 'Container Log Messages: ${container}'
    body: 'ContainerLogV2\r\n| where ContainerName == "${container}" and TimeGenerated > ago(24h)\r\n| project TimeGenerated, LogMessage\r\n| order by TimeGenerated desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]

// --------------------------------------------------------------------------------
// 6. **Identify most active containers in terms of log generation:**
// ContainerLogV2\r\n| summarize logCount=count() by ContainerName\r\n| order by logCount desc\r\n| take 10
resource containersQuery6 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Identify most active containers in terms of log generation')
  properties: {
    displayName: 'Identify most active containers in terms of log generation'
    body: 'ContainerLogV2\r\n| summarize logCount=count() by ContainerName\r\n| order by logCount desc\r\n| take 10'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}

// --------------------------------------------------------------------------------
// 3. **List containers that are in 'Running' status or not:**
// KubePodInventory\r\n| where ContainerStatus == "Running"\r\n| project Name, Namespace, ContainerName, ContainerStatus
resource containersQuery3 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('List container running status')
  properties: {
    displayName: 'List container running status'
    body: 'KubePodInventory\r\n| where ContainerStatus == "Running"\r\n| project Name, Namespace, ContainerName, ContainerStatus'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}
	
// --------------------------------------------------------------------------------
// 5. **Containers with the most restarts in a cluster:**
// KubePodInventory\r\n| summarize TotalRestarts=sum(ContainerRestartCount) by ContainerName\r\n| order by TotalRestarts desc\r\n| take 10
resource containersQuery5 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Containers with the most restarts in a cluster')
  properties: {
    displayName: 'Containers with the most restarts in a cluster'
    body: 'KubePodInventory\r\n| summarize TotalRestarts=sum(ContainerRestartCount) by ContainerName\r\n| order by TotalRestarts desc\r\n| take 10'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}
