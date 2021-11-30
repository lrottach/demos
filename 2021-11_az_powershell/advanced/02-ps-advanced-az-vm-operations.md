# Azure PowerShell Advanced Schulung
Erstellt von: Lukas Rottach  
Erstellt am: 30.11.2021

## Vorbereitungen
https://docs.microsoft.com/en-us/azure/virtual-machines/windows/run-scripts-in-vm

### Module
```powershell
Install-Module -Name Az.Network,Az.Compute -Force -Scope CurrentUser
```

### Variablen
```powershell
$deploymentLocation = "Switzerland North"

# Virtual Machine Variables
$vmName = "pdmo-adds1-csn"
$vmRg = "pdmo-adds1-csn-rg"
```

## Master Storage Account und File Upload
```powershell
# Master Storage Account
$masterStorageRg = "pdmo-sto2-csn-rg"
$masterStorageName = "pdmosto2csn"

New-AzResourceGroup -Name $masterStorageRg -Location $deploymentLocation -Tag $tags

$masterStorage = New-AzStorageAccount -ResourceGroupName $masterStorageRg -AccountName $masterStorageName -Location $deploymentLocation -SkuName Standard_LRS -Tag $tags

# Save Storage Account Context
$ctx = $masterStorage.Context

# Create a new container
$containerName = "dsc"
New-AzStorageContainer -Name $containerName -Context $ctx -Permission Blob

# Upload file to container
Set-AzStorageBlobContent -File '.\file.bla' -Container $containerName -Blob "file.bla" -Context $ctx
```
## Add new Data Disks
```powershell
# Set required variables
$dataDiskName = $vmName + "-ddsk"

# Initialize disk config
$dataDiskConfig = New-AzDiskConfig -Location $deploymentLocation -DiskSizeGB 20 -SkuName Standard_LRS -CreateOption Empty

# Create new disk
$dataDisk = New-AzDisk -ResourceGroupName $vmRg -DiskName $dataDiskName -Disk $dataDiskConfig

# Attach disk to VM
$vm = Get-AzVm -Name $vmName -ResourceGroupName $vmRg
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $dataDisk.Id
Update-AzVm -VM $vm -ResourceGroupName $vmRg
```

## Custom Script Extension
https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows

- Skripte werden auf die Azure VM heruntergeladen und ausgeführt
- Verwendung: Post Deployments, Software Installationen, Konfigurationen und Management

```powershell
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
	-ProtectedSettings $protectedSettings `
	-AsJob
```


## Run Commands
https://docs.microsoft.com/en-us/azure/virtual-machines/windows/run-command

- Skripte werden unter Windows als 'System' ausgeführt
- Nur ein Skript kann gleichzeitig ausgeführt werden
- Keine interaktiven Skripts möglich
- Maximale Laufzeit ca. 90 Minuten

### Build in Script zum Auslesen von IP Informationen
```powershell
Invoke-AzVMRunCommand -ResourceGroupName $vmRg -Name $vmName -CommandId 'IPConfig' 
```

## Disk resizing
https://docs.microsoft.com/en-us/azure/virtual-machines/windows/expand-os-disk

### Live Resizing (Preview)
```powershell
Register-AzProviderFeature -FeatureName "LiveResize" -ProviderNamespace "Microsoft.Compute"
```

### Classic Resizing
```powershell
# Stop Azure VM
Stop-AzVM -ResourceGroupName $vmRg -Name $vmName

# Edit disk
$disk = Get-AzDisk -ResourceGroupName $vmRg -DiskName $dataDiskName
$disk.DiskSizeGB = 256
Update-AzDisk -ResourceGroupname $vmRg -Disk $disk -DiskName $disk.Name
```