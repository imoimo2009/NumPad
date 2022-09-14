Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

. .\NumPad.ps1

function Form_Shown(){
    $tb.Left = $form.ClientSize.Width / 2 - $tb.Width / 2
    $tb.Top = $form.ClientSize.Height / 2 - $tb.Height
    $bt.Left = $form.ClientSize.Width / 2 - $bt.Width / 2
    $bt.Top = $form.ClientSize.Height / 2 + 16
}

function NumPad_VisibleChanged([object]$own){
    if(-not $own.Visible){
        $tb.Text = $np.Text
    }
}

function Button_Click(){
    $np.Open($tb.Text)
}

$np = New-Object NumPad(0,0,400,480)
$np.Visible = $false
$np.TextLength = 4
$np.Add_VisibleChanged({NumPad_VisibleChanged})

$tb = New-Object System.Windows.Forms.TextBox
$tb.Size = New-Object System.Drawing.Size(100,30)
$tb.Font = New-Object System.Drawing.Font("Meiryo UI",16)
$tb.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center

$bt = New-Object System.Windows.Forms.Button
$bt.Size = New-Object System.Drawing.Size(100,50)
$bt.Text = "Open`nNumPad"
$bt.Add_Click({Button_Click})

$form = New-Object System.Windows.Forms.Form
$form.ClientSize = New-Object System.Drawing.Size($np.Size.Width,$np.Size.Height)
$form.Add_Shown({Form_Shown})

$form.Controls.Add($np)
$form.Controls.Add($tb)
$form.Controls.Add($bt)

$form.ShowDialog() > $null
