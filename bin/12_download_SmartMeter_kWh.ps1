param (
    [int]$year
    ,[int]$month
)


Invoke-WebRequest -Uri "https://api.awattar.at/v1/marketdata/csv/$year/$month/" -Method Post -WebSession $sess