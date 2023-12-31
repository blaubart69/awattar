param (
    [Parameter(Mandatory)][string]$filename
)

# curl --request POST \
# "http://localhost:8086/api/v2/write?org=YOUR_ORG&bucket=YOUR_BUCKET&precision=ns" \
#   --header "Authorization: Token YOUR_API_TOKEN" \
#   --header "Content-Type: text/plain; charset=utf-8" \
#   --header "Accept: application/json" \
#   --data-binary '
#     airSensors,sensor_id=TLM0201 temperature=73.97038159354763,humidity=35.23103248356096,co=0.48445310567793615 1630424257000000000
#     airSensors,sensor_id=TLM0202 temperature=75.30007505999716,humidity=35.651929918691714,co=0.5141876544505826 1630424257000000000
#     '

$headers = @{ 
    'Authorization'='Token Tx-tv3oJiXnQf48LNc_4L99qeD3d3Hz3NySh6AjXeaCwzr4pizoTXYx1eeG1o2k83qzorpFBEzO_S9YEQwK2Og==';
    'Content-Type'='text/plain; charset=utf-8';
    'Accept'='application/json'
}

$data = gc -Raw $filename

Invoke-RestMethod `
    -Uri 'http://localhost:8086/api/v2/write?org=beeorg&bucket=spidata&precision=s' `
    -Headers $headers `
    -Method Post `
    -Body $data
    
    
    