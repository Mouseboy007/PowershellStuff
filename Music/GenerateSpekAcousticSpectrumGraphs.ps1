###################################################################
#                                                                 #
#             GenerateSpekAcousticSpectrumGraphs.Ps1              #
#                     Andy Pyne 2020.06.10                        #
#                                                                 #
#               Using AlternativeSpek found here:                 #
#     https://github.com/withmorten/spek-alternative/issues/1     #
#                                                                 #
###################################################################

# Point to Alternative Spek executable and your Music path:
$AlternativeSpekExecutable = 'D:\OneDrive\Music Other\Tools\MusicManagement\Spek (Alternative version with command line support)\spek.exe' 
$MusicPath = 'D:\Music\Rolling Stones\Forty Licks'

# Set an Alias to call
Set-Alias Spek $AlternativeSpekExecutable

# Set Music File types to scan
$MusicFileTypes = "mp3|m4a|flac|wav|ogg|wv"

# Get a list of all your music files
$MusicFiles = Get-ChildItem -LiteralPath $MusicPath -Recurse | Where-Object {$_.Extension -Match $MusicFileTypes}

# Loop through each music file and output a graph in the same location with the same name plus a png extension (simples!)
ForEach ($MusicFile in $MusicFiles) 
{ 
    $Folder = ((Get-Item -LiteralPath $MusicFile.FullName).Directory).FullName
    $File = "$($MusicFile.Name)$(".png")"
    Spek $MusicFile.FullName "$($Folder)$('\')$($File)" 
    Write-Host "$($Folder)$($File)"
}
