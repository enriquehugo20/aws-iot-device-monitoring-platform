import json
import ssl
import threading

import paho.mqtt.client as mqtt

from config import AWS_IOT_ENDPOINT, AWS_IOT_PORT, ROOT_CA, SENSORS_DIR

SENSOR_ID = "sensor-001"
CERT_DIR = SENSORS_DIR / SENSOR_ID / "certs"

connected = threading.Event()
subscribed = threading.Event()
updated = threading.Event()
received = threading.Event()


def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        print("Connected to AWS IoT Core")

        topics = [
            (f"$aws/things/{SENSOR_ID}/shadow/update/accepted", 1),
            (f"$aws/things/{SENSOR_ID}/shadow/update/rejected", 1),
            (f"$aws/things/{SENSOR_ID}/shadow/get/accepted", 1),
            (f"$aws/things/{SENSOR_ID}/shadow/get/rejected", 1),
        ]

        client.subscribe(topics)
        connected.set()
    else:
        print(f"Connection failed: {reason_code}")


def on_subscribe(client, userdata, mid, reason_code_list, properties):
    subscribed.set()


def on_message(client, userdata, msg):
    payload = json.loads(msg.payload.decode())
    print(f"\n[{msg.topic}]")
    print(json.dumps(payload, indent=2))

    if msg.topic.endswith("/update/accepted"):
        updated.set()
    elif msg.topic.endswith("/get/accepted"):
        received.set()


client = mqtt.Client(
    mqtt.CallbackAPIVersion.VERSION2,
    client_id=SENSOR_ID,
    protocol=mqtt.MQTTv311,
)

client.tls_set(
    ca_certs=str(ROOT_CA),
    certfile=str(CERT_DIR / "certificate.pem"),
    keyfile=str(CERT_DIR / "private.pem"),
    tls_version=ssl.PROTOCOL_TLS_CLIENT,
)

client.on_connect = on_connect
client.on_subscribe = on_subscribe
client.on_message = on_message

try:
    client.connect(AWS_IOT_ENDPOINT, AWS_IOT_PORT)
    client.loop_start()

    if not connected.wait(10):
        raise TimeoutError("MQTT connection timeout")

    if not subscribed.wait(10):
        raise TimeoutError("Shadow subscriptions timeout")

    update = {
        "state": {
            "desired": {
                "reporting_enabled": True,
                "sampling_interval_seconds": 60
            }
        }
    }

    client.publish(
        f"$aws/things/{SENSOR_ID}/shadow/update",
        json.dumps(update),
        qos=1,
    )

    if not updated.wait(10):
        raise TimeoutError("Shadow update was not confirmed")

    client.publish(
        f"$aws/things/{SENSOR_ID}/shadow/get",
        "{}",
        qos=1,
    )

    if not received.wait(10):
        raise TimeoutError("Shadow get was not confirmed")

    print("\nSUCCESS: Device Shadow update and get validated.")

finally:
    client.disconnect()
    client.loop_stop()