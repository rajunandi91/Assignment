Cloud Infrastructure Engineer
Take-home technical assessment

Tasks
1. Docker
A basic TypeScript application has been created in the application folder. Create a Dockerfile to build this application, making sure that it runs on your local device.

Answer :- Dockerfile is placed inside the Application folder.

2. CI/CD
▶️ CircleCI
▶️ Bitbucket Pipelines
▶️ Github Actions
Write a YAML-based CI/CD pipeline to build, push and deploy this docker image to an imaginary Amazon Kubernetes Service cluster.

Kubernetes resource definitions have been included in the kubernetes folder.

Use whatever mechanism/tools you think are appropriate/relevant to "deploy" the application.

NOTE: This pipeline does not have to be active. All we're looking for is the YAML file. Minor syntax errors will be overlooked.

Answer :- Github actions yaml file is stored in Assignment/.github/workflows/

3. Infrastructure as Code
▶️ AWS CDK in TypeScript
▶️ Terraform
Create some Infrastructure as Code resources to deploy an EC2 instance and an RDS database to an imaginary AWS account.

The EC2 instance must be able to connect to RDS, and the EC2 instance will need to be accessed as follows:

SSH from IPs 107.22.40.20 and 18.215.226.36
HTTPS traffic from anywhere
Consider other general security best practices.

Assume the default VPC exists and can be used for this infrastructure.

Other configuration can be decided by yourself, based on the instance being used for a low resource usage, low traffic web application.

Answer :- Terraform code is stored in AWS_EC2_RDS folder for the above requirement.

Questions
How long did you spend on this assessment in total?
Answer :- 2-3 hrs

What was the most difficult task?
Answer :- None of them was difficult, However in terms of ranking I would say CI/CD 

If you had an unlimited amount of time to complete this task, what would you have done differently?
Answer:- I would have created Terraform modules for Ec2 and RDS to keep the code dry and reusable. For the CI/CD I would have tried with other technologies as well like Bitbucket, Circle CI for my learning and curosity.
