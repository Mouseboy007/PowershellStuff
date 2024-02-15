# $NumberToTest is the number you want to check to probabilistically check if it's prime
# We then take $NumberToTest and minus 1, so it becomes the exponent in a calculation where it is raised to a power called $RaiseToPowerBase
# So if $NumberToTest is 13, and $RaiseToPowerBase is 2, then we will perform the calculation 2^(13-1) (two to the power of thirteen-minus-1, or in other words 2^12)
# Based on the Miller-Rabin Primality Test, we'll test each $NumberToTest against at least 2 $RaiseToPowerBase values

# If $NumberToTest is Prime, then for any integer $RaiseToPowerBase that is not divisible by $NumberToTest, the equation $RaiseToPowerBase^($NumberToTest-1) Mod $NumberToTest = 1 will hold
# The Miller-Rabin test works by repeatedly choosing random $RaiseToPowerBase integers and checking whether the equation $RaiseToPowerBase^($NumberToTest-1) Mod $NumberToTest = 1 holds 
# If it does, then the number n is *probably* prime. If it does not, then the number $NumberToTest is definitely composite.

# The probability that the Miller-Rabin test will incorrectly classify a composite number as prime is 1/4
# This means that if the test is run multiple times, the probability that it will incorrectly classify a composite number as prime will be very small

# The Miller-Rabin test is a very efficient algorithm, and it is often used in practice to test the primality of large numbers and is used in RSA
# The RSA cryptosystem is a widely used public-key encryption system

# Here is an example of how the Miller-Rabin test works 
# Consider the $NumberToTest is 13 and $RaiseToPowerBase is 2 
# The equation 2^(13-1) Mod 13, is 2^12 mod 13, which is= 4096 mod 13, which equals to 1 so 13 is probably prime
# As a second example, consider $NumberToTest is 13 and $RaiseToPowerBase is 2
# The equation 2^(15-1) Mod 15, which is 2^14 mod 15, which is 16384 mod 15 does not equal to 1 so 15 is definitely composite

###########################################################

# Another Explanation:

#The Miller-Rabin test is a probabilistic algorithm used to determine if a given number is likely to be prime or composite (not prime).
#It works by testing if a number n is a "strong probable prime" based on witnesses.
#To test, we pick a random number a (the witness) less than n.
#We then compute (a^d) mod n where d is the highest power of 2 that divides (n-1).
#If the result is 1 or n-1, n passes the test for that witness.
#If the result is anything else, n fails the test and is composite.
#We repeat with different random witnesses to increase confidence in the result.
#After several iterations without failure, we can say n is likely prime, but there is a small chance it may still be composite.
#So the more witnesses used, the higher the probability that a number is prime if it passes the tests.

##########################################################

Function RaiseToPowerBase {
    Param($NumberToTest)

# https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
$RaiseToPowerBase = Switch ($NumberToTest) {
    {$_ -lt 2047} {2,3 ; Break}
    {$_ -lt 1373653} {2,3 ; Break}
    {$_ -lt 9080191} {31,73 ; Break}
    {$_ -lt 25326001} {2,3,5 ; Break}
    {$_ -lt 3215031751} {2,3,5,7 ; Break}
    {$_ -lt 4759123141} {2,7,61 ; Break}
    {$_ -lt 1122004669633} {2,13,23,1662803 ; Break}
    {$_ -lt 2152302898747} {2,3,5,7,11 ; Break}
    {$_ -lt 3474749660383} {2, 3, 5, 7, 11, 13 ; Break}
    {$_ -lt 341550071728321} {2, 3, 5, 7, 11, 13, 17 ; Break}  
    {$_ -lt 3825123056546413051} {2, 3, 5, 7, 11, 13, 17, 19, 23 ; Break}  
    {$_ -lt 18446744073709551616} {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31,37 ; Break}  # 2^64
    {$_ -lt 318665857834031151167461} {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37 ; Break}  
    {$_ -lt 3317044064679887385961981} {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41 ; Break}        
    Default {0 ; Break}
    }
      
    Return $RaiseToPowerBase
    
}

###########################################################

Function CheckPrimesTroubleshoot1 {
    Write-Host '$NumberToTest = ' -NoNewline
    Write-Host $NumberToTest -ForegroundColor Green -NoNewline
    Write-Host ' - Iteration' ($K_IterationCounter + 1) -ForegroundColor Red -NoNewline
    Write-Host ' - $CheckForPrime (calculated as ' $RaiseToPowerBase '^' $OneLessThanNumberToTest 'Mod' $NumberToTest ') = ' -NoNewline
    Write-Host $CheckForPrime -ForegroundColor Cyan
}

Function CheckPrimesTroubleshoot2 {
    Write-Host '$NumberToTest = ' -NoNewline
    Write-Host $NumberToTest -ForegroundColor Yellow -NoNewline
    Write-Host ' - SubIteration' $S_IterationCounter -ForegroundColor Yellow -NoNewline
    Write-Host ' - $CheckForPrime (calculated as ' $CheckForPrimeOrig '^ 2 Mod' $NumberToTest ') = ' -NoNewline
    Write-Host $CheckForPrime -ForegroundColor Yellow
}


#$LowerPrimeNumber = 50000000000
#$UpperPrimeNumber = 50000003000
#$LowerPrimeNumber = 27493353353884600173484019000
#$UpperPrimeNumber = 27493353353884600173484019999
#$LowerPrimeNumber = 160000
#$UpperPrimeNumber = 170000

# The maximum value for a decimal in PowerShell is approximately 7.9 x 10^28.
# Largest Prime Detectable 79228162514264337593543950319
# Largest Usable Number 79228162514264337593543950334
# [decimal]::MaxValue

Function CheckPrimes {
    <#
        .SYNOPSIS
            Test if a number is a prime number or a range of numbers are prime.
        .DESCRIPTION
            This function uses the Rabin-Miller primality test to check for primality.
            The number of rounds reduces the likelihood of error due to 'Strong Liars' as more 'Witnesses' are generated to test for primality 
        .EXAMPLE
            CheckPrimes -LowerPrimeNumber 12345678903 -UpperPrimeNumber 12345679999 -ShowNumbers Yes -Iterations 5 -MeasurePerformance Yes
            Returns 44 Primes identified
        .LINK
            https://gist.github.com/gravejester/1c8eaecdedfc8d6b7e61
            http://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
            http://rosettacode.org/wiki/Miller-Rabin_primality_test#C.23
        .INPUTS
            Bigint
        .NOTES
            This code is partly made up from a PowerShell acript found on Øyvind Kallstad's GitHub, and before that rosettacode.
            Author: Andy Pyne
            Date: 13.07.2023
            Version: 1.0
    #>
         Param(    

               # First number to check for Primality
               [Parameter(Position=0, Mandatory=$True, ValueFromPipeline)]
               [ValidateRange(1,79228162514264337593543950334)]
               $LowerPrimeNumber,
               
               # Last number in range to check for Primality (if excluded, it'll be the first number, so a 'range' of 1)
               [Parameter(Position=1)]
               [ValidateRange(2,79228162514264337593543950334)]
               $UpperPrimeNumber = $LowerPrimeNumber,
               
               # Whether to output to screen
               [Parameter(Position = 2)]
               [ValidateSet("Yes","No")]
               $ShowNumbers = $Null,

               # Determines the accuracy of the test. Default value is 10 (set later on)
               [Parameter(Position = 3)]
               [ValidateRange(1,100)]
               $Iterations = $Null,

               # Troubleshooting Switch
               [Parameter(Position = 4)]
               [Switch]$Troubleshoot
               )

# Start a timer to test the performance of the Primality Test
$StartTest = [DateTime]::Now

# Clear the screen! 
Clear

    # Show on screen what options were selected
    Write-Host "CheckPrimes" -ForegroundColor Cyan -NoNewline
    Write-Host " -LowerPrimeNumber $LowerPrimeNumber" -ForegroundColor Yellow -NoNewline
    
    If ($UpperPrimeNumber -ne $LowerPrimeNumber) {Write-Host " -UpperPrimeNumber $UpperPrimeNumber" -ForegroundColor Yellow -NoNewline}

    If ($Null -ne $Iterations) {Write-Host " -Iterations $Iterations" -ForegroundColor Yellow -NoNewline} Else {$Iterations = 10}

    If ($Null -ne $ShowNumbers) {
       Write-Host " -ShowNumbers " -ForegroundColor Yellow -NoNewline
       Write-Host $ShowNumbers -ForegroundColor Magenta -NoNewline
                    }
    Write-Host
    Write-Host
   
# Array to collate the Miller-Rabin Probabilistic Test Primes
$Global:MillerRabinPrimes = New-Object System.Collections.ArrayList

# Calculate the amount of numbers checked (We'll use this later)
$NumberRange = (($UpperPrimeNumber - $LowerPrimeNumber) + 1)

# If the lower limit for checking primes is below 5 we'll add the numbers 2 and or 3 to the $MillerRabinPrimes array before we start
Switch ($LowerPrimeNumber -le 5) {
    True {
          If ($LowerPrimeNumber -le 2) {[Void]$MillerRabinPrimes.Add(2)}
          If ($LowerPrimeNumber -le 3 -and $UpperPrimeNumber -gt 2) {[Void]$MillerRabinPrimes.Add(3)}
          If ($LowerPrimeNumber -le 5 -and $UpperPrimeNumber -gt 3) {[Void]$MillerRabinPrimes.Add(5)}
    $LowerPrimeNumber = 6
    }
}

# Loop through each number in the range LowerPrimeNumber to UpperPrimeNumber
For ($NumberToCheckIteration = $LowerPrimeNumber ; $NumberToCheckIteration -le $UpperPrimeNumber; $NumberToCheckIteration++) {

    # Set the $ProbablePrime variable to determine if the Number being checked for Primality is it being Prime as $True
    # We will invalidate the variable to being False throughout the calculations/tests
    # Any number which after the designated number of iterations is not marked as Composite by our Primality test is considered Prime
    $ProbablePrime = $True

    # Ignore any number which ends in a digit that guarantees it isn't prime such as an even or the number 5
    # This saves a little bit of mathematics later on (i.e. we can skip calculating anything for these numbers)
    # Since we're taking the last digit of the number as a string, we need to encapsulate the '-NotIn' checks in single-quotes 
    If (($NumberToCheckIteration.ToString()[-1]) -NotIn ('1','3','7','9')) {Continue} Else {
     
        # Set the number to test as the value of the iteration we're on in the For loop
        # Mathematically, this is usually referenced in the Miller-Rabin test as 'n'
        [BigInt]$NumberToTest = $NumberToCheckIteration

        # Set a value to being the odd-number we are checking, minus 1
        # Mathematically, this is usually referenced in the Miller-Rabin test as 'd'
        [BigInt]$OneLessThanNumberToTest = ($NumberToTest - 1)
    
        # Set the number of iterations we will perform
        # Mathematically, this is usually referenced in the Miller-Rabin test as 'k'
        # Technically we don't need to declare this as it will have been parsed to the function already
        # But I think it's nice to have it here as a reminder
        [Int]$Iterations = $Iterations

        # Set the number of secondary 'modular' iterations we will perform
        # This will be based on how many times we can iterate back through the $OneLessThanNumberToTest variable 'mod 2'
        # Mathematically, this is usually referenced in the Miller-Rabin test as 's'  
        [Int]$ModuloIterations = 0
        
            # Keep dividing the $OneLessThanNumberToTest by 2 until you get to an odd number
            # At each iteration, increment the $ModuloIterations variable by 1    
            While (($OneLessThanNumberToTest % 2) -eq 0) {
                # Decrement the $OneLessThanNumberToTest variable by half (until the number is odd, as mentioned)
                $OneLessThanNumberToTest /= 2
                $ModuloIterations += 1
            }

            # A counter to loop through the number of times specified by the $Iterations variable
            # The higher this number the more accurate the test, but the slower the performance
            # The number of loops will be the number of number-bases tested
            For ($K_IterationCounter = 0 ; $K_IterationCounter -lt $Iterations ; $K_IterationCounter++) {
    
            # Small loop to select a random base (2 to 255)
            # The minimum value for the number base is 2
            # Repeat until the number base value is lower, by at least 2, than the number being tested
            # So for any $NumberTotest that we test over 257, we will get a usable number first try
            # We could select larger or smaller random bases, and we could also keep track of them so we don't inadvertantly generate the same number based by chance
            # We could also refer to the static number-bases in the RaiseToPowerBase function 
                Do {[BigInt]$RaiseToPowerBase = Get-Random (2..255)
                   } While ($RaiseToPowerBase -ge ($NumberToTest - 2))

                # We now create a variable called $CheckForPrime where we use the [BigInt]::ModPow method to calculate the modular exponentiation 
                # It computes the result of raising a given base to a specified exponent and then takes the modulus with respect to a specified modulus
                    # The base (first variable) is the value to be raised to the exponent
                    # The exponent (second variable) is the value to which the base (first variable) is raised
                    # The modulus (third varibale) is the value used to compute the result
                    # Remember the $OneLessThanNumberToTest variable is going to be a smaller number as earlier we kept dividing it by 2 until we reached an odd number
                [BigInt]$CheckForPrime = [BigInt]::ModPow($RaiseToPowerBase, $OneLessThanNumberToTest, $NumberToTest)

                If ($Troubleshoot) {CheckPrimesTroubleshoot1} 
            
                # Check if the $CheckForPrime variable is either 1, or equal to the original $OneLessThanNumberToTest variable (i.e. the number one less than the $NumberToTest) 
                # If a check returns true, skip the other checks in this section and run another iteration (We already have a strong witness and probably have a prime!)
                # If by the end of all iterations $CheckForPrime has been consistently equal to 1 or equal to the original $OneLessThanNumberToTest variable 
                # Then we are confident we have a prime!
                If (($CheckForPrime -eq 1) -or ($CheckForPrime -eq ($NumberToTest - 1))) {Continue}

                # If the previous check gave us a value in which $CheckForPrime was not equal to 1 or equal to the original $OneLessThanNumberToTest variable,
                # we then perform a second set of iterative checks 
                # These next checks are predicated on the $ModuloIterations variable.
                # We iteratively set $CheckForPrime to be itself mod 2 to the power of $NumberToTest
                # In other words, we set the Base as $CheckForPrime, to an exponent of 2, and use the $NumberToTest as the modulus
                # The amount of times we can (sub)iteratively check will be equal to the number of times we could divide the original $OneLessThanNumberToTest variable by 2
                    # So for example, testing the number 73, our original $OneLessThanNumberToTest would be 72
                    # 72 which divides by 2 three times iteratively before becoming an odd number
                    # in other words, 72/2 = 36 (firstiteration - even number), 36/2 is 18 (second iteration - even number), 18/2 = 9 (third iteration - odd number!)
                    # Therefore we can perform 3x (sub)iterations at this stage to test for Primality/Compositeness                 
                        For ($S_IterationCounter = 1; $S_IterationCounter -lt $ModuloIterations; $S_IterationCounter++) {
                            
                            # We set the value here to track the value of $CheckForPrime before we iterate it
                            # This assists in troubleshooting where we can query the value before it changes
                            $CheckForPrimeOrig = $CheckForPrime 

                            [BigInt]$CheckForPrime = [BigInt]::ModPow($CheckForPrime, 2, $NumberToTest)
                                If ($Troubleshoot) {CheckPrimesTroubleshoot2} 
                    
                            # If $CheckForPrime is then equal to 1, the number is probably prime! (BUT May be a false witness!)
                                # As an example, if we're testing the primality of 7 with a power base 3, then we'd perform the calculation:
                                # 3 to the power of '7 minus 1'  (i.e. 6), mod 7. 3 to the power of 6 is 729. 
                                # 7 * 104 = 728 (one less than the output of 729), hence 729 mod 7 is 1
                                # If we changed the power base to 4 the numbers would look as follows:
                                # 4 to the power of 6 mod 7, or 4096 mod 7. 7 * 585 is 4095 (one less than the output of 4096), hence 4096 mod 7 is 1 
                            If ($CheckForPrime -eq 1) {
                                # We have a candidate for a Prime so can break out of the loop and perform a check against another base
                                # We set $ProbablePrime to False still as it's possible we have a false witness
                                # An example of a false witness - checking the number 133 using 8 as the base (to raise to 132) returns a 1
                                $ProbablePrime = $False 
                                Break # We can exit the loop here and check another base
                                }
                
                            # Remember, we have iterated the value of $CheckForPrime through a mod function so it will be a new value at this point relative to it's original value 
                            # If the present value of $CheckForPrime is equal to the $NumberToTest variable minus 1, the number is probably prime
                            # However, it's not a guarantee, so as above, we'll break out and test against a different base
                            If ($CheckForPrime -eq ($NumberToTest - 1)) {Break} # We can exit the loop here and perform the final check
                        }
            
                # If at this stage, $CheckForPrime isn't equal to the $NumberToTest variable minus 1, the number is composite
                # We set the $ProbablePrime value to $False and break out of the loop
                If ($CheckForPrime -ne ([BigInt]$NumberToTest - 1)) {
                    $ProbablePrime = $False
                        If ($Troubleshoot) {Write-Host "COMPOSITE" -ForegroundColor Red}
                    Break
                    }
            
        # If we've performed the above tests and not broken out of this part of the loop we will reset the $ProbablyPrime variable (back) to True
        # Now we need to test another number and base
        $ProbablePrime = $True
 
        }

    }
If ($Troubleshoot) {Write-Host}

    # If we've passed all above test and haven't returned the number as being composite - we've identified a Prime! (Very Probably)
    # We've now performed all of the iterations against different bases and the value for $ProbablePrime is still $True
    # We'll add the number that to the $MillerRabinPrimes array
    If ($ProbablePrime -eq $True) {[Void]$MillerRabinPrimes.Add($NumberToTest)}

}

# Once we've looped through all numbers to test and have our array of Primes, we can decide whether to draw the numbers to screen or not
# Drawing to screen will depend on the value of $ShowNumbers when calling the function
Switch($ShowNumbers) {
        Yes {$DisplayCounter = 0 
             $MillerRabinPrimes | 
                ForEach-Object {
                    $DisplayCounter ++
                    Write-Host ([String]$_).PadRight((($MillerRabinPrimes[-1]).ToString().Length)+1) -ForegroundColor Cyan -NoNewline 
                    If ($DisplayCounter -ge (140 / ((($MillerRabinPrimes[-1]).ToString().Length)+1))) {$DisplayCounter = 0 ; Write-Host}
                    }
             Write-Host
             Write-Host
             }
        Default {}
        }

# Write to screen the number of Primes identified and the size of the set
Write-Host $MillerRabinPrimes.Count "Primes identified " -ForegroundColor Green -NoNewline
Write-Host "(Checked" $NumberRange "Numbers)" -ForegroundColor Green
If ($MillerRabinPrimes.Count -eq 0) {Write-Host}

# Capture the current time to test the performance of the Primality Test
$EndTest = [DateTime]::Now

# Work out the difference between thr start and end time of the test to determine the duration
$PrimalityTestRunTime = $EndTest.Subtract($StartTest)

# Show the duration of the test
    Write-Host
    Write-Host "Primality test took" $PrimalityTestRunTime.TotalSeconds "Seconds" -ForegroundColor Magenta
    Write-Host
}

Clear
    # Show Syntax:
    Write-Host "CheckPrimes" -ForegroundColor Cyan -NoNewline
    Write-Host " -LowerPrimeNumber" "" -ForegroundColor Yellow -NoNewline
    Write-Host "<Lowest Number to Check [Mandatory]>" -ForegroundColor DarkYellow -NoNewline 
    Write-Host " -UpperPrimeNumber" "" -ForegroundColor Yellow -NoNewline
    Write-Host "<Lowest Number to Check>" -ForegroundColor DarkYellow
    Write-Host " -Iterations" ""-ForegroundColor Yellow -NoNewline
    Write-Host "<How many rounds>" -ForegroundColor DarkYellow -NoNewline
    Write-Host " -ShowNumbers " -ForegroundColor Yellow -NoNewline
    Write-Host "<Display output>" -ForegroundColor DarkMagenta
    Write-Host                    