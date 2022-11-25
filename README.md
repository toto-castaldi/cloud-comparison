cloud-comparison
================

# Python pyenv

```
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
docker run -it -v `pwd`:/app  skillbillsrl/cloud-cicd-toolkit terraform -chdir=terraform init
docker run -it -v `pwd`:/app -e AWS_ACCESS_KEY_ID=[ID] -e AWS_SECRET_ACCESS_KEY=[KEY] skillbillsrl/cloud-cicd-toolkit terraform -chdir=terraform apply

docker run -it -v `pwd`:/app -e AWS_ACCESS_KEY_ID=[ID] -e AWS_SECRET_ACCESS_KEY=[KEY] skillbillsrl/cloud-cicd-toolkit aws s3 cp /app/image.png s3://toto-castaldi-00/
```