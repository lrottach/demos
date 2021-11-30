# Azure PowerShell Advanced Schulung
Erstellt von: Lukas Rottach  
Erstellt am: 23.11.2021

## Vorbereitungen

### Module
```powershell
Install-Module -Name Az.Network,Az.Compute -Force -Scope CurrentUser
```

### Variablen
```powershell
$deploymentLocation = "Switzerland North"

# Network variables
$networkRg = "pdmo-vnet1-csn-rg"
$networkName = "pdmo-vnet1-csn"

# Diagnostics Storage Variables
$diagStorageRg = "pdmo-sto1-csn"
$diagStorageName = "pdmosto1csn"

# Virtual Machine Variables
$vmName = "pdmo-adds1-csn"
$vmSize = ""
$vmRg = "pdmo-adds1-csn-rg"

# Virtual Machine Dependencies
$nsgName = $vmName + "-nic1-nsg"
$nicName = $vmName + "-nic1"
$diskName = $vmName + "-odsk"

# Tags
$tags = @{Creator="lrottach@baggenstos.ch"; CreationDate="24.11.2021"; Environment="Production"}
```

### Netzwerk Infrastruktur
```powershell
New-AzResourceGroup -Name $networkRg -Location $deploymentLocation -Tag $tags
$virtualNetwork = New-AzVirtualNetwork -Name $networkName `
    -ResourceGroup $rgNetwork `
    -Location $deploymentLocation `
    -AddressPrefix = '10.0.0.0/16' `
    -Tag $tags

$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name 'DemoSubnet' `
    -VirtualNetwork $virtualNetwork `
    -AddressPrefix '10.0.1.0/24'

$virtualNetwork | Set-AzVirtualNetwork
```

### Diag Storage Account
```powershell
New-AzResourceGroup -Name $diagStorageRg -Location $deploymentLocation -Tag $tags

$diagStorage = New-AzStorageAccount
New-AzStorageAccount -ResourceGroupName $diagStorageRg -AccountName $diagStorageName -Location $deploymentLocation -SkuName Standard_LRS -Kind BlobStorage -Tag $tags
```

### Virtual Machine Deployment
```powershell
# Create parent resource group
New-AzResourceGroup -Name $vmRg -Location $deploymentLocation -Tag $tags

# Create Network Security Group
$nsg = New-AzNetworkSecurityGroup -Name $nsgName `
    -ResourceGroupName $vmRg `
    -Location $deploymentLocation `
    -Tag $tags

# Load network and subnet information
$vnet = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $rgNetwork
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'DemoSubnet' -VirtualNetwork $vnet

# Create IP configuration and network interface
$ipconfig = New-AzNetworkInterfaceIpConfig -Name "IPConfigPrivate" -PrivateIpAddressversion IPv4 -Subnetid $subnet.Id
$nic = New-AzNetworkInterface -Name $nicName `
    -ResourceGroupName $vmRg `
    -Location $deploymentLocation `
    -NetworkSecurityGroupId $nsg.Id `
    -IpConfiguration $ipconfig -Tag $tags

# Build VM configuration
$vm = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$vm = Set-AzVMOperatingSystem -VM $vm -ComputerName $vmName -Credential $vmCredentials -ProvisionVMAgent -EnableAutoUpdate $true -EnableHotpatching $true -PatchMode AutomaticByOS
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
$vm = Set-AzVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2022-datacenter-azure-edition' -Version 'latest'
$vm = Set-AzVMOSDisk -VM $vm -Name $diskName -DiskSizeInGB '128' -StorageAccountType StandardSSD_LRS -CreateOption fromImage

$vm = Set-AzVMBootDiagnostics -VM $vm -Enable -ResourceGroupName $diagStorageRg -StorageAccountName $diagStorageName
```
