#include <unity.h>
#include <cstring>
#include "LoRaSerializer.h"

void setUp(void) {}
void tearDown(void) {}

static LoRaPacket makePacket(uint8_t nodeId, uint8_t count, uint32_t ts) {
    LoRaPacket p = {};
    p.nodeId = nodeId;
    p.timestamp = ts;
    p.readingCount = count > 4 ? 4 : count;
    for (uint8_t i = 0; i < p.readingCount; i++) {
        p.readings[i].type = static_cast<SensorType>(i);
        p.readings[i].value = 10.0f * (i + 1);
        p.readings[i].timestamp = ts + i;
    }
    return p;
}

void test_roundtrip_single_reading(void) {
    LoRaPacket src = makePacket(1, 1, 1000);
    uint8_t buf[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));
    TEST_ASSERT_EQUAL(15, len);

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    TEST_ASSERT_EQUAL_UINT8(1, dst.nodeId);
    TEST_ASSERT_EQUAL_UINT8(1, dst.readingCount);
    TEST_ASSERT_EQUAL_UINT32(1000, dst.timestamp);
    TEST_ASSERT_EQUAL_FLOAT(10.0f, dst.readings[0].value);
}

void test_roundtrip_four_readings(void) {
    LoRaPacket src = makePacket(42, 4, 99999);
    uint8_t buf[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));
    TEST_ASSERT_EQUAL(42, len);

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    TEST_ASSERT_EQUAL_UINT8(42, dst.nodeId);
    TEST_ASSERT_EQUAL_UINT8(4, dst.readingCount);

    for (uint8_t i = 0; i < 4; i++) {
        TEST_ASSERT_EQUAL_FLOAT(10.0f * (i + 1), dst.readings[i].value);
        TEST_ASSERT_EQUAL_INT((int)static_cast<SensorType>(i), (int)dst.readings[i].type);
    }
}

void test_zero_readings(void) {
    LoRaPacket src = makePacket(5, 0, 500);
    uint8_t buf[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));
    TEST_ASSERT_EQUAL(6, len);

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    TEST_ASSERT_EQUAL_UINT8(0, dst.readingCount);
}

void test_buffer_overflow(void) {
    LoRaPacket src = makePacket(1, 4, 0);
    uint8_t buf[10];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));
    TEST_ASSERT_EQUAL(0, len);
}

void test_corrupt_reading_count(void) {
    uint8_t buf[6] = {1, 5, 0, 0, 0, 0};
    LoRaPacket dst = {};
    TEST_ASSERT_FALSE(LoRaSerializer::deserialize(buf, 6, dst));
}

void test_all_sensor_types(void) {
    LoRaPacket src = {};
    src.nodeId = 10;
    src.timestamp = 12345;
    src.readingCount = 4;
    SensorType types[] = {SensorType::DUST, SensorType::TEMPERATURE,
                          SensorType::HUMIDITY, SensorType::PRESSURE};
    for (uint8_t i = 0; i < 4; i++) {
        src.readings[i].type = types[i];
        src.readings[i].value = (float)(i * 100);
        src.readings[i].timestamp = 12345;
    }

    uint8_t buf[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    for (uint8_t i = 0; i < 4; i++) {
        TEST_ASSERT_EQUAL_INT((int)types[i], (int)dst.readings[i].type);
    }
}

void test_negative_float(void) {
    LoRaPacket src = {};
    src.nodeId = 1;
    src.timestamp = 0;
    src.readingCount = 1;
    src.readings[0].type = SensorType::TEMPERATURE;
    src.readings[0].value = -42.5f;
    src.readings[0].timestamp = 0;

    uint8_t buf[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    TEST_ASSERT_EQUAL_FLOAT(-42.5f, dst.readings[0].value);
}

int main(int argc, char **argv) {
    UNITY_BEGIN();
    RUN_TEST(test_roundtrip_single_reading);
    RUN_TEST(test_roundtrip_four_readings);
    RUN_TEST(test_zero_readings);
    RUN_TEST(test_buffer_overflow);
    RUN_TEST(test_corrupt_reading_count);
    RUN_TEST(test_all_sensor_types);
    RUN_TEST(test_negative_float);
    UNITY_END();
    return 0;
}
