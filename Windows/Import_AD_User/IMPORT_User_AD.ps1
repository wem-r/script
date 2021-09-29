cls
Import-Module ActiveDirectory

$PathCSV = "C:\Users\Administrateur\Desktop\script\1K_Users.csv" # <----- To Change (Tip: Shift+Right clic on the CSV, then "Copy as Path".)

$Users = Import-Csv -Delimiter ";" -Path $PathCSV

foreach ($User in $Users)
{
    if ((Get-ADOrganizationalUnit -Filter {Name -eq $OU}) -eq $null) {
        Write-Output "The Organizational Unit '$OU' does not exist, creating now..."
        Try {
            New-ADOrganizationalUnit -Name $OU -Path "DC=$Domain,DC=$Ext"
            echo "New OU '$OU' created"
            echo ""
                }
        Catch{
            echo "The Organizational Unit $OU already exist"
            echo ""
                }
                                                                        }
    Else {
        Write-Output "The Organizational Unit '$OU' already exist"
            }


    $Domain = "no" # <------------- To Change
    $Ext = "lan" # <--------------- To Change
    $Server = "dc1.no.lan" # <-- To Change
    $Password = "CHANGE_ME"   # <-- To Change - If you choose a pwd that doesn't meet the Password Policy (if it wasn't changed) the accounts will be disabled. even when '-Enabled $true' is used
    
    $Surname = $User.Surname
    $GivenName = $User.GivenName
    $Name = $GivenName.ToUpper() + " " + $Surname
    $SAM = $Surname.ToLower()[0] + $GivenName.ToLower()
    $UPN = $Surname.ToLower()[0] + $GivenName.ToLower()
    $EmailAddress = $SAM.ToLower() + "@" + $Domain.ToLower() + "." + $Ext.ToLower()
    $Displayname = $Surname.ToLower() + " " + $GivenName.ToUpper()
    $OU = $User.OU



    if ((Get-ADUser -Filter {SamAccountName -eq $SAM}) -eq $null) {
        Write-Output "User '$Name' not found, adding now..."
        Try {
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
    echo "New User '$Name' added in the '$OU' OU"
    echo ""
                }
    Catch{
        echo "User '$Name' already present"
            }
                                                                    }
    }
