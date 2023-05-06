param (
    [Parameter(Mandatory)][string]$filename
)
Import-Csv -Delimiter ';' $filename | 
% { 
    $a=($_.start -split ' '); 
    [double]$price = $_.baseprice -as [double]

    $intHours = [System.Convert]::ToInt32( $a[1].substring(0,2) )
    $timestamp = [datetime]::ParseExact($a[0],'dd.MM.yyyy', [System.Globalization.CultureInfo]::InvariantCulture )
    $timestamp = $timestamp.AddHours($intHours)

    [PSCustomObject]@{
        Date      = $a[0]
        Hour      = $a[1].substring(0,2)
        Timestamp = $timestamp
        baseprice = $_.baseprice
        CentkWh   = $price
        Centx100  = $price*100 -as [int]
    }
}
