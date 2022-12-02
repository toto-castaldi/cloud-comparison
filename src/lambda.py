import json
import urllib.parse
import boto3
import io
from PIL import ImageFilter, Image

print("Loading function")

s3 = boto3.client("s3")

file_input = "/tmp/input.png"
file_output_tmp = "/tmp/output.png"


def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(event["Records"][0]["s3"]["object"]["key"], encoding="utf-8")
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        print("CONTENT TYPE: " + response["ContentType"])
        
        file_output_s3 = key.replace("input", "output")

        body = response["Body"]
        with io.FileIO(file_input, "w") as file:
            for i in body:
                file.write(i)

        im = Image.open(file_input)
        im_filtered = im.filter(ImageFilter.BLUR)
        im_filtered.save(file_output_tmp)

        s3.put_object(Bucket=bucket, Key=file_output_s3,Body=open(file_output_tmp, "rb"))

        print(file_output_s3)
 
        return file_output_s3
    except Exception as e:
        print(e)
        print("Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.".format(key, bucket))
        raise e