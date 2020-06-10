#############################################
#                                           #
#        CheckOpusConversations.Ps1         #
#          Andy Pyne 2020.06.10             #
#                                           #
#    Effectively comparing two sets of      # 
#    identical directories containing       #
#    music to see if all files exist in     #
#    Opus format too                        #
#    I basically have all my music          #
#    Transcoded to 128k Opus for my phone   #
#    and want to ensure I have everything   #
#    from my collection transcoded - and    #
#    likewise if I delete an source track   #
#    I want to identify it so I can remove  #
#    the Opus orphan                        #
#                                           #
#############################################

Clear

# Set the source music path and the Opus transcoded music path
$OriginalMusicPath = "D:\OneDrive\Music"
$OpusMusicPath = "E:\Music Temp\Opus"

# Set the source music file types to scan for 
$OriginalMusicFileTypes = "mp3|m4a|flac|wav|ogg"

# Set the opus file extension
$OpusMusicFileType = "opus"

# Get a list of all the source music
$OriginalMusicList = (Get-ChildItem -LiteralPath $OriginalMusicPath -Recurse | Where-Object {$_.Extension -Match $OriginalMusicFileTypes}).FullName

# Get a list of all the Opus music
$OpusMusicList = (Get-ChildItem -LiteralPath $OpusMusicPath -Recurse | Where-Object {$_.Extension -Match $OpusMusicFileType}).Fullname

# Crop the contents of the source and opus file lists to remove the source path and file extension
$CroppedOriginalMusicList = $OriginalMusicList | ForEach-Object {$_ -Replace [RegEx]::Escape($OriginalMusicPath) -Replace (($_ -Split "\.") | Select-Object -Last 1) -Replace ".{1}$"}
$CroppedOpusMusicList = $OpusMusicList | ForEach-Object {$_ -Replace [RegEx]::Escape($OpusMusicPath) -Replace ".{5}$"}

# With the base directories and extensions removed, we should be able to compare like-for-like
$CompareMusic = Compare-Object $CroppedOriginalMusicList $CroppedOpusMusicList

# To make it easier to view, we'll rename the Sideindicator property to reflect where the file exists that doesn't have a matching counterpart
$CompareMusic | ForEach-Object  {If ($_.Sideindicator -eq '=>') {$_.Sideindicator = "Opus Only"} If ($_.Sideindicator -eq '<=') {$_.Sideindicator = "Original Only"}}

# Output the differences track by tract
Write-Host
Write-Host $CompareMusic.Count " Differences" -ForegroundColor Yellow
$CompareMusic | Select-Object SideIndicator,InputObject

# Strip off all the tracks and just see which album paths are different
$Albums = New-Object System.Collections.ArrayList
$CompareMusic.InputObject | ForEach-Object {$Albums.Add(($_ -Split '\\')[1..((($_ -Split '\\').Count)-2)] -Join "\")} | Out-Null
$Albums = $Albums | Sort-Object -Unique

Write-Host
Write-Host $Albums.Count " Album Differences" -ForegroundColor Yellow
$Albums
