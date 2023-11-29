// --------------------------------------------------------------------------------
// Creates a AKS Alerts
// --------------------------------------------------------------------------------
param aksClusters array = []
param lawWorkspaceName string = ''
param actionGroupId string = ''

param location string = ''
param commonTags object = {}

// --------------------------------------------------------------------------------
// Variables
// --------------------------------------------------------------------------------
var templateTag = { TemplateFile: '~aksalerts.bicep' }
var tags = union(commonTags, templateTag)

// --------------------------------------------------------------------------------
// Find Log Analytics resource
// --------------------------------------------------------------------------------
resource workspaceResource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = { name: lawWorkspaceName }
var workspaceId = workspaceResource.id

// --------------------------------------------------------------------------------
// Create alerts
// --------------------------------------------------------------------------------
resource kubeWarningsAlertResource 'microsoft.insights/scheduledqueryrules@2023-03-15-preview' = [ for aksClusterName in aksClusters: {
  name: '${aksClusterName} - Kube warnings found'
  location: location
  properties: {
    description: '${aksClusterName} - Kube warnings found'
    severity: 3
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [ workspaceId ]
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          query: 'KubeEvents | where TimeGenerated >= ago(1d) and KubeEventType == "Warning" and ClusterName == "${aksClusterName}" | project ClusterName, TimeGenerated, Name, Namespace, Message, Reason'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      actionGroups: [ actionGroupId ]
      customProperties: {}
    }
  }
  tags: tags
}]
