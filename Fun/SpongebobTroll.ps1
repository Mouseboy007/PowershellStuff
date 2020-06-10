#############################################
#                                           #
#           SpongebobTroll.Ps1              #
#          Andy Pyne 2020.06.03             #
#       * FIRST GITHUB POST {w00t} *        #
#  (thanks for the nudge William Boshoff)   #
#                                           #
#############################################

Do {

    Clear
    $Hell = "quit"

    $LowerCasePhrase = Read-Host "Enter a phrase to Spongebobify"
    
    $SpongeLetters = $LowerCasePhrase -Split ""
    $SpongePhrase = New-Object System.Collections.Arraylist

    $Counter = 1
        ForEach ($Letter in $SpongeLetters) {
            If ($Letter -ne " ") {
                If ($Counter % 2 -eq 0) {$SpongePhrase.Add($Letter.ToLower())| Out-Null} 
                Else {$SpongePhrase.Add($Letter.ToUpper()) | Out-Null}
                $Counter++
                }
                Else {$SpongePhrase.Add($Letter) | Out-Null}
    }

    $SpongePhrase = $SpongePhrase -Join ""
    Write-Host $SpongePhrase -ForegroundColor Yellow
    Write-Host '^ copied to your clipboard'
    $SpongePhrase | Clip

    Write-Host
    Write-Host "Again!, Again! ? ('quit' to exit, any other key to keep going)" -ForegroundColor Cyan
    $Freezes_Over = Read-Host

} Until ($Hell -eq $Freezes_Over)
