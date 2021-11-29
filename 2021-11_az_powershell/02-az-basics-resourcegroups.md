# Azure PowerShell Basics Schulung
Erstellt von: Lukas Rottach  
Erstellt am: 24.11.2021

## Azure Resource Groups
Die folgenden Beispiele zeigen die Erstellung und Verwaltung von Azure Ressource Gruppen auf.
### Erstellen
Der folgende Befehl erstellt eine neue Resource Group in der Azure Region 'Switzerland North'
```powershell
New-AzResourceGroup -Name pdmo-tst1-csn-rg -Location 'Switzerland North' -Force
```
Der `-Force` Parameter erstellt die Resource Group ohne das eine weitere Interaktion durch den Benutzer / die Benutzerin erforderlich ist. Existiert die Resource Group z. B. schon bricht das Skript Dank des Parameters nicht ab.

### Manipulation
Eine Resource Group lässt sich im Nachhinein mit Hilfe des `Set-AzResourceGroup` Befehls bearbeiten.  
In diesem Beispiel sollten folgende Tags nachträglich auf die Resource Group angewendet werden.
```powershell
# Tag Object
$tags = @{Creator="lrottach@baggenstos.ch"; CreationDate="24.11.2021"; Environment="Production"}
```
Mit folgendem Code werden die Tags auf die Resource Group angewendet.
```powershell
Set-AzResourceGroup -Name pdmo-tst1-csn-rg -Tag $tags
```

### Prüfung
Um eine bestehende Ressource zu überprüfen oder um weitere Details anzeigen zu lassen wird der `Get-AzResourceGroup` Befehl verwendet.
```powershell
Get-AzResourceGroup -Name pdmo-tst1-csn-rg
```

### Härtung
Um Resource Groups und die darin enthaltenen Ressourcen zu schützen bietet Azure die Möglichkeit der sogenannten 'Resource Locks'. Damit wird die entsprechende Resource Group vor versehentlichem Löschen geschützt.
```powershell
New-AzResourceLock -LockName 'az-rg-lock-delete' -LockLevel CanNotDelete -ResourceGroupName pdmo-tst1-csn-rg
```

### Löschen
Um die in diesem Beispiel erstellten Ressourcen wieder zurückzubauen muss erst das Resource Lock entfernt werden.
```powershell
$lockId = (Get-AzResourceLock -ResourceGroupName pdmo-tst1-csn-rg).LockId
Remove-AzResourceLock -LockId $lockId
```
Im Anschluss kann die Resource Group wie gewohnt gelöscht werden.
```powershell
Remove-AzResourceGroup -Name pdmo-tst1-csn-rg
```
