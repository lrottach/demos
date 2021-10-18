$location = "Switzerland North"
$resourceGroup = "pdco-demo1-csn"
$accountName = "pdcosto33csn"
$tags = @{"Creator" = "lrottach@baggenstos.ch"; "Creation Date" = "18.10.2021" }

# Create a new storage account
New-AzStorageAccount -ResourceGroupName $resourceGroup `
	-Name $accountName `
	-Location $location `
	-SkuName Standard_LRS `
	-Kind StorageV2 `
	-Tags $tags

# Add new tag to existing storage account
$newTag = @{"Environment" = "Production" }

$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -StorageAccount $accountName

Set-AzResource -ResourceId $storageAccount.Id `
	-Tag $newTag `
	-Force