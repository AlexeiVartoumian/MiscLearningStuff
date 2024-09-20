
from difflib import Differ

def compare_output_files(file1: str , file2: str) -> None :
    with open(file1 , "r") as f1 , open(file2 , "r") as f2 :
        content1 = f1.readlines()
        content2 = f2.readlines()
    
    differ = Differ()
    diff = list(differ.compare(content1, content2))

    print(f"Differences between {file1} and {file2}:")
    for line in diff:
        if line.startswith('- ') or line.startswith('+ ') or line.startswith('? '):
            print(line)


compare_output_files("output.json_20240819_195344.json" , "output.json_20240819_195427.json")