#Authenticate and get access token for AzureAD
$creds = Get-Credential 
$token = Get-AADIntAccessTokenForAADGraph -Credentials $creds -Verbose 
$headers = @{
    Authorization="Bearer $token"
}

#Craft base URL: https://graph.windows.net/TENANT-ID/users?
$tenant = Get-AADIntTenantDetails -AccessToken $token


$countryCodes = @(
"SG"
"CN"
"HK"
"ID"
"MY"
"AU"
"TW"
"JP"
)

foreach($c in $countryCodes){
    #Craft URI 
    $uri = 'https://graph.windows.net/<TENANTID>/users?'
    $uri = $uri -replace "<TENANTID>", $tenant.objectID
    $uri += '$top=999'
    $uri += '&$filter' + "=startswith(usageLocation,'" + $c + "')"
    $uri += "&api-version=1.61-internal"

    $results = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers

    $results.value | select mail | Export-Csv c:\temp\apac_users.csv -NoTypeInformation -Append
}