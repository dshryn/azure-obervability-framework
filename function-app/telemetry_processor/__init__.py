import json
import logging
import os
from datetime import datetime

import azure.functions as func
from azure.storage.blob import BlobServiceClient


def main(event: func.EventGridEvent):

    

    data = event.get_json()

    service = data.get("service", "unknown-service")
    severity = data.get("severity", "INFO")
    latency = data.get("latency_ms", 0)
    region = data.get("region", "unknown-region")

    log_message = (
        f"service={service} "
        f"severity={severity} "
        f"latency_ms={latency} "
        f"region={region}"
    )
    logging.error(log_message)

    logging.info(
        f"CUSTOM_TELEMETRY "
        f"service={service} "
        f"severity={severity} "
        f"latency_ms={latency}"
    )   

    if severity == "ERROR":
        logging.error(log_message)

    elif severity == "WARNING":
        logging.warning(log_message)

    else:
        logging.info(log_message)

    try:

        connection_string = os.getenv(
            "ARCHIVE_STORAGE_CONNECTION_STRING"
        )

        container_name = os.getenv(
            "ARCHIVE_CONTAINER_NAME"
        )

        blob_service_client = BlobServiceClient.from_connection_string(
            connection_string
        )

        container_client = blob_service_client.get_container_client(
            container_name
        )

        blob_name = (
            f"{service}/"
            f"{datetime.utcnow().strftime('%Y%m%d-%H%M%S-%f')}.json"
        )

        container_client.upload_blob(
            name=blob_name,
            data=json.dumps(data),
            overwrite=False
        )

        logging.info(
            f"Archived telemetry to blob: {blob_name}"
        )

    except Exception as e:

        logging.error(
            f"Blob archival failed: {str(e)}"
        )