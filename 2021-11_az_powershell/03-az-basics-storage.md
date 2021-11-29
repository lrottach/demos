# Azure PowerShell Basics Schulung
Erstellt von: Lukas Rottach  
Erstellt am: 24.11.2021

## Azure Storage Accounts

### Vorbereitungen
Folgende Variablen werden erstellt um die Deployment Details festzulegen.
```powershell
$storageRg = "pdmo-sto1-csn-rg"
$deploymentLocation = "Switzerland North"
$storageName = "pdmosto1csn"
```

Als Vorbereitung für das Deployment des Storage Accounts wird die Resource Group erstellt.
```powershell
New-AzResourceGroup -Name $storageRg -Location $deploymentLocation
```

### Storage Deployment
Folgender Befehl erstellt einen neuen Azure Storage Account.
```powershell

```