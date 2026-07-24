#include <Arduino.h>
#include "ISensor.h"
#include "ILoRaSender.h"
#include "IConfigServer.h"
#include "IPowerManager.h"
#include "LoRaPacket.h"
#include "BMP280Sensor.h"
#include "DustSensor.h"
#include "LoRaSenderImpl.h"
#include "ConfigServerStub.h"
#include "PowerManagerStub.h"

Adafruit_BMP280 bmp;
BMP280Sensor tempSensor(bmp, SensorType::TEMPERATURE);
BMP280Sensor pressureSensor(bmp, SensorType::PRESSURE);
DustSensor dustSensor(25, 32);

ISensor* sensors[] = { &tempSensor, &pressureSensor, &dustSensor };
constexpr uint8_t SENSOR_COUNT = sizeof(sensors) / sizeof(sensors[0]);

// LILYGO LoRa32: SS=18, RST=23, DIO0=26
LoRaSenderImpl loraSender(868E6, 18, 23, 26);
ConfigServerStub configServer;
PowerManagerStub powerManager;

ILoRaSender* transmitter = &loraSender;
IConfigServer* config = &configServer;
IPowerManager* pm = &powerManager;

constexpr uint8_t NODE_ID = 1;

void setup() {
    Serial.begin(115200);

    for (uint8_t i = 0; i < SENSOR_COUNT; i++) {
        sensors[i]->begin();
    }

    transmitter->begin();
    config->begin();

    Serial.printf("[Node %d] Initialized, LoRa %s\n",
        NODE_ID, transmitter->isAvailable() ? "OK" : "FAIL");
}

void loop() {
    config->handleRequests();

    LoRaPacket packet = {};
    packet.nodeId = NODE_ID;
    packet.timestamp = millis();
    packet.readingCount = 0;

    for (uint8_t i = 0; i < SENSOR_COUNT; i++) {
        if (sensors[i]->isReady() && packet.readingCount < 4) {
            packet.readings[packet.readingCount++] = sensors[i]->read();
        }
    }

    for (uint8_t i = 0; i < packet.readingCount; i++) {
        const SensorReading& r = packet.readings[i];
        Serial.printf("[Node %d] type=%d value=%.2f\n",
            packet.nodeId, (int)r.type, r.value);
    }

    if (transmitter->isAvailable()) {
        bool ok = transmitter->send(packet);
        Serial.printf("[Node %d] LoRa send: %s\n", NODE_ID, ok ? "OK" : "FAIL");
    }

    delay(2000);
}
