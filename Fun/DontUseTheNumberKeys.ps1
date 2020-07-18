#############################################
#                                           #
#        DontUseTheNumberKeys.PsONE         #
#      Just to demonstrate you can get      #
#        numbers without using the          #
#       number keys or number keypad        #
#                                           #
#               Andy Pyne                   #
#       Eighteenth of July, TwentyTwenty    #
#                                           #
#############################################

$One = $One.Length
$Two = $One + $One
$Three = $One + $Two

$ZeroToNineArray = New-Object System.Collections.Arraylist

$ZeroToNineArray.Add($One - $One)              #Zero
$ZeroToNineArray.Add($One)                     #One
$ZeroToNineArray.Add($Two)                     #Two
$ZeroToNineArray.Add($Three)                   #Three
$ZeroToNineArray.Add($Two * $Two)              #Four
$ZeroToNineArray.Add($Three + $Two)            #Five
$ZeroToNineArray.Add($Three * $Two)            #Six
$ZeroToNineArray.Add($Three + $Two + $Two)     #Seven
$ZeroToNineArray.Add([Math]::Pow($Two,$Three)) #Eight
$ZeroToNineArray.Add([Math]::Pow($Three,$Two)) #$Nine

Do {
Clear
$Digit = Get-Random -InputObject $ZeroToNineArray
Write-Host $Digit "Copied to Clipboard"
$Digit | Clip
Write-Host
Pause
} Until ($Hell -eq "FreezesOver")