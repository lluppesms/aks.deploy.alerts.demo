// --------------------------------------------------------------------------------
// Bicep file that builds all the resource names used by other Bicep templates
// --------------------------------------------------------------------------------
param appName string = ''
@allowed(['azd','gha','azdo','dev','demo','qa','stg','ct','prod'])
param environmentName string = 'demo'

// --------------------------------------------------------------------------------
var sanitizedEnvironment = toLower(environmentName)
var sanitizedAppNameWithDashes = replace(replace(toLower(appName), ' ', ''), '_', '')
var sanitizedAppName = replace(replace(replace(toLower(appName), ' ', ''), '-', ''), '_', '')

// pull resource abbreviations from a common JSON file
var resourceAbbreviations = loadJsonContent('resourceabbreviations.json')

// --------------------------------------------------------------------------------
output logAnalyticsWorkspaceName string   = toLower('${sanitizedAppNameWithDashes}-${resourceAbbreviations.logworkspace}-${sanitizedEnvironment}')
output appInsightsName string             = toLower('${sanitizedAppNameWithDashes}-${resourceAbbreviations.appInsightsSuffix}-${sanitizedEnvironment}')

output queryPackName string               = toLower('${sanitizedAppNameWithDashes}-${resourceAbbreviations.queryPack}-${sanitizedEnvironment}')

output dashboardName string               = toLower('${sanitizedAppNameWithDashes}-${resourceAbbreviations.dashboard}-${sanitizedEnvironment}')
output dashboardDisplayName string        = '${appName} AKS Dashboard'

output aksClusterName string              = toLower('${sanitizedAppName}${resourceAbbreviations.aksCluster}${sanitizedEnvironment}')
output sshKeyName string                  = toLower('${sanitizedAppName}${resourceAbbreviations.sshKey}${sanitizedEnvironment}')
output linuxAdminUsername string          = toLower('${sanitizedAppName}admin')

// --------------------------------------------------------------------------------
// Container names can only be alpha
output containerRegistryName string       = toLower('${sanitizedAppName}${resourceAbbreviations.containerRegistry}${sanitizedEnvironment}')

// --------------------------------------------------------------------------------
// Key Vaults and Storage Accounts can only be 24 characters long
output keyVaultName string                = take('${sanitizedAppName}${resourceAbbreviations.keyVaultAbbreviation}${sanitizedEnvironment}', 24)
output storageAccountName string          = take('${sanitizedAppName}${resourceAbbreviations.storageAccountSuffix}data${sanitizedEnvironment}', 24)
output iotStorageAccountName string       = take('${sanitizedAppName}${resourceAbbreviations.storageAccountSuffix}iot${sanitizedEnvironment}', 24)
output logicAppStorageAccountName string  = take('${sanitizedAppName}${resourceAbbreviations.storageAccountSuffix}logic${sanitizedEnvironment}', 24)
