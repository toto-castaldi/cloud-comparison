cloud-comparison
================

# Python pyenv

```bash
if [ ! -d ".venv" ]
then
    pyenv install 3.10.2
    pyenv local 3.10.2
    pip install virtualenv
    virtualenv .venv
fi
. .venv/bin/activate
cd src
pip install -r requirements.txt
```

## Python layers

Thanks to https://github.com/keithrozario/Klayers

# Terraform

This project uses Terraform for IAC .
You can install on your machine or use a container version. 

```bash
docker run -it -v `pwd`:/app  skillbillsrl/cloud-cicd-toolkit terraform -help
```

terraform version 1.3.5

# Use case

Input  : a image File
Logic  : serverless Python code for image manipulation (https://pillow.readthedocs.io/en/stable/#)
Output : filtered image File

```bash
#Terraform
docker run -it -v `pwd`:/app  skillbillsrl/cloud-cicd-toolkit terraform -chdir=terraform init
docker run -it -v `pwd`:/app -e AWS_ACCESS_KEY_ID=[ID] -e AWS_SECRET_ACCESS_KEY=[KEY] skillbillsrl/cloud-cicd-toolkit terraform -chdir=terraform apply

#AWS S3
docker run -it -v `pwd`:/app -e AWS_ACCESS_KEY_ID=[ID] -e AWS_SECRET_ACCESS_KEY=[KEY] skillbillsrl/cloud-cicd-toolkit aws s3 cp /app/image.png s3://toto-castaldi-00/input/
docker run -it -v `pwd`:/app -e AWS_ACCESS_KEY_ID=[ID] -e AWS_SECRET_ACCESS_KEY=[KEY] skillbillsrl/cloud-cicd-toolkit aws s3 sync s3://toto-castaldi-00/output/ .

```