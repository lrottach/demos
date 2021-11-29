# Azure PowerShell Advanced Schulung
Erstellt von: Lukas Rottach  
Erstellt am: 23.11.2021

## Vorbereitungen

### Variablen
```powershell
$deploymentLocation = "Switzerland North"
$networkRg = "pdmo-vnet1-csn-rg"
$networkName = "pdmo-vnet1-csn"
```

### Netzwerk Infrastruktur
```powershell
New-AzResourceGroup -Name $networkRg -Location $deploymentLocation
$virtualNetwork = New-AzVirtualNetwork -Name $networkName `
    -ResourceGroup $rgNetwork `
    -Location $deploymentLocation `
    -AddressPrefix = '10.0.0.0/16'

$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name 'DemoSubnet' `
    -VirtualNetwork $virtualNetwork `
    -AddressPrefix '10.0.1.0/24'

$virtualNetwork | Set-AzVirtualNetwork
```
