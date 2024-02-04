# Bash stands for 'Bourne Again Shell'
# Default in Unix and MaxOS
# It is easier to execute shell commands using bash script

# This should be the first line in the bash file, which indicates it is batch file which is being processed
# This line in short is called 'hash bang' or 'shebang'
!/bin/bash 

# Type 'which bash' in the terminal to check the location of bash files

# The file extension to be used .sh as convention if we don't add the first line indicating its a bash script
# To execute bash script type bash script_name.sh
# If we have the first line mentioned identifying bash then ./script_name.sh


# In bash scripting there are 3 streams for your program 
# 1. STDIN : A stream data into the program
# 2. STDOUT: A stream data out of the program
# 3. STDERR: Error in your program

# 2> /dev/null : redirecting STDERR to be deleted 
# 1> /dev/null : STDOUT

# Sports.txt has 3 rows : football,basketball,swimming

# This command is taking data from the file and writing STDOUT to a new file
cat sports.txt 1> new_sports.txt

# Arguments(ARGV)
# ARGV is used inside by adding space after the script
# ARGV can be accessed via $ notation. $1 (First Argument), $2 (Second Argument)
# $@ and $* : give all the arguments in ARGV 
# $# : gives the length of the argument 

# Create a bash file args.sh
#!/usr/bash
echo $1
echo $2
echo $@
echo "There are " $# "arguments"

# Run the commad in the terminal
bash args.sh one two three four five

# Output 
one 
two 
one two three four five
There are 5 arguments 