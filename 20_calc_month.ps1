param (
     [int]$year
    ,[int]$month
)

$groupPerDay = 
(
    & "$PSScriptRoot/Join-Price_kWh.ps1" -year $year -month $month
    | Group-Object -Property Date
    | % {
        $EuroNet = ( $_.Group | Measure-Object -Sum PriceCent ).Sum / 100
        [PSCustomObject]@{
            Date       = $_.Name
            EuroNet    = $EuroNet
            EuroBrutto = $EuroNet * 1.2
            kWhDay     = ( $_.Group | Measure-Object -Sum kWh ).Sum
        }
    }
)

$groupPerDay

$SumNet      = ( $groupPerDay | Measure-Object -Sum -Property EuroNet ).Sum
$vat         = $SumNet * 0.2
$gross       = $SumNet + $vat
$awatt       = $gross * 0.03
$daysInMonth = ( $groupPerDay | Measure-Object ).Count
$kwHSum      = ( $groupPerDay | Measure-Object -Sum -Property kWhDay ).Sum
$kWhAverage  = $kwHSum / $daysInMonth

[PSCustomObject]@{
    EuroSumNet  = $SumNet
    Mwst        = $vat
    Awattar     = $awatt
    EuroBrutto  = $SumNet + $vat
    EuroTotal   = $SumNet + $vat + $awatt
    kWhSum      = $kwHSum
    kWhAveragePerDay = $kWhAverage
    CentPerKwH = $SumNet / $kwHSum * 100
} | Format-List