#!/bin/bash
#use chmod u+x trcommands.sh & ./trcommands.sh command
terraform workspace new <workspace name>
terraform workspace select <workspace name>
terraform init 
terraform plan
terraform apply -auto-approve
#hello
