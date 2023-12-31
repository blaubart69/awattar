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

# Syntax
# <measurement>[,<tag_key>=<tag_value>[,<tag_key>=<tag_value>]] <field_key>=<field_value>[,<field_key>=<field_value>] [<timestamp>]

# Example
# myMeasurement,tag1=value1,tag2=value2 fieldKey="fieldValue" 1556813561098000000

$datakWh   = "$PSScriptRoot/../data/$($Year)-$($month.ToString('00'))_kWh.csv"

& $PSScriptRoot/Convert-WienerNetze.ps1 -filename $datakWh
| % {
    $UnixSeconds = Get-Date -UFormat %s ([datetime]$_.Timestamp).ToUniversalTime()
    "strom kWh=$($_.kWh) $($UnixSeconds)"
}
