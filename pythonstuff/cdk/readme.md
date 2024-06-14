cool stuff! using aws cloud developer kit to use python style function calls to generate otherwise hundreds of lines 
of cloudformation yaml stuff

https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html#getting_started_bootstrap
https://docs.aws.amazon.com/cdk/v2/guide/serverless_example.html
- steps:
once the cdk has been installed  
1. cdk init --language python -> will set up the project withdependencies and a readme with commands relevant for cdk stack stuff
2.on my machine i need to add the virtual environment first to install non-conflict packages 
py -m venv .venv
.\.venv\Scripts\activate  
3.pip install -r requirements.txt
4.IMPORTANT! for cdk to know where to pull the constructs from all files must be written in the generated folder when init occured
i.e if cdk-hello-world is folder and init has been done in there then there will be an additioanl folder generated inside of which will
be name-of-folder-Stack.PY . This is the file to modify.
5. before running make sure cdk is bootstrapped i.e tied to a region and acc number
6. cdk synth -> will pull all the code from step 4 and otuput in terminal a cloudformation yaml file.
7. cdk deploy -> create IAC resources !
8. cdk destroy -> destroys resources. 
 