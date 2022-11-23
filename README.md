cloud-comparison
================

# Terraform

This project uses Terraform for IAC .
You can install on your machine or use a container version. 

```bash
docker run -it -v `pwd`:/app  skillbillsrl/cloud-cicd-toolkit terraform -help
```

terraform version 1.3.5

# Use case

Input  : a image File
Logic  : serverless Python code for image filtering (https://scikit-image.org/)
Output : filtered image File

```bash
cd terraform
docker run -it -v `pwd`:/app  skillbillsrl/cloud-cicd-toolkit terraform init
docker run -it -v `pwd`:/app -e AWS_ACCESS_KEY_ID=[ID] -e AWS_SECRET_ACCESS_KEY=[KEY] skillbillsrl/cloud-cicd-toolkit terraform apply
```