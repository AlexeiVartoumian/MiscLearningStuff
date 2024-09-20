"Santiago": Find the secret combination
Scenario: "Santiago": Find the secret combination

Level: Easy

Type: Do

Tags: bash  

Description: Alice the spy has hidden a secret number combination, find it using these instructions:

1) Find the number of lines with occurrences of the string Alice (case sensitive) in the *.txt files in the /home/admin directory
2) There's a file where Alice appears exactly once. In that file, in the line after that "Alice" occurrence there's a number.
Write both numbers consecutively as one (no new line or spaces) to the solution file. For example if the first number from 1) is 11 and the second 22, you can do echo -n 11 > /home/admin/solution; echo 22 >> /home/admin/solution or echo "1122" > /home/admin/solution.

Test: Running md5sum /home/admin/solution returns d80e026d18a57b56bddf1d99a8a491f9(just a way to verify the solution without giving it away.)

Time to Solve: 15 minutes.