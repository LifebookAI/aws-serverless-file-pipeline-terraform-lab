import json
import os
import time
import uuid
from urllib.parse import unquote_plus

import boto3


dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")

TABLE_NAME = os.environ["TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    records = event.get("Records", [])

    processed = []

    for record in records:
        bucket = record["s3"]["bucket"]["name"]
        key = unquote_plus(record["s3"]["object"]["key"])

        object_info = s3.head_object(Bucket=bucket, Key=key)

        file_id = str(uuid.uuid4())
        item = {
            "file_id": file_id,
            "bucket": bucket,
            "object_key": key,
            "size_bytes": object_info.get("ContentLength", 0),
            "content_type": object_info.get("ContentType", "unknown"),
            "etag": object_info.get("ETag", "").replace('"', ""),
            "processed_at_epoch": int(time.time()),
        }

        table.put_item(Item=item)
        processed.append(item)

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Processed S3 event records.",
                "processed_count": len(processed),
                "processed": processed,
            }
        ),
    }