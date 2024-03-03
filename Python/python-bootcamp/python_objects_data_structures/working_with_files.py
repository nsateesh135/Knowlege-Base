# Using open() built in function in Python to interact with files

# pwd: knowing which directory you are on currently 

data_file  = open('/users/nsateesh/data/cities.txt')
data_file = open('cities.txt') # This will work if the file is in the same directory as the Python file


data_file.read() # we can now read the file

#Once the first read operator has executed the function will read the entire file. 
# If we try to execute read again the cursor will be pointing to end of file 
# To re-read the file reser cursor with seek method

data_file.seek(0) # 0 here is index value
data_file.readlines() # Puts the lines in a files as indivudual elements of a list. So to retrieve value we need to iterate

data_file.close() # closes the file after all edits are complete

# Writing to a file
# By default the open() function opens a file in read mode, to open in write mode we need to specify a w parameter 
# w+ parameter helps us read and write 
# Opening a file with 'w or 'w+' truncates the original. So this also means that if there is no exsisting file it will get created by using write operator 

data_file = open('cities.txt','w+')


# Appending to as file 
# passing 'a' as a parameter puts the pointer at the end 

my_file = open('cities.txt','a+')
my_file.write('\n This is text being written to cities.txt')
my_file.write('\nAnd another line is added.')

# printing contents in as file, without storing object values in memory

for abcd in open('cities.txt'):
    print(abcd)


# Packet manager
with open("cities.txt",'r') as f :
    for line in f:
        print(f)


# let's verify if it was really created.
# For that, let's find out which directory we're working from
import os
print(os.path.abspath(os.curdir))
          

