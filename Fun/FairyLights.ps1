$Counter = 0
Do {
$ChristmasLight = (Get-Random "White","Red","Green","Cyan","Yellow","Magenta")
Write-Host "🌰" -ForegroundColor $ChristmasLight -NoNewline
If ($Counter % 60 -eq 0) {Write-Host}
$Counter++
} Until ($ChristmasSpirit -eq "AllGone <|:(")