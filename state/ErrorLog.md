
04/07/24

I forgot that in order to enroll an existing aws account into contorol tower that you cannot do so as root.
the way to go is to create an IAM with admin priviledges associated with ControlTower. then it will succeed and this goes for OU 
(organizational unit) as well. 