import logging
import json

import azure.functions as func


def main(event: func.EventGridEvent):
    result = json.dumps({
        "id": event.id,
        "topic": event.topic,
        "subject": event.subject,
        "event_type": event.event_type,
        "data": event.get_json()
    })

    logging.info(
        "Telemetry Processor received event: %s",
        result
    )