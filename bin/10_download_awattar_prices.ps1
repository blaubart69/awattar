param (
    [int]$year
    ,[int]$month
)
Invoke-WebRequest -OutFile "$PSScriptRoot/../data/$($Year)-$($month.ToString('00'))_awattar.csv" `
"https://api.awattar.at/v1/marketdata/csv/$year/$month/"