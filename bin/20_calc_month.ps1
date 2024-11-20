param (
     [int]$year
    ,[int]$month
)

# Date      : 31.07.2023
# Hour      : 14
# Timestamp : 7/31/2023 2:00:00PM
# baseprice : 6.01
# CentkWh   : 6.01
# Centx100  : 601
# kWh       : 0.197
# kWhx1000  : 197
# PriceCent : 1.18397
$joinedData = (& "$PSScriptRoot/Join-Price_kWh.ps1" -year $year -month $month)

$groupPerDay = 
(
      $joinedData
    | Group-Object -Property Date
    | % {
        $EuroNet = ( $_.Group | Measure-Object -Sum PriceCent ).Sum / 100
        [PSCustomObject]@{
            Date       = $_.Name
            EuroNet    = $EuroNet
            #EuroBrutto = $EuroNet * 1.2
            kWhDay     = ( $_.Group | Measure-Object -Sum kWh ).Sum
        }
    }
)

$CentMinus = 0

$joinedData | % { 
    if ( $_.Centx100 -lt 0 ) {
        $CentMinus += -$_.PriceCent
    }
}

$groupPerDay

[decimal]$SumNet      = ( $groupPerDay | Measure-Object -Sum -Property EuroNet ).Sum
[decimal]$daysInMonth = ( $groupPerDay | Measure-Object ).Count
[decimal]$kwHSum      = ( $groupPerDay | Measure-Object -Sum -Property kWhDay ).Sum
[decimal]$kWhAverage  = $kwHSum / $daysInMonth

[decimal]$awattar     = [Math]::Abs($SumNet * [decimal]0.03) + ( $kwHSum * [decimal]0.015 )
[decimal]$EnergyNet   = $SumNet + $awattar
[decimal]$vat         = $EnergyNet * 0.2

[PSCustomObject]@{
    EPEX        = $SumNet
    Awattar     = $awattar
    EnergyNet   = $EnergyNet
    Vat         = $vat
    Brutto      = $EnergyNet + $vat
    EuroEarned  = $CentMinus / 100
    kWhSum      = $kwHSum
    kWhAveragePerDay = $kWhAverage
    CentPerKwH = $SumNet / $kwHSum * 100
} | Format-List