
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
<TextBox 
    HorizontalAlignment = "Left" 
    VerticalAlignment   = "Top" 
    Height              = "324" 
    Width               = "665" 
    TextWrapping        = "Wrap" 
    Margin              = "21,17,0,0" 
    Name                = "Notes"

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

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }

$LogDir = "E:\StorageFolder\Thomas\_Projects\TimeLogging"
$clear.Add_Click({$Notes.text = "Hello`n`rHello"})
$Log.Add_Click({
    $Notes.text | out-file $LogDir\$(get-date -Format yyyyMMddHHmmss)_timeLog.md -Encoding UTF8 
})

$Notes.text = "Subject`t: `n`nNotes`t: `n"



$Window.ShowDialog()


