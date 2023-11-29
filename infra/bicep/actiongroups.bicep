// --------------------------------------------------------------------------------
// Creates a AKS Alerts
// --------------------------------------------------------------------------------
param actionGroupName string = 'AlertGroup1'
@maxLength(12)
param actionGroupShortName string = 'alertgroup1'
param notificationEmail string = ''
param commonTags object = {}

// --------------------------------------------------------------------------------
// Variables
// --------------------------------------------------------------------------------
var templateTag = { TemplateFile: '~aksalerts.bicep' }
var tags = union(commonTags, templateTag)

var emailReceivers = (notificationEmail == '') ? [] : [
  {
    name: 'emailme_-EmailAction-'
    emailAddress: notificationEmail
    useCommonAlertSchema: true
  }
]

// pull Role GUIDs from a common JSON file
var roleDefinitions = loadJsonContent('armroles.json')
var armRoleReceivers = [
  {
    name: 'ArmRole'
    roleId: roleDefinitions.armResourceOwnerRole
    useCommonAlertSchema: true
  }
]

// --------------------------------------------------------------------------------
// Create alert group
// --------------------------------------------------------------------------------
resource actionGroup_resource 'microsoft.insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: emailReceivers
    armRoleReceivers: armRoleReceivers
  }
  tags: tags
}

output id string = actionGroup_resource.id
output name string = actionGroup_resource.name
