
import argparse
import json
import threading
from datetime import datetime, timezone

import paho.mqtt.client as mqtt

from config import (
    AWS_IOT_ENDPOINT,
    AWS_IOT_PORT,
    ROOT_CA,
    SENSORS,
    SENSORS_DIR,
)


def run_sensor(sensor_id):
    if sensor_id not in SENSORS:
        raise ValueError(f"Unknown sensor: {sensor_id}")

    cert_dir = SENSORS_DIR / sensor_id / "certs"

    certificate = cert_dir / "certificate.pem"
    private_key = cert_dir / "private.pem"

    for file in [ROOT_CA, certificate, private_key]:
        if not file.exists():
            raise FileNotFoundError(f"File not found: {file}")

    connected = threading.Event()
    connection_error = []

    def on_connect(client, userdata, flags, reason_code, properties):
        if reason_code == 0:
            connected.set()
            print(f"[{sensor_id}] Connected to AWS IoT Core")
        else:
            connection_error.append(str(reason_code))
            connected.set()

    client = mqtt.Client(
        callback_api_version=mqtt.CallbackAPIVersion.VERSION2,
        client_id=sensor_id,
        protocol=mqtt.MQTTv311,
    )

    client.tls_set(
        ca_certs=str(ROOT_CA),
        certfile=str(certificate),
        keyfile=str(private_key),
    )

    client.on_connect = on_connect

    loop_started = False

    try:
        client.connect(
            AWS_IOT_ENDPOINT,
            AWS_IOT_PORT,
            keepalive=30,
        )

        client.loop_start()
        loop_started = True

        if not connected.wait(timeout=10):
            raise TimeoutError("MQTT connection timed out")

        if connection_error:
            raise ConnectionError(connection_error[0])

        measurement = SENSORS[sensor_id]

        payload = {
            "temperature": measurement["temperature"],
            "humidity": measurement["humidity"],
            "measured_at": datetime.now(
                timezone.utc
            ).isoformat(),
        }

        topic = f"devices/{sensor_id}/telemetry"

        result = client.publish(
            topic,
            json.dumps(payload),
            qos=1,
        )

        if result.rc != mqtt.MQTT_ERR_SUCCESS:
            raise RuntimeError("Could not publish telemetry")

        result.wait_for_publish(timeout=10)

        if not result.is_published():
            raise TimeoutError("Message delivery was not confirmed")

        print(f"[{sensor_id}] Telemetry published:")
        print(json.dumps(payload, indent=2))
        print(f"[{sensor_id}] Message confirmed by broker")

    finally:
        if loop_started:
            client.disconnect()
            client.loop_stop()

        print(f"[{sensor_id}] Disconnected")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="AWS IoT sensor simulator"
    )

    parser.add_argument(
        "sensor_id",
        choices=list(SENSORS.keys()),
        help="Sensor to execute",
    )

    args = parser.parse_args()
    run_sensor(args.sensor_id)
