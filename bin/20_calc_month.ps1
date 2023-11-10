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

$SumNet      = ( $groupPerDay | Measure-Object -Sum -Property EuroNet ).Sum
$vat         = $SumNet * 0.2
$daysInMonth = ( $groupPerDay | Measure-Object ).Count
$kwHSum      = ( $groupPerDay | Measure-Object -Sum -Property kWhDay ).Sum
$kWhAverage  = $kwHSum / $daysInMonth
$AwattarEuro = ($SumNet * 0.03) + ( $kwHSum * 0.015 )


[PSCustomObject]@{
    EuroSumNet  = $SumNet
    Mwst        = $vat
    AwattarEuro = $AwattarEuro
    EuroBrutto  = $SumNet + $vat
    EuroTotal   = $SumNet + $vat + $AwattarEuro
    EuroEarned  = $CentMinus / 100
    kWhSum      = $kwHSum
    kWhAveragePerDay = $kWhAverage
    CentPerKwH = $SumNet / $kwHSum * 100
} | Format-List