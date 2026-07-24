#include <Arduino.h>
#include <unity.h>
#include "ISensor.h"
#include "LoRaPacket.h"
#include "BMP280Sensor.h"
#include "DustSensor.h"

Adafruit_BMP280 bmp;
BMP280Sensor tempSensor(bmp, SensorType::TEMPERATURE);
BMP280Sensor pressureSensor(bmp, SensorType::PRESSURE);
DustSensor dustSensor(25, 32);

ISensor* sensors[] = { &tempSensor, &pressureSensor, &dustSensor };
constexpr uint8_t SENSOR_COUNT = sizeof(sensors) / sizeof(sensors[0]);

void setUp(void) {}
void tearDown(void) {}

void test_all_sensors_read(void) {
    for (uint8_t i = 0; i < SENSOR_COUNT; i++) {
        sensors[i]->begin();
    }

    for (uint8_t i = 0; i < SENSOR_COUNT; i++) {
        TEST_ASSERT_TRUE(sensors[i]->isReady());
        SensorReading r = sensors[i]->read();
        TEST_ASSERT_TRUE(r.timestamp > 0);
    }
}

void test_packet_build(void) {
    LoRaPacket packet = {};
    packet.nodeId = 1;
    packet.timestamp = millis();
    packet.readingCount = 0;

    for (uint8_t i = 0; i < SENSOR_COUNT; i++) {
        if (sensors[i]->isReady() && packet.readingCount < 4) {
            packet.readings[packet.readingCount++] = sensors[i]->read();
        }
    }

    TEST_ASSERT_EQUAL_UINT8(3, packet.readingCount);
    TEST_ASSERT_EQUAL_UINT8(1, packet.nodeId);
}

void setup() {
    delay(2000);
    UNITY_BEGIN();
    RUN_TEST(test_all_sensors_read);
    RUN_TEST(test_packet_build);
    UNITY_END();
}

void loop() {}
