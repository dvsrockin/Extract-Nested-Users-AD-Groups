Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Nested AD Group Members Export"
$form.Size = New-Object System.Drawing.Size(600,300)

# Create the input fields and labels
$groupnameLabel = New-Object System.Windows.Forms.Label
$groupnameLabel.Text = "Group Name:"
$groupnameLabel.Location = New-Object System.Drawing.Point(10,20)
$form.Controls.Add($groupnameLabel)

$groupnameTextBox = New-Object System.Windows.Forms.TextBox
$groupnameTextBox.Location = New-Object System.Drawing.Point(120,20)
$groupnameTextBox.Size = New-Object System.Drawing.Size(400, 20)

$form.Controls.Add($groupnameTextBox)

$domainLabel = New-Object System.Windows.Forms.Label
$domainLabel.Text = "Domain:"
$domainLabel.Location = New-Object System.Drawing.Point(10,60)
$form.Controls.Add($domainLabel)

$domainTextBox = New-Object System.Windows.Forms.TextBox
$domainTextBox.Location = New-Object System.Drawing.Point(120,60)
$domainTextBox.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($domainTextBox)

$propertiesLabel = New-Object System.Windows.Forms.Label
$propertiesLabel.Text = "Properties:"
$propertiesLabel.Location = New-Object System.Drawing.Point(10,100)
$form.Controls.Add($propertiesLabel)

$propertiesTextBox = New-Object System.Windows.Forms.TextBox
$propertiesTextBox.Location = New-Object System.Drawing.Point(120,100)
$propertiesTextBox.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($propertiesTextBox)

$filepathLabel = New-Object System.Windows.Forms.Label
$filepathLabel.Text = "File Path:"
$filepathLabel.Location = New-Object System.Drawing.Point(10,140)
$form.Controls.Add($filepathLabel)

$filepathTextBox = New-Object System.Windows.Forms.TextBox
$filepathTextBox.Location = New-Object System.Drawing.Point(120,140)
$filepathTextBox.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($filepathTextBox)

# Create the button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Export"
$button.Location = New-Object System.Drawing.Point(150,180)
$form.Controls.Add($button)

# Add the button click event
$button.Add_Click({
    $groupname = $groupnameTextBox.Text
    $domain = $domainTextBox.Text
    $properties = $propertiesTextBox.Text
    $filepath = $filepathTextBox.Text

    # Your existing script logic here
    If(!(Test-Path $Filepath)){ 
        if($filepath.Split("/")[-1] -like "*.CSV"){
            Try{
                    New-Item -Path $filepath -ItemType File
            }
            Catch{
                    [System.Windows.Forms.MessageBox]::Show("Error: $($Error[0].exception.message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                    exit
            }
        }
        Else{
                [System.Windows.Forms.MessageBox]::Show("Please enter file name of .CSV format", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                exit
        }
    }

    $group0s = (Get-ADGroup -Identity $groupname -Server $Domain).DistinguishedName
    $listUsers = @()
    $refGroups = @()
    $loop = 10
    $ctr = 0
    do {
        $ctr += 1
        $group1s = @()
        foreach ($group0 in $group0s) {
            $Domain0  = $group0.Substring("$group0".IndexOf("DC=")).Replace("DC=","").Replace(",",".")
            $members = (Get-ADGroup $group0 -Properties members -Server $Domain0 | select -ExpandProperty members)
            foreach ($member in $members) {
                $Domain  = $member.Substring("$member".IndexOf("DC=")).Replace("DC=","").Replace(",",".")
                $ObjectClass = (Get-ADObject $member -Server $Domain).ObjectClass
                Switch ($ObjectClass) {
                    "user" {
                            $listUsers += $member
                    }
                    "group" {
                        if ($refGroups -notcontains $member) {
                            $refGroups += $member
                            $group1s += $member
                        }
                     }
                }
            }
            if ($Group1s.count -eq 0) {
                $loop = 0
            }
            else {
                $group0s = $group1s
                $loop = $loop - 1
            }
        }
    }
    while ($loop -gt 0)

    $listUsers = ($listUsers | Sort-Object -Unique)
    If(($listUsers | Measure-object).count -gt "0"){

        $GC = (Get-ADDomainController -Filter {IsGlobalCatalog -eq $true} | Select-Object -ExpandProperty hostname)[0] + ":3268"
        $Propertiesarray = $Properties.split(",")

        $listUsers |  ForEach-Object { 
                            Get-ADUser -Identity $_ -Properties $Propertiesarray -Server $GC  | Select-Object $Propertiesarray |
                                    Export-Csv $filepath -Append -NoTypeInformation
                        [System.Windows.Forms.MessageBox]::Show("Export completed successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                    }
    }
    Else{
            [System.Windows.Forms.MessageBox]::Show("The AD group has zero users!", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Exclamation)
    }
})

# Show the form
$form.ShowDialog()