# Variable area
$deploymentLocation = "Switzerland North"

# Network variables
$networkRg = "pdmo-vnet1-csn-rg"
$networkName = "pdmo-vnet1-csn"

# Diagnostics Storage Variables
$diagStorageRg = "pdmo-sto1-csn-rg"
$diagStorageName = "pdmosto2diagcsn"

# Virtual Machine Variables
$vmName = "pdmo-adds1-csn"
$vmSize = "Standard_D2s_v4"
$vmRg = "pdmo-adds1-csn-rg"
$vmCredentials = Get-Credential

# Virtual Machine Dependencies
$nsgName = $vmName + "-nic1-nsg"
$nicName = $vmName + "-nic1"
$diskName = $vmName + "-odsk"

# Tags
$tags = @{Creator = "lrottach@baggenstos.ch"; CreationDate = "24.11.2021"; Environment = "Production" }

New-AzResourceGroup -Name $networkRg -Location $deploymentLocation -Tag $tags
$virtualNetwork = New-AzVirtualNetwork -Name $networkName `
	-ResourceGroup $networkRg `
	-Location $deploymentLocation `
	-AddressPrefix 10.0.0.0/16 `
	-Tag $tags

$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name 'DemoSubnet' `
	-VirtualNetwork $virtualNetwork `
	-AddressPrefix '10.0.1.0/24'

$virtualNetwork | Set-AzVirtualNetwork

# Diagnostics Storage Account deployment
New-AzResourceGroup -Name $diagStorageRg -Location $deploymentLocation -Tag $tags
New-AzStorageAccount -ResourceGroupName $diagStorageRg -AccountName $diagStorageName -Location $deploymentLocation -SkuName Standard_LRS -AccessTier Hot -Tag $tags

# Resource Group for vm deployment
New-AzResourceGroup -Name $vmRg -Location $deploymentLocation -Tag $tags

# Creating a new Network Security Group
$nsg = New-AzNetworkSecurityGroup -Name $nsgName `
	-ResourceGroupName $vmRg `
	-Location $deploymentLocation `
	-Tag $tags

# Load network and subnet information
$vnet = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $networkRg
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
$vm = Set-AzVMOperatingSystem -VM $vm -ComputerName $vmName -Credential $vmCredentials -ProvisionVMAgent -Windows
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
$vm = Set-AzVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2022-datacenter-azure-edition' -Version 'latest'
$vm = Set-AzVMOSDisk -VM $vm -Name $diskName -DiskSizeInGB '128' -StorageAccountType StandardSSD_LRS -CreateOption fromImage
$vm = Set-AzVMBootDiagnostic -VM $vm -Enable -ResourceGroupName $diagStorageRg -StorageAccountName $diagStorageName

# VM deployment
$vm = New-AzVM -VM $vm -ResourceGroupName $vmRg -Location $deploymentLocation -Tag $tags

$userName = "locadmin"
$userPassword = "Kennwort_2022!" | ConvertTo-SecureString -AsPlainText -Force
$fileUri = "https://pdmosto2mastercsn.blob.core.windows.net/dsc/CreateADPDC.zip"
$settings = @{"ModulesUrl" = $fileUri; ConfigurationFunction = "CreateADPDC.ps1\CreateADPDC"; Properties = @{DomainName = "lro.int"; AdminCreds = @{ UserName = $userName; Password = "PrivateSettingsRef:AdminPassword" } } }
$protectedSettings = @{ Items = @{ AdminPassword = $userPassword } }

Set-AzVMExtension -ResourceGroupName $vmRg `
	-Location $deploymentLocation `
	-VMName $vmName `
	-Name "CreateADForest" `
	-Publisher "Microsoft.PowerShell" `
	-ExtensionType "DSC" `
	-TypeHandlerVersion "2.19" `
	-Settings $settings `
	-ProtectedSettings $protectedSettings
