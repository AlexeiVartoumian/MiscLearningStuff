

reformaulated the stages to dockerise the app and to store it in the gitlab container registry. used the services to run the image
and inside the script grabbed predefined varibles to authenticate.

finally changed the s3 bucket to point to the elastic beanstalk bucket via env variables and pushed the neccessary manifest files for the docker images to run. used a deploy token on gitlab to authenticate with aws and stored as an additaional variable to deploy from gitlab.