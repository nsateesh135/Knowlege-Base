# __name__ = "__main__"
# __name__ : is the first variable which gets set each time we run a Python file 
# If we are executing a python file with functions in them  __name__ = "__main__"
# Think of it like directly Python script which is the entry point 

# What happens when we import functions from another file?
# Then __name__ is set to the name of the imported function

# Another use case would be to explain order of execution of functions in a python file

def func1 ():
    pass

def func2():
    pass
def func3():
    pass

if __name__ == "__main__":
    # Run the script
    func2()
    func3()
    func1()
##############################################################################################

def calculate_area(base,height):
    print(f"__name__ : {__name__}")
    return 1/2*(base*height)

if __name__ == "__main__":
    print("I am in the main file")
    a= calculate_area(10)
    print(f"area: {a}")
