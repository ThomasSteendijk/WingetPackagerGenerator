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
    />
<ComboBox 
    Name                = "Version"
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top"
    Margin              = "20,80,0,0" 
    Width               = "500" 
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
if (!(Test-Path -Path  .\winget-pkgs.zip)) {
    Invoke-WebRequest -Uri "https://codeload.github.com/microsoft/winget-pkgs/zip/refs/heads/master" -UseBasicParsing -OutFile .\winget-pkgs.zip
    Expand-Archive -Path .\winget-pkgs.zip
}

$manifestBase = ".\winget-pkgs\winget-pkgs-master\manifests"



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
    $Application.SelectedItem
    $Version.Items.Clear()
    Get-ChildItem -Directory $Application.SelectedItem.FullName | foreach -Process {$Version.AddChild($_)}
    })

$LogDir = "E:\StorageFolder\Thomas\_Projects\TimeLogging"
$clear.Add_Click({$Notes.text = "Hello`n`rHello"})
$Log.Add_Click({
$Publisher.AddChild("hello")
    #$Notes.text | out-file $LogDir\$(get-date -Format yyyyMMddHHmmss)_timeLog.md -Encoding UTF8 
})




$Window.ShowDialog()


