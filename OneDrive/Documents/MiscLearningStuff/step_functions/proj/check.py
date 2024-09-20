import psutil
import json
from typing import List , Any
import os
from datetime import datetime


print(psutil.pids())

def write_output(output: List[Any], filename: str = "output.json"):

    with open( filename , "w") as f :
        json.dump(output, f , indent=2)
    print(f"job done")


arr = []

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
new_filename = f"output.json_{timestamp}.json"
for id in psutil.pids():

    proc = psutil.Process(id)
    # print(f"Process{proc} : {id} ")
    # print("\n")
    arr.append(f"Process{proc} : {id} ")
print(len(psutil.pids()))

write_output(arr, new_filename)

