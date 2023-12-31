# #datatype measurement,tag,double,dateTime:RFC3339
# m,host,used_percent,time
# mem,host1,64.23,2020-01-01T00:00:00Z
# mem,host2,72.01,2020-01-01T00:00:00Z
# mem,host1,62.61,2020-01-01T00:00:10Z
# mem,host2,72.98,2020-01-01T00:00:10Z
# mem,host1,63.40,2020-01-01T00:00:20Z
# mem,host2,73.77,2020-01-01T00:00:20Z

param (
     [int]$year
    ,[int]$month
)

$datakWh   = "$PSScriptRoot/../data/$($Year)-$($month.ToString('00'))_kWh.csv"

'#datatype measurement,double,dateTime:RFC3339'
'm,kWh,time'

& $PSScriptRoot/Convert-WienerNetze.ps1 -filename $datakWh
| Add-Member -MemberType ScriptProperty -Name influxtimeUTC -Value { 
        $this.Timestamp.ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ssZ") 
    } -PassThru
| % {
    "strom,$($_.kWh),$($_.influxtimeUTC)"
}
