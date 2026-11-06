
from pathlib import Path

# AWS IoT Core
AWS_IOT_ENDPOINT = "a30poidobk1sv3-ats.iot.us-east-1.amazonaws.com"
AWS_IOT_PORT = 8883

# Project paths
BASE_DIR = Path(__file__).resolve().parent
SENSORS_DIR = BASE_DIR / "sensors"
ROOT_CA = BASE_DIR / "AmazonRootCA1.pem"

# Simulated sensor measurements
SENSORS = {
    "sensor-001": {
        "temperature": 24.5,
        "humidity": 65.0,
    },
    "sensor-002": {
        "temperature": 26.1,
        "humidity": 58.0,
    },
}
