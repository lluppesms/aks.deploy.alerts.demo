// -----------------------------------------------------------------------------------------------
// This BICEP file will create an sshkey in the resource group
// See also: https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/sshpublickeys?pivots=deployment-language-bicep
// -----------------------------------------------------------------------------------------------
// Warning - can't get this to generate right.... 
// go create it manually with the command
// then copy the public key into this file...
// -----------------------------------------------------------------------------------------------
param sshKeyName string = 'mykeypair'
//param location string = resourceGroup().location

resource sshKeyResource 'Microsoft.Compute/sshPublicKeys@2023-03-01' existing = {
  name: sshKeyName
}

output publicKey string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDck27hppnvbGe1XsqeJ4jxU9lsFYjgsjk2Pj1OlWtmFSm3etZ7hPkfeBQxgetuyXViGvpPNOmUdENiwCWNrr/UCoTbOjiNEas4sf4+Z6h73bKWUp7hbi0kcUGoujGuXxlULmeWvQdRHgcD+AIk6PshA05n68ae1JLu0PCT7tLHRzDvb9KiK9ThJ2LfmYhAHPLbBGdxv61Rj1xlcXahtYOIOK9Dd7iSzN1acR0scVSqMHBODqVmJCBKXTOnlroOlsDD8i7Y50NOlG5EUy5j4058fjC9THNyvvERIqr+mKXJtxWQUd9a5ceHKi9NgYZ9eqF6EXAkbWLOOcUaKCyy2ZsDh5DpQLNsT98KQZEVGhDkm0FCRnpiL9IZnFLEMEmJgwjfpUCs/TBFQL36yPns0pnVgjCMc+Zn+Fgany9XEam1J0N54MUJc5eIxRwOD56R32lxp+t9ZPr9y7oKFXpQED5SpG6tusb+ddxiSdU9nz74n/B+/ZWTFnxoGCTzHUiLSi0= generated-by-azure'
output id string = sshKeyResource.id
output keyName string = sshKeyResource.name

//param utcValue string = utcNow()
//var resourceGroupName = resourceGroup().name
// resource createSSHKey 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   name: 'createSSHKey'
//   location: location
//   kind: 'AzurePowerShell'
//   properties: {
//     azPowerShellVersion: '8.1'
//     forceUpdateTag: utcValue
//     retentionInterval: 'PT1H'
//     timeout: 'PT5M'
//     cleanupPreference: 'Always' // cleanupPreference: 'OnSuccess' or 'Always'
//     arguments: ' -KeyName ${sshKeyName} -ResourceGroupName ${resourceGroupName}'
//     scriptContent: loadTextContent('sshkeycreate.ps1')
//   }
// }
// output name string = sshKeyName
