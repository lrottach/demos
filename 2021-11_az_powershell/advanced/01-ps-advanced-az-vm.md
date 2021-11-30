# Azure PowerShell Advanced Schulung
Erstellt von: Lukas Rottach  
Erstellt am: 23.11.2021

## Vorbereitungen

### Baggenstos Naming Convention
https://bag.sharepoint.com/:x:/r/sites/KTCloudPlatform/Freigegebene%20Dokumente/General/Architecture%20-%20Design%20-%20Templates/Global/Naming%20Convention/20200922_Azure%20Naming%20Conventions.xlsx?d=w9dedaec98d0a4eb5b26b43f16b187d70&csf=1&web=1&e=J7Njip

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
$diagStorageRg = "pdmo-sto1-csn-rg"
$diagStorageName = "pdmosto1csn"

# Master Storage Account
$masterStorageRg = "pdmo-sto2-csn-rg"
$masterStorageName = "pdmost2csn

# Virtual Machine Variables
$vmName = "pdmo-adds1-csn"
$vmSize = "Standard_D2s_v4"
$vmRg = "pdmo-adds1-csn-rg"
$vmCredentials = Get-Credentials

# Virtual Machine Dependencies
$nsgName = $vmName + "-nic1-nsg"
$nicName = $vmName + "-nic1"
$diskName = $vmName + "-odsk"
$pipName = $vmName + "nic1-pip

# Tags
$tags = @{Creator="lrottach@baggenstos.ch"; CreationDate="24.11.2021"; Environment="Production"}
```

### Netzwerk Infrastruktur

```powershell
New-AzResourceGroup -Name $networkRg -Location $deploymentLocation -Tag $tags
$virtualNetwork = New-AzVirtualNetwork -Name $networkName `
    -ResourceGroup $networkRg `
    -Location $deploymentLocation `
    -AddressPrefix '10.0.0.0/16' `
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
New-AzStorageAccount -ResourceGroupName $diagStorageRg -AccountName $diagStorageName -Location $deploymentLocation -SkuName Standard_LRS -Tag $tags
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
$vnet = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $networkRg
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'DemoSubnet' -VirtualNetwork $vnet

# Create public ip address
$publicIp = New-AzPublicIpAddress -ResourceGroupName $vmRg -Name $pipName -Location $deploymentLocation -AllocationMethod Static -Tag $tags

# Create IP configuration and network interface
$ipconfig = New-AzNetworkInterfaceIpConfig -Name "IPConfigPrivate" -PrivateIpAddressversion IPv4 -Subnetid $subnet.Id
$nic = New-AzNetworkInterface -Name $nicName `
    -ResourceGroupName $vmRg `
    -Location $deploymentLocation `
    -NetworkSecurityGroupId $nsg.Id `
    -PublicIpAddressId $publicIp.Id `
    -IpConfiguration $ipconfig -Tag $tags

# Build VM configuration
$vm = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$vm = Set-AzVMOperatingSystem -VM $vm -ComputerName $vmName -Credential $vmCredentials -ProvisionVMAgent -Windows
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
$vm = Set-AzVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2022-datacenter-azure-edition' -Version 'latest'
$vm = Set-AzVMOSDisk -VM $vm -Name $diskName -DiskSizeInGB '128' -StorageAccountType StandardSSD_LRS -CreateOption fromImage
$vm = Set-AzVMBootDiagnostic -VM $vm -Enable -ResourceGroupName $diagStorageRg -StorageAccountName $diagStorageName

# VM deployment
$vm = New-AzVM -VM $vm -ResourceGroupName $vmRg -Location $deploymentLocation -Tag $tags
```
