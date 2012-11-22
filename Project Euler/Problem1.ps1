# If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
# Find the sum of all the multiples of 3 or 5 below 1000.

$answer = 0
for ($i=1; $i -lt 1000; $i++) 
{
    if ($i/3 -is [int]) { $answer += $i }
    elseif ($i/5 -is [int]) { $answer += $i }
}
