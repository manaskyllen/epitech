#include <unity.h>
#include "SensorData.h"
#include "LoRaPacket.h"

void setUp(void) {}
void tearDown(void) {}

void test_packet_structure(void) {
    LoRaPacket packet = {};
    packet.nodeId = 1;
    packet.timestamp = 12345;
    packet.readingCount = 0;

    SensorReading r;
    r.type = SensorType::TEMPERATURE;
    r.value = 22.5f;
    r.timestamp = 12345;

    packet.readings[packet.readingCount++] = r;

    TEST_ASSERT_EQUAL_UINT8(1, packet.nodeId);
    TEST_ASSERT_EQUAL_UINT32(12345, packet.timestamp);
    TEST_ASSERT_EQUAL_UINT8(1, packet.readingCount);
    TEST_ASSERT_EQUAL_FLOAT(22.5f, packet.readings[0].value);
    TEST_ASSERT_EQUAL_INT((int)SensorType::TEMPERATURE, (int)packet.readings[0].type);
}

void test_packet_max_readings(void) {
    LoRaPacket packet = {};
    packet.readingCount = 0;

    for (int i = 0; i < 6; i++) {
        if (packet.readingCount < 4) {
            SensorReading r;
            r.type = SensorType::DUST;
            r.value = (float)i;
            r.timestamp = 0;
            packet.readings[packet.readingCount++] = r;
        }
    }

    TEST_ASSERT_EQUAL_UINT8(4, packet.readingCount);
}

void test_sensor_types_exist(void) {
    SensorType dust = SensorType::DUST;
    SensorType temp = SensorType::TEMPERATURE;
    SensorType hum = SensorType::HUMIDITY;
    SensorType pres = SensorType::PRESSURE;
    SensorType snd = SensorType::SOUND;

    TEST_ASSERT_NOT_EQUAL((int)dust, (int)temp);
    TEST_ASSERT_NOT_EQUAL((int)temp, (int)hum);
    TEST_ASSERT_NOT_EQUAL((int)hum, (int)pres);
    TEST_ASSERT_NOT_EQUAL((int)pres, (int)snd);
}

int main(int argc, char **argv) {
    UNITY_BEGIN();
    RUN_TEST(test_packet_structure);
    RUN_TEST(test_packet_max_readings);
    RUN_TEST(test_sensor_types_exist);
    UNITY_END();
    return 0;
}
