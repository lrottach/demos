# Azure PowerShell Advanced Schulung
Erstellt von: Lukas Rottach  
Erstellt am: 30.11.2021

## Vorbereitungen
1. Deployment der Azure Function App über das Azure Portal
2. Erstellen einer Managed Identity
3. Berechtigung auf die Azure VM Resource Group
4. Auskommentieren des Az Moduls in requirements.psd1
5. Installation von Postman

## Azure Functions Snippets
### Get VM Sizes for a Azure VM
```powershell
Get-AzVMSize -ResourceGroupName "ResourceGroup03" -VMName "VirtualMachine12"
```

### Resize VM without deallocating
```powershell
$vm = Get-AzVM -ResourceGroupName $resourceGroup -VMName $vmName
$vm.HardwareProfile.VmSize = "<newVMsize>"
Update-AzVM -VM $vm -ResourceGroupName $resourceGroup
```

### Resize VM with deallocating
```powershell
Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force
$vm = Get-AzVM -ResourceGroupName $resourceGroup -VMName $vmName
$vm.HardwareProfile.VmSize = "<newVMSize>"
Update-AzVM -VM $vm -ResourceGroupName $resourceGroup
Start-AzVM -ResourceGroupName $resourceGroup -Name $vmName
```

## Aufgaben

### Aufgabe 1
1. Implementieren eines VmName und VmRg Parameters
2. Abgreifen des neuen Parameters in der Function
3. Abfragen ob eine VM und/oder Resource Group mit dem Namen existiert
4. Entsprechend dem Ergebnis Feedback an den Sender

### Aufgabe 2
1. Implementieren eines VmSize Parameters
2. Abgreifen des neuen Parameters in der Function
3. Prüfen ob es sich bei der VM Size um eine gültige Size handelt
4. Feedback an den Sender zurückgeben