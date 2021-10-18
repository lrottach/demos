$location = "Switzerland North"
$resourceGroup = "pdco-sto1-csn"
$accountName = "pdcosto33csn"
$tags = @{"Creator" = "lrottach@baggenstos.ch"; "Creation Date" = "18.10.2021" }

# Create a new storage account
New-AzStorageAccount -ResourceGroupName $resourceGroup `
	-Name $accountName `
	-Location $location `
	-SkuName Standard_LRS `
	-Kind StorageV2 `
	-Tags $tags

$newTag = @{"Environment" = "Production" }

$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -StorageAccount $accountName