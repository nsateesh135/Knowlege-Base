# Print working directory : prints absolute path of your current working directory
pwd 

# To list files in the current directory 
# To list files in a directory you are not on ls <path_of_chosen_directory>
ls 
ls /home/nsateesh


# Absolute path : has a fixed value 
# Relative path : specifies a location from where you are 
# If you are in the directory /home/repl, the relative path seasonal specifies the same directory as absolute path /home/repl/seasonal
ls seasonal

# cd : change directory 
cd /home/repl

# cd .. means the directory above the one I'm currently in. So if you are in /home/repl/seasonal and type cd .. it takes you to /home/repl
# cd . means current directory so no change 
# Cd ~ lists contents of the home directory 

#Copying files from one directory to another 
# Make a copy of seasonal/summer.csv in backup directory calling the new file summer.bck
cp seasonal/summer.csv backup/summer.bck

# Copy spring.csv and summer.csv from seasonal directory to the backup directory 
cp seasonal/spring.csv seasonal/summer.csv backup

# Duplicates contents from summer.csv to duplicate.csv
cp seasonal/summer.csv seasonal/duplicate.csv 

# You are in /home/repl/seasonal directory move autumn and winter files into repl directory
mv autumn.csv winter.csv ..

# Move spring and summer files from seasonal to backup folders
mv seasonal/spring.csv seasona/summer.csv backup

# mv can also be used to rename a file 
# If there was already a file named old-course.txt then the contents of that file will be replaced
mv course.txt old-course.txt 

# Deletes file 
# When we delete the file the file is gone forever. It doesn't store them in trash
rm thesis.txt backup/thesis-2017-08.txt 

#To move contents of one directory into another directory use mv 
mv seasonal by-seasonal 

# To delete a directory use rm -r <name_of_the_directory> or use rmdir
rm -r people 

# To make an empty directory use mkdir 

mkdir yearly 
mkdir /yearly/2017

# /tmp : temporary directory : To store files which we need briefly
# The /tmp directory is immediately below root(/) directory 

cd /tmp 
mkdir scratch
mv /home/repl/people/nsateesh.txt /tmp/scratch
