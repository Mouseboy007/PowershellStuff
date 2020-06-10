###################################################################
#                                                                 #
#                    FixFakinFunkRename.Ps1                       #
#                     Andy Pyne 2020.06.10                        #
#                                                                 #
#   If you've ever used Fakin' the Funk and accidentally renamed  #
#   all your files with the tool causing them to have a suffix    #
#   which contains the bitrate in square-brackets, this script    # 
#   will help reverse that                                        #
#                                                                 #
###################################################################

Clear
# Set the path in which your renamed music resides
$Path = 'D:\OneDrive\Music'

# Scan the directory for files that match '[Real' which is how the Fakin' the Funk renamed files are named
$AllItems = (Get-ChildItem -LiteralPath $Path -Recurse) | Where-Object {$_.Name -Match '\[Real'}

# This is the range of 'Real' bitrates you want to scan for
$Bitrate = 0..320

# Iterate through each track
ForEach ($Item in $AllItems) {
Write-Host $Item.FullName -ForegroundColor Yellow

# A bit of RegEx escaping as the square brackets are special characters
# What this is doing is setting the BitRename variable to the [Real <bitrate>] in question
$Bitrate | ForEach-Object {
    $BitRename = [Regex]::Escape("$('[Real ')$($_)$(']')")

    # If the track matches the [Real <bitrate>] in question, rename it back
    If ($Item.FullName -match $BitRename) {
    Rename-Item -LiteralPath $Item.Fullname ($Item.FullName -Replace "$(' ')$($BitRename)")
    Write-Host $Item.Fullname ($Item.FullName -Replace "$(' ')$($BitRename)") -ForegroundColor Magenta}
    }

}