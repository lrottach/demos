$location = "Switzerland North"
$resourceGroup = "pdco-demo2-csn"
$accountName = "pdcostodemo4csn"

New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $accountName -Location $location -SkuName Standard_LRS -Kind StorageV2

$tags = @{Createor = "lrottach....." }

$account = Get-AzStorageAccount

Set-AzStorageAccount