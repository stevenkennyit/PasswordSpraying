#Uncomment the 3 lines below to install AADInternals 
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Install-Module AADInternals -Scope CurrentUser
Import-Module AADInternals 

#Authenticate and get access token for AzureAD
$creds = Get-Credential 
$token = Get-AADIntAccessTokenForAADGraph -Credentials $creds -Verbose 
$headers = @{
    Authorization="Bearer $token"
}

#Craft base URL: https://graph.windows.net/TENANT-ID/users?
$tenant = Get-AADIntTenantDetails -AccessToken $token

#Alphabet to cycle through 
$alpha_range = 97..(97+25) | % { [char]$_ }

foreach($letter in $alpha_range){

    #Craft URI 
    $uri = 'https://graph.windows.net/<TENANTID>/users?'
    $uri = $uri -replace "<TENANTID>", $tenant.objectID
    $uri += '$top=999'
    $uri += '&$filter' + "=startswith(userPrincipalName,'" +$letter + "')"
    $uri += "&api-version=1.61-internal"


    $results = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    $results.value | select UserPrincipalName | Export-Csv c:\temp\Azure_Users_Dumped.csv -NoTypeInformation -Append
    
}