// --------------------------------------------------------------------------------
// Creates a Log Analytics Query - KubeEvents
//    --> RAW DATA:  converted these queries but haven't tested them yet...!
// --------------------------------------------------------------------------------
param queryPackName string = ''
@description('String List of Object Kinds to list events')
param eventsForKind array = []
@description('String List of Namespaces to list events')
param namespaceEvents array = []
@description('String List of Components to list events')
param componentEvents array = []
param commonTags object = {}
  
// --------------------------------------------------------------------------------
var templateTag = { TemplateFile: '~loganalyticsquery-podlogs.bicep' }
var tags = union(commonTags, templateTag)

// --------------------------------------------------------------------------------
resource queryPackResource 'Microsoft.OperationalInsights/querypacks@2019-09-01' existing = { name: queryPackName }

// --------------------------------------------------------------------------------
// 1. **Retrieve All Events in the Last 24 Hours:**   ==> Kube Query
// KubeEvents\r\n| where TimeGenerated >= ago(1d)\r\n| project TimeGenerated, Name, Namespace, KubeEventType, Message, Reason
resource kubeEventQuery1 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Retrieve All Events in the Last 24 Hours')
  properties: {
    displayName: 'Retrieve All Events in the Last 24 Hours'
    body: 'KubeEvents\r\n| where TimeGenerated >= ago(1d)\r\n| project TimeGenerated, Name, Namespace, KubeEventType, Message, Reason'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}
	
// 2. **Find Warning Events in the Last 24 Hours:**   ==> Kube Query
// KubeEvents\r\n| where TimeGenerated >= ago(1d) and KubeEventType == "Warning"\r\n| project TimeGenerated, Name, Namespace, Message, Reason
resource kubeEventQuery2 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Find Warning Events in the Last 24 Hours')
  properties: {
    displayName: 'Find Warning Events in the Last 24 Hours'
    body: 'KubeEvents\r\n| where TimeGenerated >= ago(1d) and KubeEventType == "Warning"\r\n| project TimeGenerated, Name, Namespace, Message, Reason'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}
	
// 3. **Events by Namespace in the Last 24 Hours:**   ==> Kube Query
// KubeEvents\r\n| where TimeGenerated >= ago(1d)\r\n| summarize EventCount=count() by Namespace\r\n| order by EventCount desc
resource kubeEventQuery3 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Events by Namespace in the Last 24 Hours')
  properties: {
    displayName: 'Events by Namespace in the Last 24 Hours'
    body: 'KubeEvents\r\n| where TimeGenerated >= ago(1d)\r\n| summarize EventCount=count() by Namespace\r\n| order by EventCount desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}
	
// 4. **Most Common Reasons for Events in the Last 24 Hours:**   ==> Kube Query
// KubeEvents\r\n|where TimeGenerated >= ago(1d)\r\n|summarize Count=count() by Reason\r\n| order by Count desc
resource kubeEventQuery4 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPackResource
  name: guid('Most Common Reasons for Events in the Last 24 Hours')
  properties: {
    displayName: 'Most Common Reasons for Events in the Last 24 Hours'
    body: 'KubeEvents\r\n|where TimeGenerated >= ago(1d)\r\n|summarize Count=count() by Reason\r\n| order by Count desc'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}
	
// 5. **Find Specific Events by ObjectKind (e.g., Pod) in the Last 24 Hours:**   ==> Kube Query
// KubeEvents\r\n| where TimeGenerated >= ago(1d) and ObjectKind == "Pod"\r\n| project TimeGenerated, Name, Namespace, KubeEventType, Message, Reason
resource kubeEventQuery5 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for kind in eventsForKind: {
  parent: queryPackResource
  name: guid('Specific Events for Kind "${kind}" in the Last 24 Hours')
  properties: {
    displayName: 'Specific Events for Kind "${kind}" in the Last 24 Hours'
    body: 'KubeEvents\r\n| where TimeGenerated >= ago(1d) and ObjectKind == "${kind}"\r\n| project TimeGenerated, Name, Namespace, KubeEventType, Message, Reason'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]

// 6. **Find Events in a Namespace:**   ==> Kube Query
// KubeEvents\r\n| where Namespace == "<NamespaceName>"\r\n| project TimeGenerated, KubeEventType, Message, Reason
resource kubeEventQuery6 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for namespace in namespaceEvents: {
  parent: queryPackResource
  name: guid('Find Events for Namespace "${namespace}"')
  properties: {
    displayName: 'Find Events for Namespace "${namespace}"'
    body: 'KubeEvents\r\n| where Namespace == "${namespace}"\r\n| project TimeGenerated, KubeEventType, Message, Reason'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]

// 7. **List of Events Generated by a Specific Source Component (e.g., kubelet, scheduler):**   ==> Kube Query
// KubeEvents\r\n| where SourceComponent == "<SourceComponentName>"\r\n| project TimeGenerated, Name, Namespace, KubeEventType, Message, Reason
resource kubeEventQuery7 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = [ for component in componentEvents: {
  parent: queryPackResource
  name: guid('List of Events Generated by a Component "${component}"')
  properties: {
    displayName: 'List of Events Generated by a Component "${component}"'
    body: 'KubeEvents\r\n| where SourceComponent == "${component}"\r\n| project TimeGenerated, Name, Namespace, KubeEventType, Message, Reason'
    related: {
      categories: []
      resourceTypes: [ 'microsoft.operationalinsights/workspaces' ]
    }
    tags: tags
  }
}]
