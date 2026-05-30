import logging

import azure.functions as func


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

    if severity == "ERROR":
        logging.error(log_message)

    elif severity == "WARNING":
        logging.warning(log_message)

    else:
        logging.info(log_message)