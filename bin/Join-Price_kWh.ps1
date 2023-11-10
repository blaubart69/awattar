param (
     [int]$year
    ,[int]$month
)

$dataAwattar = "$PSScriptRoot/../data/$($Year)-$($month.ToString('00'))_awattar.csv"
$dataNetze   = "$PSScriptRoot/../data/$($Year)-$($month.ToString('00'))_kWh.csv"

Join-Object `
-Left  ( & "$PSScriptRoot/Convert-Awattar.ps1"     -filename $dataAwattar) `
-Right ( & "$PSScriptRoot/Convert-WienerNetze.ps1" -filename $dataNetze) `
-LeftJoinProperty  Timestamp `
-RightJoinProperty Timestamp `
-Type OnlyIfInBoth `
-RightProperties kWh,kWhx1000 
| % {
    $priceCent = ( $_.kWhx1000 * $_.Centx100 ) / 100000
    Add-Member -InputObject $_ -Type NoteProperty -Name PriceCent -Value $priceCent -PassThru
}