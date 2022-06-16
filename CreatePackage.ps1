cd $PSScriptRoot
#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#

Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="800" Height="400">
<Grid>


<Button 
    Content             = "Clear" 
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top" 
    Width               = "75" 
    Margin              = "700,18,0,0" 
    Name                = "clear"
    />
<Button 
    Content             = "Log" 
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top" 
    Width               = "75" 
    Margin              = "701,322,0,0" 
    Name                = "Log"
    />
<ComboBox 
    Name                = "Publisher"
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top"
    Margin              = "20,20,0,0" 
    Width               = "500" 
    IsTextSearchEnabled = "True"
    IsEditable          = "True"
    />

<ComboBox 
    Name                = "Application"
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top"
    Margin              = "20,50,0,0" 
    Width               = "500" 
    IsTextSearchEnabled = "True"
    IsEditable          = "True"
    />
<ComboBox 
    Name                = "Version"
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top"
    Margin              = "20,80,0,0" 
    Width               = "500" 
    />
<TextBox
    Name                = "WingetInstallString"
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top"
    Margin              = "20,120,0,0" 
    Width               = "500"
    />
<TextBox
    Name                = "Installers"
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top"
    Margin              = "20,140,0,0" 
    Width               = "500"
    Height              = "50"
    />
<TextBox
    Name                = "TextBox"
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top"
    Margin              = "20,200,0,0" 
    Width               = "500"
    Height              = "140" 
    />

</Grid>
</Window>
"@

#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#


#region Logic
#Write your code here
#endregion 
#region section

#endregion 


#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#


$ProgressPreference = "SilentlyContinue"
<#
if (!(Test-Path -Path  .\winget-pkgs.zip)) {
    Invoke-WebRequest -Uri "https://codeload.github.com/microsoft/winget-pkgs/zip/refs/heads/master" -UseBasicParsing -OutFile .\winget-pkgs.zip
    Expand-Archive -Path .\winget-pkgs.zip
}
#>

$manifestBase = ".\winget-pkgs\manifests"




$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }


#$Publisher.IsTextSearchEnabled = $true

Get-ChildItem -Directory $manifestBase -Depth 1 | foreach -Process {
    $Publisher.AddChild($_)
}

$Publisher.Add_SelectionChanged({
    write-host "Selected"
    $Application.Items.Clear()
    $Version.Items.Clear()
    Get-ChildItem -Directory $Publisher.SelectedItem.FullName | foreach -Process {$Application.AddChild($_)}
    })

$Application.Add_SelectionChanged({
    if ($Application.SelectedItem -ne $null) 
    {
        $Version.Items.Clear()
        Get-ChildItem -Directory $Application.SelectedItem.FullName -Recurse | foreach -Process {
            if (Get-ChildItem $_.FullName -File -ErrorAction SilentlyContinue) {$Version.AddChild($_)}
        }
    }
    }
    )
$Version.Add_SelectionChanged({
    $InstallerInfo            = Get-ChildItem $Version.SelectedItem.FullName -Filter "*installer.yaml" | Get-Content |convertfrom-yaml
    $TextBox.text             = "$($InstallerInfo |convertto-json |Out-String)"
    $WingetInstallString.text = "winget install $($InstallerInfo.PackageIdentifier) -v $($Version.SelectedItem.name)"
    #$Installers.text = ""
    $Installers.text.clear()
    foreach ($installer in $InstallerInfo.Installers) {
        $Installers.text += "Architecture  :  $($installer.Architecture)
InstallerType :  $($installer.InstallerType)
InstallerUrl  :  $($installer.InstallerUrl)`n"
    }
    
    
    #$TextBox.text = "$($_|Out-String) - hi $(Get-date)"
})
#Get-ChildItem $_.FullName -Filter "*installer.yaml" | Get-Content |convertfrom-yaml |convertto-json |Out-String
$LogDir = "E:\StorageFolder\Thomas\_Projects\TimeLogging"
$clear.Add_Click({$Notes.text = "Hello`n`rHello"})
$Log.Add_Click({
$Publisher.AddChild("hello")
    #$Notes.text | out-file $LogDir\$(get-date -Format yyyyMMddHHmmss)_timeLog.md -Encoding UTF8 
})




$Window.ShowDialog()


