
import random

thing = random.randint(1,40)
print(thing)

with open("somefile.txt" , "a+") as f:

    for i in range(random.randint(1,40)):
        for j in range(random.randint(1,40)):
            f.write(str(random.randint(1,40)))
            f.write(" ")
        f.write("\n")

    

    f.close()

result = 0
with open("somefile.txt" , "r") as f:
    inputstr = f.readlines()
    for i in inputstr:
        string = i.rstrip("\n").rstrip()
       
        string =string.split(" ")
        
        
        result += sum(map(int ,string))
        print(result)       

print(result)



