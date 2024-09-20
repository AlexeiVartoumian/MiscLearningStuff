after adding in the settings environment variables that point to production and staging , modified the yaml file
to deploy the same application to the respective urls. got rid of additional stages since in each respective environment
the deplouy test stage was a single curl command and was incoroporated into the each environment getting rid of two stages.

p2 yaml file builds on this by extracting the duplicate configuration and using the extends keyword to imple on both environments