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
    IsTextSearchEnabled = "false"
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


<TabControl 
    Margin="20,120,0,0"
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top"
    Width               = "500"
    Height              = "220">
    <TabItem Header="WingetInstallString">
        <Grid Background="#FFE5E5E5">
            <TextBox
                Name                = "WingetInstallString"
                HorizontalAlignment = "Left" 
                VerticalAlignment   = "Top"
                Margin              = "0,0,0,0" 
                Width               = "493"
                Height              = "190"
            />
        </Grid>
    </TabItem>
    <TabItem Header="Installers">
        <Grid Background="#FFE5E5E5">
            <TextBox
                Name                = "Installers"
                HorizontalAlignment = "Left" 
                VerticalAlignment   = "Top"
                Margin              = "0,0,0,0"  
                Width               = "493"
                Height              = "190"
            />
        </Grid>
    </TabItem>
    <TabItem Header="the Comandos">
        <Grid Background="#FFE5E5E5">
            <TextBox
                Name                = "Commandos"
                HorizontalAlignment = "Left" 
                VerticalAlignment   = "Top"
                Margin              = "0,0,0,0"  
                Width               = "493"
                Height              = "190"
            />
        </Grid>
    </TabItem>
</TabControl>







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
$manifestBase = ".\winget-pkgs\manifests"




$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }

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
    $Installers.text = ""
    foreach ($installer in $InstallerInfo.Installers) {
        $Installers.text += "Architecture  :  $($installer.Architecture)
InstallerType :  $(
    if ($installer.InstallerType) {$installer.InstallerType}
    else {
        $InstallerInfo.InstallerType
    }
    )
InstallerUrl  :  $($installer.InstallerUrl)`n"
        if ($installer.InstallerType -eq "inno") {
            $Commandos.text += "$(($installer.InstallerUrl.split("/"))[-1]) /S`n"
        }
        if ($installer.InstallerType -eq "wix") {
        $Commandos.text += "msiexec.exe /i $(($installer.InstallerUrl.split("/"))[-1]) /qb-!`n"
        
        }
        if ($installer.InstallerType -eq "nullsoft") {
            $Commandos.text += "$(($installer.InstallerUrl.split("/"))[-1]) /S`n"
        }
        #$Comandos.text = 
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


$Publisher.AddHandler(
    [System.Windows.Controls.Primitives.TextBoxBase]::TextChangedEvent, 
    [System.Windows.RoutedEventHandler]{ 
        (Get-ChildItem -Directory $manifestBase -Depth 1) | Where-Object -property "name" -like "*$($Publisher.Text)*"| ForEach-Object -begin {$Publisher.Items.Clear()} -Process {
            $Publisher.AddChild($_)
        }
    })


$Window.ShowDialog()
