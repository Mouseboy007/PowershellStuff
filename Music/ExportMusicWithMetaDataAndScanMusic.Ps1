###################################################################
#                                                                 #
#            ExportMusicWithMetaDataAndScanMusic.Ps1              #
#                     Andy Pyne 2020.06.10                        #
#                                                                 #
# Using this modified script:                                     #
# Script: Get-FileMetaDataReturnObject.ps1                        #
# Author: ed wilson, msft                                         #
#                                                                 #
# ...which was modified to allow for individual files to have     #
# their metadata exported (and not just full directories) plus    #
# a few tweaks in how the metadata is enumerated to make it a     #
# little faster                                                   # 
#                                                                 #
# The script will do two things:                                  #
# 1) Allow you to export all your music with metadata to a CSV    #
# 2) Find the tracks that match a particular key word or phrase,  #
#    for example, 'ma cig wi' would match 'Man with the Cigar',   #
#    it doesn't matter if you use part words or what order you    #
#    type in the words                                            #
#                                                                 #
###################################################################

# Ed Wilson's Script (modified):

# -----------------------------------------------------------------------------
# Script: Get-FileMetaDataReturnObject.ps1
# Author: ed wilson, msft
# Date: 01/24/2014 12:30:18
# Keywords: Metadata, Storage, Files
# comments: Uses the Shell.APplication object to get file metadata
# Gets all the metadata and returns a custom PSObject
# it is a bit slow right now, because I need to check all 266 fields
# for each file, and then create a custom object and emit it.
# If used, use a variable to store the returned objects before attempting
# to do any sorting, filtering, and formatting of the output.
# To do a recursive lookup of all metadata on all files, use this type
# of syntax to call the function:
# Get-FileMetaData -folder (gci e:\music -Recurse -Directory).FullName
# note: this MUST point to a folder, and not to a file.
# -----------------------------------------------------------------------------

Function Get-FileMetaData(
    [string[]]$folders,
    [string[]]$properties,
    [string[]]$filekeywords
) {
    $shellApp = New-Object -ComObject Shell.Application
    # get all headers and find their indexes
    $shellFolder = $shellApp.namespace($folders[0])
    $allProps = @{}
    foreach ($index in 0..266) {
        $allProps[$shellFolder.getDetailsOf($shellFolder.items, $index)] = $index
    }
    $supportsOrdered = $PSVersionTable.PSVersion.Major -ge 3
    $hash = if ($supportsOrdered) { [ordered]@{} } else { @{} }
    # walk the folders and get the properties by index found above
    $folders | ForEach {
        $shellFolder = $shellApp.namespace($_)
        $shellFolder.items() | ForEach {
            $file = $_
            
            #Write-Host $_.Name -ForegroundColor Yellow
            If ($FileKeywords -eq $Null) {$FileKeywordSearch = ($File | Select Name)} Else {$FileKeywordSearch = $FileKeywords}
            If (($file | Select Name) | Select-String -Pattern ([RegEx]::Escape($FileKeywordSearch))) {
            
            $hash.Clear()
            foreach ($prop in $properties) { 
                if (($index = $allProps[$prop]) -ne $null) {
                    $hash[$prop] = $shellFolder.getDetailsOf($file, $index)
                }
            }
            if ($supportsOrdered) {
                [PSCustomObject]$hash
            } else {
                Select $properties -inputObject (
                    New-Object PSObject -Property $hash
                )
            }
        }
    }
    }
}

# Andy's Script :)

Clear

# User Set variable for the directory of music 
$MusicPath = "D:\OneDrive\Music" 

# User Set variables for the output CSV
$CSVPath = "D:\OneDrive\Music\"
$CSVName = "MusicExport"

# Script set variables for the output CSV
$CSVDateAppend = Date -Format "-yyyy-MM-dd"
$CSVExtension = ".CSV"
$CSV = "$($CSVPath)$($CSVName)$($CSVDateAppend)$($CSVExtension)"

# First find out if the user wants to export their music to a CSV
$RunTheScan = Read-Host "Run The Scan? (Y/N) [Hint - press 'Enter' twice to go straight to searching for tracks]"
If ($RunTheScan -eq "Y") {

# Enumerate all the subdirectories from the root path
$AllDirectories = (Get-ChildItem -LiteralPath $MusicPath -Recurse -Directory)
$DirectoriesWithMusic = New-Object System.Collections.ArrayList

# Loop through each directory and check if they have any files in them - if not, no point in scanning
# If they do have files, add them to the Array
ForEach ($Directory in $AllDirectories) {
    If ((Get-ChildItem -File -LiteralPath $Directory.FullName).count -eq 0) {Write-Host $Directory "Nothing Here" -ForegroundColor Yellow}
    Else {Write-Host "Adding" $Directory -ForegroundColor Green ; $DirectoriesWithMusic.Add($Directory) | Out-Null}
}

# Loop through each directory that contains music and export what's found to the CSV
ForEach ($DirectoryWithMusic in $DirectoriesWithMusic) {
Write-Host "Processing " -NoNewLine
Write-Host "$DirectoryWithMusic" -ForegroundColor Cyan
$CurrentMetaData = Get-FileMetaData -folders $DirectoryWithMusic.FullName -properties Path,"Folder name",Name,Size,"Item type","Title","Length","Bit rate" -Force
$CurrentMetaData | Export-CSV $CSV -Append -Encoding UTF8 -NoTypeInformation

}
}

Write-Host
# The scan is complete - tell the user and ask if they want to check their music tracks 
$CheckYourMusic = Read-Host "Export Complete (or skipped), would you like to check for specific music tracks? (N = No/Quit)"
If ($CheckYourMusic -ne "N") {

# Scan the entire music structure and collect each file name
$AllMusic = ((Get-ChildItem -LiteralPath $MusicPath -Recurse -File).FullName)

# Keep looping through the music check until the user chooses to 'quit'
Do {
Clear

# What are you looking for?
Write-Host "Keywords To Look For? ['Quit' to exit]" -ForegroundColor Magenta
$KeywordsProvided = Read-Host

# If you type in anything that's fewer than 2 characters, you need to try again (just so the search isn't stupidly cumbersome/long)
If ($KeywordsProvided.Length -le 2) {Write-Host "Nothing Entered, Try Again " -ForegroundColor Red}

# If one or more words (more than 2 characters) are entered, split the words up into their own chunk instead of treating as a phrase
# Also, by sorting the words into length order, the chances are the scan will be faster as longer words are likely more -
# - infrequent like 'umbrella' versus 'she'
Else {$KeywordsProvided = $KeywordsProvided -Split " " | Sort-Object -Property Length -Descending
        
        # Setup an arrays to match all tracks - bear in mind that 'tracks' are filenames, so if your file-naming is poor -
        # - i.e. 'track 1', 'track 2' instead of '07 - She's not there', or 'Yellow Submarine'
        $TracksThatMatchAllKeywords = [System.Collections.Arraylist]@()

        # An array (not used at present) to match against album name as well as track
        # Again, like 'track' is based on filename, this is based on directory name
        $TracksAndAlbumsThatMatchAllKeywords = [System.Collections.Arraylist]@()
    
        # Loop through each Keyword to narrow down the tracks that match
        # This is an iterative process so tracks that match the first keyword are stored in an array, and then the array itself -
        # - is used to search the second keyword, and so on - rather than scan the entire music collection each time
        ForEach ($Keyword in $KeywordsProvided) {
        
        # Check how many times the same keyword is used to prevent single words/part-words matching, for example -
        # - 'Mony' could match 'Mony Mony' and also a track called 'Harmony', whereas 'Mony Mony' will not match a track called 'Harmony' - 
        # - (but would match a track called 'Mony Harmony' or 'Harmony Harmony' etc)
        $OccurencesOfKeyword = ($KeywordsProvided | Group-Object | Where-Object {$_.Group -Match $Keyword} | Select-Object count)[0].Count
            
            # If there's only one keyword specified, or whilst checking keywords, this is the first one, check the whole music collection for matches:
            If (($Keyword -eq $KeywordsProvided[0]) -or ($KeywordsProvided.count -eq 1)) {
            
            # Get ALL tracks and Albums and ignore the music path and look for the specific keyword the number of times it is listed in the keywords list  
            $TracksAndAlbumsThatMatchAllKeywords = $AllMusic | Where-Object {(($_ -Replace [RegEx]::Escape($MusicPath)) -Match $Keyword) -and `
            (($_ -Split $Keyword).Count -ge $OccurencesOfKeyword+1)}
            
            # Get ALL tracks ONLY and ignore the music path and look for the specific keyword the number of times it is listed in the keywords list  
            $TracksThatMatchAllKeywords = $TracksAndAlbumsThatMatchAllKeywords | Where-Object {((($_ -Split '\\') | Select-Object -Last 1) -Match $Keyword) -and `
            (($_ -Split $Keyword).Count -ge $OccurencesOfKeyword+1)}
            }
            
            # Check the keyword against the existing filtered list:
            Else {
            # Get ALL tracks and Albums and ignore the music path and look for the specific keyword the number of times it is listed in the keywords list  
            $TracksAndAlbumsThatMatchAllKeywords = $TracksAndAlbumsThatMatchAllKeywords | Where-Object {(($_ -Replace [RegEx]::Escape($MusicPath)) -Match $Keyword) -and `
            (($_ -Split $Keyword).Count -ge $OccurencesOfKeyword+1)}
            # Get ALL tracks ONLY and ignore the music path and look for the specific keyword the number of times it is listed in the keywords list  
            $TracksThatMatchAllKeywords = $TracksThatMatchAllKeywords | Where-Object {((($_ -Split '\\') | Select-Object -Last 1) -Match $Keyword) -and `
            (($_ -Split $Keyword).Count -ge $OccurencesOfKeyword+1)}
            }
        }     

        # If after searching through each keyword nothing has been added to the array, there isn't a match
        If ($TracksThatMatchAllKeywords.Count -eq 0) {Write-Host "No Matching Tracks Found" -ForegroundColor Red} 
        
        Else {
        
        # Since we have tracks in the array, we need to create a new array for the matching track(s) metadata  
        $MetaDataArray = New-Object System.Collections.ArrayList
       
        # Set a counter to keep track of how many tracks to scan through (just as a visual aid to the user) 
        $TrackCount = 1
        
        # Loop through each of the tracks with matching keywords and get the metadata
        ForEach ($MatchingTrack in $TracksThatMatchAllKeywords) {
        Clear
        Write-Host "Getting metadata for: " -ForegroundColor Red -NoNewline
        ($KeywordsProvided -Join " ")
        Write-Host "Scanning " $TrackCount "of" $TracksThatMatchAllKeywords.Count " matching tracks" -ForegroundColor Cyan
    
        # Get the folder name that the track is in
        $TrackFolder = ((Get-Item -LiteralPath $MatchingTrack).Directory).FullName
        
        # Get the track name (and remoe the file extension)
        $Track = (($MatchingTrack -Split '\\') | Select-Object -Last 1) -Replace ".[^.]*$" 
        
        # Get the metadata for the specific tracks - the -FileKeywords switch was one of my edits to the Get-FileMetaData script which -
        # - previously only scanned entire directories
        # Also to note, this is where the properties are spcified for the metadata you want to export
        $MetaDataArray.Add((Get-FileMetaData -Folders $TrackFolder -Properties Path,'#',Title,Album,"contributing artists","Bit Rate" -FileKeywords $Track)) | Out-Null

        # Increment the track count
        $TrackCount++ | Out-Null
    }
    
    # Once all the metadata has been collected for the matching files, select the metadata you want to display and format as a table
    $MetaDataArray | Select-Object Title,Album,"contributing artists",'#',"Bit Rate",Path |Sort-Object Title | Format-Table -AutoSize
    
    # Pause to view the output (otherwise it will all just shoot off screen!)
    PAUSE
    }

}
} Until ($Keywords -eq "Quit")
}
