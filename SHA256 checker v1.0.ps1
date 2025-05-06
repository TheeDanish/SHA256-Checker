Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Udarbejdet af MA 439859
#For internt brug i CISOC
# d. 06/05/2025
#Version 1.0


# Opret vinduet
$form = New-Object System.Windows.Forms.Form
$form.Text = "SHA-256 File Verifier"
$form.Size = New-Object System.Drawing.Size(500,200)
$form.StartPosition = "CenterScreen"

# Label og tekstboks til filsti
$fileLabel = New-Object System.Windows.Forms.Label
$fileLabel.Text = "Select File:"
$fileLabel.Location = New-Object System.Drawing.Point(10,20)
$fileLabel.Size = New-Object System.Drawing.Size(60,20)
$form.Controls.Add($fileLabel)

$fileBox = New-Object System.Windows.Forms.TextBox
$fileBox.Location = New-Object System.Drawing.Point(80,18)
$fileBox.Size = New-Object System.Drawing.Size(300,20)
$form.Controls.Add($fileBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse"
$browseButton.Location = New-Object System.Drawing.Point(390,16)
$browseButton.Size = New-Object System.Drawing.Size(75,23)
$form.Controls.Add($browseButton)

# Label og tekstboks til forventet hash
$hashLabel = New-Object System.Windows.Forms.Label
$hashLabel.Text = "Expected SHA-256:"
$hashLabel.Location = New-Object System.Drawing.Point(10,60)
$hashLabel.Size = New-Object System.Drawing.Size(120,20)
$form.Controls.Add($hashLabel)

$hashBox = New-Object System.Windows.Forms.TextBox
$hashBox.Location = New-Object System.Drawing.Point(130,58)
$hashBox.Size = New-Object System.Drawing.Size(335,20)
$form.Controls.Add($hashBox)

# Knap til at verificere
$verifyButton = New-Object System.Windows.Forms.Button
$verifyButton.Text = "Verify"
$verifyButton.Location = New-Object System.Drawing.Point(200,100)
$verifyButton.Size = New-Object System.Drawing.Size(75,30)
$form.Controls.Add($verifyButton)

# Hændelse for "Gennemse"-knap
$browseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "All Files (*.*)|*.*"
    if ($dialog.ShowDialog() -eq "OK") {
        $fileBox.Text = $dialog.FileName
    }
})

# Hændelse for "Verificer"-knap
$verifyButton.Add_Click({
    $path = $fileBox.Text
    $expected = $hashBox.Text.Trim()

    if (-not (Test-Path $path)) {
        [System.Windows.Forms.MessageBox]::Show("File does not exist.", "Error", 'OK', 'Error')
        return
    }
    if ($expected -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Please enter an expected SHA-256 hash.", "Error", 'OK', 'Warning')
        return
    }

    $actualHash = (Get-FileHash -Path $path -Algorithm SHA256).Hash
    if ($actualHash -eq $expected) {
        [System.Windows.Forms.MessageBox]::Show("Hash match: The file is verified.", "Result", 'OK', 'Information')
    } else {
        [System.Windows.Forms.MessageBox]::Show("Hash mismatch:" + [Environment]::NewLine + "Provided hash: $expected" + [Environment]::NewLine + "Actual hash value: $actualHash", "Result", 'OK', 'Error')
    }
})

# Vis vinduet
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
