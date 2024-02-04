# Environment variables : These variables are used to store information and are available all the time
# Think of these as global variables in other programming languages
# HOME : Users home directory : /home/repl
# PWD: Present working directory: pwd
# SHELL : which shell program is being used : /bin/bash
# USER : User's ID: repl 
# set : To get complete list of environment variables 
# Use set and grep to display value of HISTFILESIZE, which determines how many old commands are stored in command history?
set | gerp HISTFILESIZE 


# Use echo to print output on the screen 
echo hello nehal!
# To print value of a variable add $, if we do echo USER it displays back USER not its value
echo $USER

# Shell variables
# These can be thought of as local variables in other programming languages
# There should be no space before and after the equal sign
training=seasonal/winter.csv
echo $training

# for loop: to repeat the commands 
#The structure is for …variable… in …list… ; do …body… ; done
#The list of things the loop is to process (in our case, the words gif, jpg, and png).
#The variable that keeps track of which thing the loop is currently processing (in our case, filetype).
#The body of the loop that does the processing (in our case, echo $filetype).
for filetype in gif jpg png; do echo $filetype; done
for filename in seasonal/*.csv; do echo $filename; done
datasets=seasonal/*.csv
for filename in $datasets; do echo $filename; done
# Many commands chained together in the body 
for file in seasonal/*.csv; do head -n 2 $file | tail -n 1; done
# Loops can contain any number of commands 
# To tell shell where one ends and the next begins, we must seperate them with semi-colons
for f in seasonal/*.csv; do echo $f; head -n 2 $f | tail -n 1; done

# Space in GUI is allowed something like July 2017.csv but in terminal we need to enclose then in single quotes
mv 'July 2017.csv' '2017 July data.csv'




