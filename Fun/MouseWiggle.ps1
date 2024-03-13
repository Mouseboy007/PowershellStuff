$MilisecondsSleep = 50
$XYMove = 30 # Change this vaue for a larger movement

# -X = L
# +X = R
# -Y = U
# +Y = D

Function GetMousePosition {$Global:MousePosition = [System.Windows.Forms.Cursor]::Position ; Start-Sleep -Milliseconds $MilisecondsSleep}
Add-Type -AssemblyName System.Windows.Forms # For KeyPress

While (1) {

GetMousePosition

$XYArray = @(
            [PSCustomObject]@{X = $MousePosition.X + $XYMove ;  Y = $MousePosition.Y + 0}
            [PSCustomObject]@{X = $MousePosition.X + 0       ;  Y = $MousePosition.Y + $XYMove}          
            [PSCustomObject]@{X = $MousePosition.X - $XYMove ;  Y = $MousePosition.Y - 0}          
            [PSCustomObject]@{X = $MousePosition.X - 0       ;  Y = $MousePosition.Y - 0}             
)

$XYArray | ForEach-Object {    
            GetMousePosition
            $MousePosition # Uncomment this line to see the output of mouse movement
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($_.X,$_.Y) 
          }

Start-Sleep -Seconds 30 # Change this value to change frequency of actions

            [System.Windows.Forms.SendKeys]::SendWait("^{ESC}") # KeyPress

}