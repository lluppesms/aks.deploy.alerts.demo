// --------------------------------------------------------------------------------
// Creates a Log Analytics Query Pack
// --------------------------------------------------------------------------------
param name string = '' // 'la_aks_queries'
param location string = resourceGroup().location
param commonTags object = {}

resource queryPackResource 'Microsoft.OperationalInsights/querypacks@2019-09-01' = {
  name: name
  location: location
  properties: {}
  tags: commonTags  
}

output id string = queryPackResource.id
output name string = queryPackResource.name
