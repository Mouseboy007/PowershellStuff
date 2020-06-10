#############################################
#                                           #
#        JobServeJobsAppliedFor.Ps1         #
#          Andy Pyne 2020.06.10             #
#                                           #
#  Basically a way to scrape job info from  #
#  JobServe and output to a text file to    #
#  easily track roles applied for           #
#                                           #
#############################################

Clear

# Path of the text file
$AppliedForSource = "D:\OneDrive\Documents\CV's & Job Hunting\Jan2020\AppliedFor.txt"

# Read the text file for the last applied for job to output to screen
Write-Host "Last Check " -ForegroundColor Yellow -NoNewline
Write-Host (Get-Content $AppliedForSource | Select-Object -First 1) -ForegroundColor Magenta
Write-Host

# A counter for how many jobs applied for this session
$JobCount = 1

# Infinite Do-Loop
Do {

# If the job counter is divisible perfectly by 9 (or any number you swap in) then the counter gets reset to zero and the sceen refreshes
If (($JobCount % 9) -eq 0) {
$JobCount = 0
Clear
Write-Host "Last Check " -ForegroundColor Yellow -NoNewline
Write-Host (Get-Content $AppliedForSource | Select-Object -First 1) -ForegroundColor Magenta
(($JobArray | Where-Object {$_ -Match "Advert"}) -Split " : ")[1] | ForEach-Object {Write-Host $_ -ForegroundColor Green}
(($JobArray | Where-Object {$_ -Match "Role"}) -Split " : ")[1] | ForEach-Object {Write-Host $_ -ForegroundColor Green}
(($JobArray | Where-Object {$_ -Match "Applied"}) -Split " : ")[1] | ForEach-Object {Write-Host $_ -ForegroundColor Green}
Write-Host
}

# Prompt to paste the 'Permalink' URL 
Write-Host "Enter Job Page: " -NoNewline -ForegroundColor Cyan
$JobServePageAsk = Read-Host 

# Date and time stamp
$TheTime = (Get-Date -f "HH:mm (ddd)")

# If a fullstring Permalink URL isn't pasted, then remove the last date check from the file and update it wth a new one
If ($JobServePageAsk.Length -lt 4) {
Write-Host "Last checked at " $TheTime -ForegroundColor Green
$TheTime | Set-Clipboard

$AppliedForData = Get-Content $AppliedForSource
$UpdatedContent = @($TheTime) +  ($AppliedForData[1..$AppliedForData.Length])
$UpdatedContent | Set-Content $AppliedForSource -Encoding Unicode


}

Else {

# Grab the full web page that the Permalink points to
$JobServePage = ""
$JobServePage = Invoke-WebRequest $JobServePageAsk

$JobLabel = ($JobServePage.AllElements | Where {$_.Title -match "apply for this"} | Select-Object Title).Title[0] -Replace "Apply for this " -Replace " job."

# Create an array to which the relevant fields can be parsed
$JobArray = @()

$JobArray += (Get-Date -f "HH:mm (ddd)")
$JobArray += ""
$JobArray += "Role     : " + $JobLabel

$JobDetails = ($JobServePage.AllElements | Where {$_.Class -match "jd_value"}).OuterHTML

# Get each element we're interested in
ForEach ($JobDetail in $JobDetails) {
If ($JobDetail -Match "md_location") {$JobArray += "Location : " + (($JobDetail -Split ">")[1] -Split "<")[0]}
If ($JobDetail -Match "md_rate") {$JobArray += "Rate     : " + (($JobDetail -Split ">")[1] -Split "<")[0]}
If ($JobDetail -Match "md_recruiter") {$JobArray += "Agency   : " + (($JobDetails -Match "md_recruiter") -split "span>" -Replace "<" -Replace "/" | Where-Object {$_ -NotMatch ">"})[1]}
If ($JobDetail -Match "md_contact") {$JobArray += "Contact  : " + (((($JobDetail -Split ">")[1] -Split "<")[0]) -Split "&")[0]} 
If ($JobDetail -Match "md_telephone") {$JobArray += "Phone    : " + (($JobDetail -Split ">")[1] -Split "<")[0]}
If ($JobDetail -Match "md_email") {$JobArray += "E-Mail   : " + (((($JobDetails -Match "md_email") -split "mailto:")[1]) -Split '" Target=')[0]}
If ($JobDetail -Match "md_ref") {$JobArray += "Ref      : " + (($JobDetail -Split ">")[1] -Split "<")[0]}
If ($JobDetail -Match "md_permalink") {$JobArray += "Advert   : " + (($JobDetail -Split ">")[1] -Split "<")[0]}
}

# If the Job Array only has 3 elements, it means the info hasn't updated from the page (maybe a broken/incorrect link) so simply dump the date back to the file
If ($JobArray.Count -eq 3) {$JobArray = $JobArray[0]} Else {$JobArray += "Applied  : " + (Get-Date -f "dd.MM.yy @ HH:mm")}
$JobArray | Set-Clipboard

# Update the file with the relevant Permalink page elements
$AppliedForData = Get-Content $AppliedForSource
$UpdatedContent = @($JobArray) +  ($AppliedForData[1..$AppliedForData.Length]) 
$UpdatedContent | Set-Content $AppliedForSource -Encoding Unicode
Write-Host "Last Checked at " $TheTime

}

$JobCount ++

} Until ($Hell -eq "Freezes-Over")