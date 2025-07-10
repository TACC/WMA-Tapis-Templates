import kalpana.export
import os

pwd = os.getcwd()

print("What is PWD?\n")
print(f"PWD is: {pwd}\n")
print("Hello, world!")

with open("newfile.txt", "w") as f:
    f.write("What is PWD?\n")
    f.write(f"PWD is: {pwd}\n")
    f.write("Hello, world!")
    f.close()