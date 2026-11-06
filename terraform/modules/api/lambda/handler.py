import json
import os

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])


def parse_device(item):
    device = dict(item)

    for attribute in ("telemetry", "device_status"):
        if attribute in device:
            try:
                device[attribute] = json.loads(device[attribute])
            except (TypeError, json.JSONDecodeError):
                pass

    return device


def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }


def lambda_handler(event, context):
    path = event.get("rawPath", "")
    path_parameters = event.get("pathParameters") or {}

    device_id = path_parameters.get("device_id")

    if device_id:
        result = table.get_item(
            Key={"device_id": device_id}
        )

        item = result.get("Item")

        if not item:
            return response(404, {"message": "Device not found"})

        return response(200, parse_device(item))

    if path == "/devices":
        devices = []
        scan_kwargs = {}

        while True:
            result = table.scan(**scan_kwargs)
            devices.extend(result.get("Items", []))

            if "LastEvaluatedKey" not in result:
                break

            scan_kwargs["ExclusiveStartKey"] = result["LastEvaluatedKey"]

        return response(200, {
            "count": len(devices),
            "devices": [parse_device(item) for item in devices]
        })

    return response(404, {"message": "Route not found"})