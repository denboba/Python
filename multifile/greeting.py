from morning import * 
from evening import *
from afternon import *
print("\n*********************************\n\n\n\n")
print("Hello there ?")
name = input("What is your name?\n")
time = input("what time is now? \n\nmorning,\n\nafternoon,\n\nevening\n\n")
if time == "morning":
    it_is_morning(name)
elif time == "afternoon":
    it_is_afternoon(name)
elif time == "evening":
    it_is_evening(name)
else:
    print(f"I am sorry {name} i dont know {time}")

print("\n\n\n***************************\n")

