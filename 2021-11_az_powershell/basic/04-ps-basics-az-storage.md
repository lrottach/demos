# Azure PowerShell Basics Schulung

Erstellt von: Lukas Rottach  
Erstellt am: 24.11.2021

## Azure Storage Accounts

### Vorbereitungen

Installation des 'Az.Storage' PowerShell Moduls.

```powershell
Install-Module -Name Az.Storage -Force -Scope CurrentUser
```

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
New-AzStorageAccount -ResourceGroupName $storageRg -AccountName $storageName -Location $deploymentLocation -SkuName Standard_LRS -Kind BlobStorage -AccessTier Hot
```

Mit dem entsprechenden 'Set-AzStorageAccount' Befehl lassen sich auch Konfigurationen an bestehenden Storage Accounts vornehmen.

```powershell
$storage = Set-AzStorageAccount -ResourceGroupName $storageRg -AccountName $storageName -MinimumTlsVersion TLS1_2 -AllowBlobPublicAccess $false
```

### Übung

1. Erstelle eine neue, leere Resource Group
2. Baue die Logik (Schleifen, usw.) um 10 Storage Accounts zu erstellen
3. Jeder Storage Account startet mit einem Prefix (z. B. pdmosto). Darauf folgt eine fortlaufende Zahl. Anschliessend endet der Name mit dem Location Postfix (z. B. csn)

#### Lösung 1 (for loop)

```powershell
$storageRg = "pdmo-sto1-csn-rg"
$deploymentLocation = "Switzerland North"
$storagePrefix = "pdmosto"
$storagePostfix = "csn"

for ($i = 1; $i -le 10; $i++) {
$storageName = $storagePrefix + $i + $storagePostfix
New-AzStorageAccount -Name $storageName -Location $deploymentLocation -ResourceGroupName $storageRg -AccountType Standard_LRS -AsJob
}
```

#### Lösung 2 (foreach loop)

```powershell
$storageRg = "pdmo-sto1-csn-rg"
$deploymentLocation = "Switzerland North"

$storageNames = @(
	"pdmosto1csn",
	"pdmosto2csn",
	"pdmosto3csn",
	"pdmosto4csn",
	"pdmosto5csn",
	"pdmosto6csn",
	"pdmosto7csn",
	"pdmosto8csn",
	"pdmosto9csn",
	"pdmosto10csn"
)

foreach ($storageName in $storageNames) {
	New-AzStorageAccount -Name $storageName -Location $deploymentLocation -ResourceGroupName $storageRg -AccountType Standard_LRS -AsJob
}
```
