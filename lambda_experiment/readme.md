

did some basic lammbda stuff with puthon such as creating a basic function testing it. then doing the same thing but from remote ide using a zip file.
saw the same thing but the lambda zip file is in a s3 bucket and pulled from there.
then going into the configuration tab and assigning a function url meaning the function is now reachable via an endppint. then adding an IAM ROLE so that credentials are required to access the lambda. Used Postman to test the url which showed forbidden until the aws access and secret key weere passed in Postman authorisation tab. then created an environemnt variable and assigned it to the lamdba i.e same code for test database and same code for  prod database.

finally saw how creating a layer which I understand as a library where you can import functions steps whre to create a python\lib\python.3.12\site-packages\name_of_folder_where_functions_live\     directory where the functions will live and and __init__.py file to render them. then create a zip file and import that into the layer and any in the lambda can now import that function . inside the lambda it will follow this general syntax
from my_module.my_function import function_from_lambda_layers
from  name_of_folder_where_functions_live.name_of_function_file import actual function

note: be sure the python folder has a  lowercase p as in python not Python and everything is as decribed above