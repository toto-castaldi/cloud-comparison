#!/bin/bash

tfilejpg="$(mktemp /tmp/XXXXXXXXX.jpg)" || exit 1
tfilepng="$(mktemp /tmp/XXXXXXXXX.png)" || exit 1
echo "Image : $tfilepng"
wget -O $tfilejpg https://api.lorem.space/image/movie
convert $tfilejpg $tfilepng
filename=$(basename -- "$tfilepng")
docker run -it -v /tmp:/app -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY skillbillsrl/cloud-cicd-toolkit aws s3 cp /app/$filename s3://toto-castaldi-00/input/