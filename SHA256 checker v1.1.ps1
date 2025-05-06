Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Udarbejdet af MA 439859
#For internt brug i CISOC
# d. 06/05/2025
#Version 1.1

# Opret hovedvinduet
$form = New-Object System.Windows.Forms.Form
$form.Text = "SHA-256 File Verifier"
$form.Size = New-Object System.Drawing.Size(500,200)
$form.StartPosition = "CenterScreen"

# Label og tekstfelt til filsti
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

# Label og tekstfelt til forventet hash
$hashLabel = New-Object System.Windows.Forms.Label
$hashLabel.Text = "Expected SHA-256:"
$hashLabel.Location = New-Object System.Drawing.Point(10,60)
$hashLabel.Size = New-Object System.Drawing.Size(120,20)
$form.Controls.Add($hashLabel)

$hashBox = New-Object System.Windows.Forms.TextBox
$hashBox.Location = New-Object System.Drawing.Point(130,58)
$hashBox.Size = New-Object System.Drawing.Size(335,20)
$form.Controls.Add($hashBox)

# Verificer-knap
$verifyButton = New-Object System.Windows.Forms.Button
$verifyButton.Text = "Verify"
$verifyButton.Location = New-Object System.Drawing.Point(200,100)
$verifyButton.Size = New-Object System.Drawing.Size(75,30)
$form.Controls.Add($verifyButton)

# Funktion til at vise brugerdefineret resultatvindue
function Show-CustomResult {
    param (
        [string]$message,
        [string]$title,
        [System.Drawing.Color]$backColor,
        [System.Drawing.Color]$textColor
    )

    $resultForm = New-Object System.Windows.Forms.Form
    $resultForm.Text = $title
    $resultForm.Size = New-Object System.Drawing.Size(800,200)  # Increased width to 800
    $resultForm.StartPosition = "CenterScreen"
    $resultForm.BackColor = $backColor
    $resultForm.TopMost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $message
    $label.ForeColor = $textColor
    $label.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
    $label.AutoSize = $false
    $label.TextAlign = "MiddleCenter"
    $label.Dock = "Fill"
    $resultForm.Controls.Add($label)

    [void]$resultForm.ShowDialog()
}

# Håndter klik på "Browse"-knappen
$browseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "All Files (*.*)|*.*"
    if ($dialog.ShowDialog() -eq "OK") {
        $fileBox.Text = $dialog.FileName
    }
})

# Håndter klik på "Verify"-knappen
$verifyButton.Add_Click({
    $path = $fileBox.Text
    $expected = $hashBox.Text.Trim()

    if (-not (Test-Path $path)) {
        Show-CustomResult -message "File does not exist." -title "Error" -backColor ([System.Drawing.Color]::DarkRed) -textColor ([System.Drawing.Color]::White)
        return
    }
    if ($expected -eq "") {
        Show-CustomResult -message "Please enter an expected SHA-256 hash." -title "Warning" -backColor ([System.Drawing.Color]::Orange) -textColor ([System.Drawing.Color]::Black)
        return
    }

    $actualHash = (Get-FileHash -Path $path -Algorithm SHA256).Hash
    if ($actualHash -eq $expected) {
        Show-CustomResult -message "Hash match! The file is verified." -title "Success" -backColor ([System.Drawing.Color]::DarkGreen) -textColor ([System.Drawing.Color]::White)
    } else {
        $msg = "Hash mismatch:" + [Environment]::NewLine + "Provided hash: $expected" + [Environment]::NewLine + "Actual hash value: $actualHash"
        Show-CustomResult -message $msg -title "Mismatch" -backColor ([System.Drawing.Color]::DarkRed) -textColor ([System.Drawing.Color]::White)
    }
})

# Vis hovedvinduet
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
