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

# $groupPerDay

[decimal]$SumNet      = ( $groupPerDay | Measure-Object -Sum -Property EuroNet ).Sum
[decimal]$daysInMonth = ( $groupPerDay | Measure-Object ).Count
[decimal]$kwHSum      = ( $groupPerDay | Measure-Object -Sum -Property kWhDay ).Sum
[decimal]$kWhAverage  = $kwHSum / $daysInMonth

[decimal]$awattar     = 4.73 + [Math]::Abs($SumNet * [decimal]0.03) + ( $kwHSum * [decimal]0.015 )
# magic values           taken from Awattar bill and Wiener Netze "Netzentgelte"
[decimal]$netcosts    = $kwHSum * ( (7.4 + 0.7) / 100 ) + 4.08 + 2.22        
[decimal]$EnergyNet   = $SumNet + $awattar + $netcosts
[decimal]$vat         = $EnergyNet * 0.2

$f = '{0,10:N2}'

[PSCustomObject]@{
    EPEX        = $SumNet
    Awattar     = $awattar
    Netz        = $netcosts
    EnergyNet   = $EnergyNet
    Vat         = $vat
    Brutto      = $EnergyNet + $vat
    EuroEarned  = $CentMinus / 100
    kWhSum      = $kwHSum
    kWhAveragePerDay = $kWhAverage
    CentPerKwH = $SumNet / $kwHSum * 100
} | Format-List -Property @{ e='EPEX'; FormatString=$f },
        @{ e='Awattar'; FormatString=$f },
        @{ e='Netz'; FormatString=$f },
        @{ e='EnergyNet'; FormatString=$f },
        @{ e='Vat'; FormatString=$f },
        @{ e='Brutto'; FormatString=$f },
        @{ e='EuroEarned'; FormatString=$f },
        @{ e='kWhSum'; FormatString=$f },
        @{ e='kWhAveragePerDay'; FormatString=$f },
        @{ e='CentPerKwH'; FormatString=$f }