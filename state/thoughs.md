

so this file simply creates a portfolio and a product with terraform on aws service catalog.

todo:
understand how  aws-service catalog works. I have created a template but do now know how to use it.
i.e i can see the administrator side but not the user side.

once that is understood. then I have gone through a very basic runthrough of the entier pipeline with aws service catalog.
that is from the admin and the user side eac of whci have thier own steps to go through.

the next step will be to look ath the entire pipeline of AWS ACCOUNT FACTORY W. Terraform. I will have only broken down one part of this which is the above.

there is a preliminary step which is more complex. it is a singular terraform module containtning 4 repositories. each repo will have a specific function. the idea is to focus on one of these repos of the module which will be account request. 
and then figure out that pipeline which have to use codecommit, code build and dynamodb. never used aws codecommit/build so yeah.

if I can pull the above block off then I would have two very rough parts of the ENTIRE Pipeline down. 