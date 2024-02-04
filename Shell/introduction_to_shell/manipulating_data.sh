# cat : concatenate to view contents of a file
cat nsateesh.csv

# less : to print large files and scrolls through the output 
# :n for next page, :p previous page and :q to quit 
less seasonal/spring.csv seasonal/summer.csv

# head : scan through the top 10 lines of a file 
# flag -n suggest number of lines -n 3 suggest print 3 lines
head seasonal/summer.csv
head -n 3 seasonal/summer.csv

# ls -R (recursive) - lists everything below the chosen directory 
# ls -F prints a / after name of each directory and * after name of every runable program
ls -R -F /home

# man (mannual): to get information about a command 
man tail 

# cut: selecting only columns from a file
# -f : fields 2 through 5 and column 8
# d , : delimiter <type_of_delimiter>
cut -f 2-5,8 d , values.csv

# first:second:third: use cut to display output 
# Fourth column get added dynamically
cut -d : -f 2-4 

#history : print a list of all commands which were typed recently 
# !<command> to rerun the command which was previously run. Like !head 
head seasonal/summer.csv
ls 
history 
!head 

# grep : selects line according to what they contain 
# grep has various flags like -c print a count of matching lines, 
#-n prints line numbers for matching files, -v invert the match
# -E makes sure we can have a 'or' regexp operator 
grep bicuspid seasonal/winter.csv 
grep molar -v -i seasonal/spring.csv
grep incisor -c seasonal/autumn.csv seasonal/winter.csv
grep -E 'Sydney Carton|Charles Darnay' | wc-l

#sed : Used to search and replace text in a file
# s : flag is seraching and replacing text
# g: makes sure all occurances are replaced
sed 's/Cherno/Cherno City/g'

# paste: combine data files rather than cutting them 
# Sometimes some rows will have wrong number of columns 
paste -d , seasonal/summer.csv seasonal/winter.csv


# How to store a commands output in a file 
head -n 5 seasonal/summer.csv > top.csv

# How to use a command output as an input
head -n 5 seasonal/winter.csv > top.csv
tail -n 3 top.csv

# To combine series of operation(s) we use pipe | operator 
# The output of the first operation is passed on to the next operation
head -n 5 seasonal/summer.csv | tail -n 3 

#select the first column from the spring data;
#remove the header line containing the word "Date"; and
#select the first 10 lines of actual data.
cut -d , -f 1 seasonal/spring.csv | grep -v Date | head -n 10


# wc(word count) : This is used to print number of characters, words and lines in a file
# Available flags -c, -w, -l
grep 2017-07 | wc -l


# Wildcard operator to select files from a directory 
# * : match one or many characters 
# ? : matches single character, 201?.txt matches 2017, 2018 but not 2017-07
# [..] : matches any one of the characters inside the square brackets 20[17].txt matches 201.txt and 207.txt
# {..} : matches any comma seperated values {*.txt.*.csv} 
cut -d , -f 1 seasonal/*
cut -d , -f 1 seasonal/*.csv

# expression that matches singh.pdf and johel.txt but not sandhu.pdf or sandhu.txt
{singh.pdf,j*.txt}


# sort : To sort lines in a text
# By default sorts in ascending order 
# -n : sorts by numerical order, -r: sort by decreasing order 
# -b : ignore leading space, -f: become case insensitive
cut -d , -f 2 seasonal/summer.csv | grep -v Tooth | sort -r

# uniq: remove duplicate lines
# This only removes duplicate lines from adjacent rows
cut -d , -f 2 seasonal/winter.csv | grep -v Tooth | sort | uniq -c 


# To save output of a pipe 
# Don't write to output file in the middle of pipe operation(cut -d , -f 2 seasonal/*.csv > teeth-only.txt | grep -v Tooth), because this will cause the terminal to wait forever and crash
cut -d , -f 2 seasonal/*.csv | grep -v Tooth > teeth-only.txt

# To stop a running program just type ctrl+c (This applies for cmd and terminal)

