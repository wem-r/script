Import-Module ActiveDirectory
$Users = Import-Csv -Delimiter ";" -Path "C:\Users\Administrateur\Desktop\script\1K_Users.csv"

foreach ($User in $Users)
{
    $Domain = "no" # <------------- To Change
    $Ext = "lan" # <--------------- To Change
    $Server = "ssprad.no.lan" # <-- To Change
    $Password = "CHANGE_ME"   # <-- To Change - If you choose a pwd that doesn't meet the Password Policy (if it wasn't changed) the accounts will be disabled. even when '-Enabled $true' is used
    
    $Surname = $User.Surname
    $GivenName = $User.GivenName
    $Name = $GivenName.ToUpper() + " " + $Surname
    $SAM = $Surname.ToLower()[0] + $GivenName.ToLower()
    $UPN = $Surname.ToLower()[0] + $GivenName.ToLower()
    $EmailAddress = $SAM.ToLower() + "@" + $Domain.ToLower() + "." + $Ext.ToLower()
    $Displayname = $Surname.ToLower() + " " + $GivenName.ToUpper()
    $OU = $User.OU

	Try{
    New-ADOrganizationalUnit -Name $OU -Path "DC=$Domain,DC=$Ext"
    
        echo "New OU $OU created"
    }
    catch{
        echo "The Organizational Unit $OU already exist"
    }
	Try{
	New-ADUser -Surname $Surname `
               -Name $Name `
               -GivenName $GivenName `
               -SamAccountName $SAM `
               -UserPrincipalName $UPN `
               -EmailAddress $EmailAddress `
               -DisplayName $Displayname `
               -AccountPassword:(ConvertTo-SecureString -AsPlainText $Password -Force) `
               -Enabled $true `
               -Path "OU=$OU,DC=$Domain,DC=$Ext" `
               -ChangePasswordAtLogon $false `
               –PasswordNeverExpires $true `
               -server $Server
	
        echo "New User : $Name"
	}
	catch{
	    echo "User not created: $Name"
	}

}
