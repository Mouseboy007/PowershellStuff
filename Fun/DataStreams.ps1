Clear
$CurrentPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

Function Get-DataStreams {

    Param(
    [String]$Path
    )      

    If (!$Path) {$Path = $CurrentPath}
    Else {If ((Test-Path $Path -ErrorAction SilentlyContinue) -eq $False) {$Path = $CurrentPath}}
    
    $ChildItems = Get-ChildItem -Recurse $Path
    $DataStreamArray = New-Object System.Collections.ArrayList

    Clear

    ForEach ($ChildItem in $ChildItems) {

    $DataStreams = Get-Item -LiteralPath $ChildItem.FullName -Stream * -ErrorAction Ignore
        ForEach ($DataStream in $DataStreams) {
            If (
                ($DataStream.Length -ne 0) -and ($DataStream.Stream -ne ':$DATA')
                ) 
                {
                [Void]$DataStreamArray.Add($DataStream)
                }
            }
    }

    If ($DataStreamArray.count -eq 0) {Write-Host "No Alternate Data Streams Found" -ForegroundColor Red}
    Else {Write-Host "Alternate Data Streams Found" -ForegroundColor Green
          Start-Sleep -Seconds 2
          $DataStreamArray | Select-Object PSChildName, Length, FileName | Out-GridView

            ForEach ($DataStream in $DataStreamArray) {
                Clear
                Write-Host $DataStream.Filename -ForegroundColor Green
                $DataStream | Select-Object Stream, Length | Format-Table
                Write-Host "View Contents as (T)ext, (R)aw Export, (F)udgedExport (S)kip, (D)elete Stream or (Q)uit?" -ForegroundColor Cyan
                    Switch ($ViewContents = Read-Host) {
                    "T" {Clear ; Get-Content $DataStream.PSPath  ; Pause}

                    "D" {Write-Host "Deleting Stream" $DataStream.Stream -ForegroundColor Yellow
                         Start-Sleep -Seconds 1
                         Remove-Item $DataStream.FileName -Stream ($DataStream.Stream)
                         }

                    "R" {Write-Host "Exporting Content, please wait" -ForegroundColor Cyan
                         $ExportFile = (($DataStream.Filename)+'._ADS_.'+($DataStream.Stream))
                         [IO.File]::WriteAllBytes($ExportFile, [Byte[]](
                            Get-Content (Get-Item -Path $DataStream.FileName -Stream ($DataStream.Stream)).PSPath -ReadCount 0 -Encoding Byte)
                            )
                         Explorer.exe $ExportFile
                         Write-Host "Exported Data Stream Content to: " -ForegroundColor Yellow
                         Write-Host $ExportFile -ForegroundColor Green
                         Start-Sleep -Seconds 2
                         }

                    "F" {Write-Host "Exporting Content, please wait" -ForegroundColor Cyan
                         $ExportFile = (($DataStream.Filename)+'._ADS_.'+($DataStream.Stream))
                         [IO.File]::WriteAllBytes($ExportFile, [Byte[]](
                            Get-Content (Get-Item -Path $DataStream.FileName -Stream ($DataStream.Stream)).PSPath -ReadCount 0 -Encoding Byte)
                            )
                         
                         $ByteArrayFudged    = [Byte[]](Get-Content $ExportFile -ReadCount 0 -Encoding Byte)
                         
                         $ReadCounter=255
                         $ByteArrayUnFudged = $ByteArrayFudged | ForEach-Object {($_ + $ReadCounter) % 256
                                                                                 If ($ReadCounter -eq 0) {$ReadCounter = 256}
                                                                                 $ReadCounter -- 
                                                                                 }
                                       
                         [IO.File]::WriteAllBytes($ExportFile, [Byte[]]($ByteArrayUnFudged))
                         
                         Explorer.exe $ExportFile
                         Write-Host "Exported Data Stream Content to: " -ForegroundColor Yellow
                         Write-Host $ExportFile -ForegroundColor Green
                         Start-Sleep -Seconds 2
                         }

                    "Q" {Return}
                    
                    Default {Write-Host "Skip"}        

                    } 
                }
            }

     }
 
Function Set-DataStreams {

    Param(
    [Parameter(Mandatory=$True)]
    $Filename,
    [Parameter(Mandatory=$True)]
    $StreamName,
    [Parameter(Mandatory=$True)]
    [String]$FileOrText,
    [ValidateSet("Yes","No")]
    [String]$Obfuscated,
    [ValidateSet("Yes","No")]
    [String]$HideExtension
    )    

    If ((Test-Path $FileName) -eq $False) {Write-Host "Invalid Filename" -ForegroundColor Red ; Break}
    If ($HideExtension -eq "Yes") {$StreamNameValidated = $StreamName} 
    Else {$StreamNameValidated = (($StreamName)+'.'+($FileOrText.Split('.') | Select-Object -Last 1))}
    
    If ((Test-Path $FileOrText) -eq $True) {
        Write-Host "Adding File Content: " -ForegroundColor Yellow -NoNewline
        Write-Host $FileOrText
        Write-Host "To Stream:           " -ForegroundColor Yellow -NoNewline
        Write-Host $StreamNameValidated
        Write-Host
        Write-Host "Importing Content, Please Wait" -ForegroundColor Cyan
        
        If ($Obfuscated -eq "Yes") {
                Write-Host "Obfuscating Data Please Wait" -ForegroundColor Green
                $ByteArrayRaw    = [Byte[]](Get-Content $FileOrText -ReadCount 0 -Encoding Byte)
                
                $WriteCounter=1
                $ByteArrayFudged = $ByteArrayRaw | ForEach-Object {($_ + $WriteCounter) % 256 ; $WriteCounter ++}               
                
                Set-Content -Path $Filename `
                            -Value ([Byte[]]($ByteArrayFudged)) `
                            -Stream $StreamNameValidated -Encoding Byte
                }
        
        If ($Obfuscated -ne "Yes") {
                Set-Content -Path $Filename `
                            -Value ([Byte[]](Get-Content $FileOrText -ReadCount 0 -Encoding Byte)) `
                            -Stream $StreamNameValidated -Encoding Byte
                }
        
        }
   Else {
        Write-Host "Adding Plain Text: " -ForegroundColor Cyan -NoNewline
        Write-Host $FileOrText
        Write-Host "To Stream:         " -ForegroundColor Cyan -NoNewline
        Write-Host $StreamName
        Set-Content -Path $Filename -Value $FileOrText -Stream $StreamName
        }  

Write-Host
Write-Host "Alternate Data Streams for File:" -ForegroundColor Magenta
Try {$AllFileStreams = (Get-Item -LiteralPath $FileName -Stream *).Stream } Catch {}
$AllFileStreams

}


#Set-Content -path .\hello.txt -value $(Get-Content $(Get-Command calc.exe).Path -readcount 0 -encoding byte) -encoding byte -stream exestream

#Get-DataStreams -Path Blah

<#

$Numbers = 0..255
Clear
$Numbers | ForEach-Object {($_ + 255) % 256}
PAUSE   
$Numbers | ForEach-Object {($_ + 1) % 256}

#>

$ADD_ADS_To  = "C:\Users\Public\Hello.txt"
$Import_File = "C:\Users\Public\TestPic.jpg"

Set-DataStreams -StreamName '1_AllClear' `
                -Obfuscated No `
                -HideExtension No `
                -Filename $ADD_ADS_To `
                -FileOrText $Import_File

Set-DataStreams -StreamName '2_Clear_NoExt' `
                -Obfuscated No `
                -HideExtension Yes `
                -Filename $ADD_ADS_To `
                -FileOrText $Import_File

Set-DataStreams -StreamName '3_Obfs+Ext' `
                -Obfuscated Yes `
                -HideExtension No `
                -Filename $ADD_ADS_To `
                -FileOrText $Import_File

Set-DataStreams -StreamName '4_TotallyObfs' `
                -Obfuscated Yes `
                -HideExtension Yes `
                -Filename $ADD_ADS_To `
                -FileOrText $Import_File