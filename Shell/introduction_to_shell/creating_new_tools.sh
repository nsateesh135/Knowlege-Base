# To edit the file in the terminal we can use nano text editor 
# ctrl+O : to save 
# ctrl+x : to exit
nano names.txt

# To record series of commands and write to an output file
history | tail -n 10 > figure-5.history


# Use bash command to run a files containing bash commands
head -n 1 seasonal/*.csv > headers.sh
bash headers.sh

# Use bash to run a file containing bash commands and store output of bash command in another .sh file
cut -d , -f 1 seasonal/*.csv | grep -v Date | sort | uniq > all-dates.sh
bash all-dates.sh > dates.out

# Dynamically pass filenames to scripts using $@
sort $@ | uniq > unique-lines.sh
bash unique-lines.sh seasonal/*.csv


# How to pass multiple values to bash script containing commands 
# We can use $1, #2 ,...
# The 2 parameters are passed in reverse order

cut -d , -f $2 $1 > column.sh
bash column.sh seasonal/autumn.csv 1 



# Write loops in a shell script 
# Shell scripts can also contain loops. We can write them using semi-columns, or split them across lines without semicolumns

# Print the first and last data records of each file
# we don't necessarly have to indent inside the loop but doing so makes things cleaner

for filename in $@ 
do 
  head -n 2 $filename | tail -n 1
  tail -n 1 $filename
done

# Note  if you don't provide filename accidently then the script waits for an input and never executes 
# If this happens then ctrl + c to stop running the script

# The tail goes ahead and prints the last 3 lines of somefile.txt but head waits forever for keyboard input
head -n 5 | tail -n 3 somefile.txt

