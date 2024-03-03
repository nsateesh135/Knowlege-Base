'''
xml.etree.ElementTree : Implementation of the ElementTree API
'''

import xml.etree.ElementTree as ET

# The inspect module in Python is used to examine various classes available
# in the library
from inspect import getmembers, isclass, isfunction

# We will work with Element and ElementTree Classes
# Display Classes in DT module
for (name,member) in getmembers(ET,isclass):
    if "_" not in name :
        print(name)

# Display Functions in DT module
# fromstring : ET.fromstring(string)-----> Element
# tostring   : ET.tostring(Element)------> String
# parse      : ET.parse(file) -----------> ElementTree  
for (name,member) in getmembers(ET,isfunction):
    if "_" not in name :
        print(name)

