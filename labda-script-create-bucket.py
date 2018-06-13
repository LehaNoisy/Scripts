import boto3, os

def lambda_handler(event, context):
    myS3 = boto3.client('s3')
    try:
        result = myS3.list_buckets()
        print(result)
        output = ""
        for bucket in results['Buckets']:
            output = output + bucket['Name'] + "\n"
        print("<h1><font color=green> S3 Bucket List:</font></h1><br><br>" + output)
    except:
        print("<h1><font color=red>Error!</font></h1><br><br>")
