$outDir = "C:\Temp"
$outFile = Join-Path $outDir "HotelInfo.txt"

# Check if file exists at the very start
if (Test-Path $outFile) {
    return  # Exit the script silently
}

# Make sure the output directory exists
if (!(Test-Path $outDir)) { New-Item -Path $outDir -ItemType Directory | Out-Null }

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "IT Inventory Update"
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.ControlBox = $false     # disable X/min/max
$form.ClientSize = New-Object System.Drawing.Size(420,300)
$form.Padding = New-Object System.Windows.Forms.Padding(10)

# TableLayoutPanel for tidy automatic layout
$table = New-Object System.Windows.Forms.TableLayoutPanel
$table.Dock = [System.Windows.Forms.DockStyle]::Fill
$table.AutoSize = $true
$table.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$table.ColumnCount = 2

# Column: labels fixed width, inputs take remaining
$table.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute,120)))
$table.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,100)))

# We'll add rows as controls are added (use AutoSize RowStyles)
for ($i = 0; $i -lt 6; $i++) {
    $table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
}

# Instruction label (spans two columns and wraps)
$labelInstruction = New-Object System.Windows.Forms.Label
$labelInstruction.Text = "Please complete the following inventory information for this workstation."
$labelInstruction.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$labelInstruction.AutoSize = $true
$labelInstruction.MaximumSize = New-Object System.Drawing.Size(380,0)   # wrap at ~380px
#$labelInstruction.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$table.Controls.Add($labelInstruction, 0, 0)
$table.SetColumnSpan($labelInstruction, 2)

# Hotel Name
$lblHotel = New-Object System.Windows.Forms.Label
$lblHotel.Text = "Hotel Name:"
$lblHotel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblHotel.AutoSize = $true
$table.Controls.Add($lblHotel, 0, 1)

$textHotel = New-Object System.Windows.Forms.TextBox
$textHotel.Dock = [System.Windows.Forms.DockStyle]::Fill
$table.Controls.Add($textHotel, 1, 1)

# Business Unit
$lblBU = New-Object System.Windows.Forms.Label
$lblBU.Text = "Business Unit:"
$lblBU.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblBU.AutoSize = $true
$table.Controls.Add($lblBU, 0, 2)

$textBU = New-Object System.Windows.Forms.TextBox
$textBU.Dock = [System.Windows.Forms.DockStyle]::Fill
$table.Controls.Add($textBU, 1, 2)

# Phone Number
$lblPhone = New-Object System.Windows.Forms.Label
$lblPhone.Text = "Phone Number:"
$lblPhone.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$lblPhone.AutoSize = $true
$table.Controls.Add($lblPhone, 0, 3)

$textPhone = New-Object System.Windows.Forms.TextBox
$textPhone.Dock = [System.Windows.Forms.DockStyle]::Fill
$table.Controls.Add($textPhone, 1, 3)

# OK button - disabled until fields filled
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.AutoSize = $true
$okButton.Enabled = $false
# Center the button by spanning two columns and not anchoring it
$table.Controls.Add($okButton, 0, 5)
$table.SetColumnSpan($okButton, 2)
$okButton.Anchor = [System.Windows.Forms.AnchorStyles]::None
$okButton.Margin = New-Object System.Windows.Forms.Padding(0,12,0,0)

# Validation function: enable OK only when all fields have non-empty trimmed text
$validate = {
    if ($textHotel.Text.Trim() -ne "" -and $textBU.Text.Trim() -ne "" -and $textPhone.Text.Trim() -ne "") {
        $okButton.Enabled = $true
    } else {
        $okButton.Enabled = $false
    }
}

# Wire up TextChanged events
$textHotel.Add_TextChanged($validate)
$textBU.Add_TextChanged($validate)
$textPhone.Add_TextChanged($validate)

# OK click: save silently and close
$okButton.Add_Click({
    $outDir = "C:\Temp"
    if (!(Test-Path $outDir)) { New-Item -Path $outDir -ItemType Directory | Out-Null }

    $output = @"
Hotel Name: $($textHotel.Text.Trim())
Business Unit: $($textBU.Text.Trim())
Phone Number: $($textPhone.Text.Trim())
"@

    $output | Set-Content -Path (Join-Path $outDir "HotelInfo.txt") -Encoding UTF8
    $form.Close()
})

$form.Controls.Add($table)
$form.TopMost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
