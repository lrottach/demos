# Azure PowerShell Basics Schulung

Erstellt von: Lukas Rottach  
Erstellt am: 23.11.2021

## Azure Modul Installation

Das gesamte Az Modul lässt sich über den folgenden Befehl installieren.

```powershell
Install-Module -Name Az.Accounts -Force
```

Alterantiv lässt sich das Modul auch ohne Adminrechte im Kontext des aktuellen Accounts installieren.

```powershell
Install-Module -Name Az.Accounts -Force -Scope CurrentUser
```

Die Installation des gesamten Az Moduls kann unter Umständen mehrere Minuten in Anspruch nehmen. Um dem vorzubeugen lassen sich auch einzelne Az Module installieren.

```powershell
Install-Module -Name Az.Accounts,Az.KeyVault,Az.Compute -Force -Scope CurrentUser
```

## Azure Anmeldung

### Klassische Anmeldung

Öffnet die Microsoft Login Website im zuletzt verwendeten Browser.

```powershell
Connect-AzAccount
```

**Nachteil:** Kompliziert und umständlich sobald mehrere Browser verwendet werden.

### Device Anmeldung

Die Anmeldung erfolgt über https://microsoft.com/devicelogin und einen durch die PowerShell zur verfügung gestellten Device Code.

```powershell
Connect-AzAccount -UseDeviceAuthentication
```

### Spezifische Tenant Anmeldung

Anmeldung an einem bestimmten Tenant und Subscription.

```powershell
Connect-AzAccount -UseDeviceAuthentication -TenantId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -SubscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## Azure Kontext

Während der Verwaltung verschiedener Kunden muss stets sichergestellt sein, dass die Azure PowerShell im richtigen Kontext verbunden ist.

```powershell
~ ➜ Get-AzContext

Name                                     Account               SubscriptionName      Environment           TenantId
----                                     -------               ----------------      -----------           --------
azure-prod-infra01 (xxxxxxxx-xxxx-xxxx… admsupplier_baggenst… azure-prod-infra01   AzureCloud            xxxxxxxx-xxxx-xxxx-…

~ ➜
```

Mit dem Befehl `Get-AzContext` lässt sich prüfen, mit welchem Tenant und welcher Azure Subscription die Verbindung besteht.  
Mit dem Befehl `Set-AzContext` lässt sich die Verbindung in einen anderen Tenant / Subscription herstellen.

```powershell
Set-AzContext -TenantId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -SubscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## Azure Abmeldung

Mit dem folgenden Befehl wird die aktive Verbindung zum bestehnden Tenant (Kontext) getrennt.

```powershell
Disconnect-AzAccount
```
