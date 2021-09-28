Import-Module ActiveDirectory
$Users = Import-Csv -Delimiter ";" -Path "C:\Users\Administrator\Desktop\1K_Users.csv"

foreach ($User in $Users)
{
    $Domain = "kmr"
    $Ext = "lan"
    $Surname = $User.Surname
    $Name = $User.Name
    $GivenName = $User.GivenName
    $SAM = $User.SamAccountName
    $UPN = $User.UserPrincipalName
    $EmailAddress = $User.EmailAdress
    $Displayname = $User.DisplayName
    $OU = $User.OU
    $Server = "dc1.kmr.lan"
    $Password = "CHANGE_ME" # If you chose a pwd that doesn't meet the Password Policy (if it wasn't changed) the accounts will be disabled. even when '-Enabled $true' is used
	
	Try{
    New-ADOrganizationalUnit -Name $OU -Path "DC=$Domain,DC=$Ext"
    
        echo "New OU $OU created"
    }
    catch{
        echo "The Organizational Unit $OU already exist"
    }
	Try{
	New-ADUser -Surname $Surname -Name $Name -GivenName $GivenName -SamAccountName $SAM -UserPrincipalName $UPN -EmailAddress $EmailAddress -DisplayName $Displayname -AccountPassword:(ConvertTo-SecureString -AsPlainText $Password -Force) -Enabled $true -Path "OU=$OU,DC=$Domain,DC=$Ext" -ChangePasswordAtLogon $false –PasswordNeverExpires $true -server $Server
	
        echo "New User : $Name"
	}
	catch{
	    echo "User not created: $Name"
	}

}
