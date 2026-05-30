import os
import random
from datetime import datetime

from azure.eventgrid import EventGridPublisherClient, EventGridEvent
from azure.core.credentials import AzureKeyCredential

TOPIC_ENDPOINT = os.getenv("TOPIC_ENDPOINT")
TOPIC_KEY = os.getenv("TOPIC_KEY")

assert TOPIC_ENDPOINT is not None
assert TOPIC_KEY is not None


client = EventGridPublisherClient(
    TOPIC_ENDPOINT,
    AzureKeyCredential(TOPIC_KEY)
)

services = [
    "payment-api",
    "auth-service",
    "inventory-service",
    "recommendation-engine"
]

severities = [
    "INFO",
    "WARNING",
    "ERROR"
]

events = []

for _ in range(5):
    service = random.choice(services)
    severity = random.choice(severities)

    event = EventGridEvent(
        subject=f"/services/{service}",
        event_type="Telemetry.Generated",
        data_version="1.0",
        data={
            "service": service,
            "severity": severity,
            "latency_ms": random.randint(50, 3000),
            "timestamp": datetime.utcnow().isoformat(),
            "region": "central-india"
        }
    )

    events.append(event)

client.send(events)

print(f"Successfully sent {len(events)} events")