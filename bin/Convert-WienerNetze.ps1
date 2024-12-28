param (
    [Parameter(Mandatory)][string]$filename
)

  Import-Csv -Delimiter ';' $filename -Header date,starttime,endtime,kwh 
| Select-Object -Skip 1 
| Where-Object { -not [String]::IsNullOrEmpty($_.kwh)  } 
| Add-Member -MemberType ScriptProperty -Name Hour -Value { ($this.starttime -split ':')[0] } -PassThru 
| Group-Object -Property date,Hour
| ForEach-Object {
    ($date,$hour) = $_.Name -split ','  
    $kWhHour = ($_.Group | % { ($_.kWh -replace ',','.') -as [double] } | Measure-Object -Sum).Sum

    $intHours = [System.Convert]::ToInt32( $hour )
    $timestamp = [datetime]::ParseExact($date,'dd.MM.yyyy', [System.Globalization.CultureInfo]::InvariantCulture )
    $timestamp = $timestamp.AddHours($intHours)

    [PSCustomObject]@{
        Date = $date
        Hour = $hour
        Timestamp = $timestamp
        kWh = $kWhHour
        kWhx1000 = ($kWhHour * 1000) -as [int]
    }
}