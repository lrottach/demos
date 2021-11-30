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
## Custom Script Extension
https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows

- Skripte werden auf die Azure VM heruntergeladen und ausgeführt
- Verwendung: Post Deployments, Software Installationen, Konfigurationen und Management

```powershell
Set-AzVMExtension -ResourceGroupName $vmRg `
    -Location $deploymentLocation `
    -VMName $vmName `
    -Name "CreateADForest" `
    -Publisher "Microsoft.PowerShell" `
    -ExtensionType "CustomScriptExtension" `
    -TypeHandlerVersion "2.19" `
    -Settings $settings `
    -ProtectedSettings $protectedSettings;
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