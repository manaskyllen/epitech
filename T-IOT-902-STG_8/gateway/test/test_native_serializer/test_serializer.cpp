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
    TEST_ASSERT_EQUAL(15, len); // 6 + 1*9

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    TEST_ASSERT_EQUAL_UINT8(1, dst.nodeId);
    TEST_ASSERT_EQUAL_UINT8(1, dst.readingCount);
    TEST_ASSERT_EQUAL_UINT32(1000, dst.timestamp);
    TEST_ASSERT_EQUAL_FLOAT(10.0f, dst.readings[0].value);
    TEST_ASSERT_EQUAL_INT((int)SensorType::DUST, (int)dst.readings[0].type);
}

void test_roundtrip_four_readings(void) {
    LoRaPacket src = makePacket(42, 4, 99999);
    uint8_t buf[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));
    TEST_ASSERT_EQUAL(42, len); // 6 + 4*9

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    TEST_ASSERT_EQUAL_UINT8(42, dst.nodeId);
    TEST_ASSERT_EQUAL_UINT8(4, dst.readingCount);
    TEST_ASSERT_EQUAL_UINT32(99999, dst.timestamp);

    for (uint8_t i = 0; i < 4; i++) {
        TEST_ASSERT_EQUAL_FLOAT(10.0f * (i + 1), dst.readings[i].value);
        TEST_ASSERT_EQUAL_INT((int)static_cast<SensorType>(i), (int)dst.readings[i].type);
        TEST_ASSERT_EQUAL_UINT32(99999 + i, dst.readings[i].timestamp);
    }
}

void test_zero_readings(void) {
    LoRaPacket src = makePacket(5, 0, 500);
    uint8_t buf[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));
    TEST_ASSERT_EQUAL(6, len); // header only

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    TEST_ASSERT_EQUAL_UINT8(5, dst.nodeId);
    TEST_ASSERT_EQUAL_UINT8(0, dst.readingCount);
}

void test_buffer_too_small(void) {
    LoRaPacket src = makePacket(1, 4, 0);
    uint8_t buf[10]; // too small for 4 readings
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));
    TEST_ASSERT_EQUAL(0, len);
}

void test_deserialize_too_short(void) {
    uint8_t buf[3] = {1, 0, 0};
    LoRaPacket dst = {};
    TEST_ASSERT_FALSE(LoRaSerializer::deserialize(buf, 3, dst));
}

void test_deserialize_corrupt_count(void) {
    // readingCount = 5 (> 4) should be rejected
    uint8_t buf[6] = {1, 5, 0, 0, 0, 0};
    LoRaPacket dst = {};
    TEST_ASSERT_FALSE(LoRaSerializer::deserialize(buf, 6, dst));
}

void test_deserialize_truncated_readings(void) {
    // Header says 2 readings but only 6 bytes total (no reading data)
    uint8_t buf[6] = {1, 2, 0, 0, 0, 0};
    LoRaPacket dst = {};
    TEST_ASSERT_FALSE(LoRaSerializer::deserialize(buf, 6, dst));
}

void test_all_sensor_types_roundtrip(void) {
    LoRaPacket src = {};
    src.nodeId = 10;
    src.timestamp = 12345;
    src.readingCount = 4;
    SensorType types[] = {SensorType::DUST, SensorType::TEMPERATURE,
                          SensorType::HUMIDITY, SensorType::PRESSURE};
    for (uint8_t i = 0; i < 4; i++) {
        src.readings[i].type = types[i];
        src.readings[i].value = (float)(i * 100 + 50);
        src.readings[i].timestamp = 12345 + i * 10;
    }

    uint8_t buf[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));
    TEST_ASSERT_GREATER_THAN(0, len);

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    for (uint8_t i = 0; i < 4; i++) {
        TEST_ASSERT_EQUAL_INT((int)types[i], (int)dst.readings[i].type);
        TEST_ASSERT_EQUAL_FLOAT((float)(i * 100 + 50), dst.readings[i].value);
    }
}

void test_negative_float_roundtrip(void) {
    LoRaPacket src = {};
    src.nodeId = 1;
    src.timestamp = 0;
    src.readingCount = 1;
    src.readings[0].type = SensorType::TEMPERATURE;
    src.readings[0].value = -15.5f;
    src.readings[0].timestamp = 0;

    uint8_t buf[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(src, buf, sizeof(buf));

    LoRaPacket dst = {};
    TEST_ASSERT_TRUE(LoRaSerializer::deserialize(buf, len, dst));
    TEST_ASSERT_EQUAL_FLOAT(-15.5f, dst.readings[0].value);
}

void test_max_buffer_size(void) {
    // MAX_BUFFER_SIZE should be 42 (6 + 4*9)
    TEST_ASSERT_EQUAL(42, LoRaSerializer::MAX_BUFFER_SIZE);
}

int main(int argc, char **argv) {
    UNITY_BEGIN();
    RUN_TEST(test_roundtrip_single_reading);
    RUN_TEST(test_roundtrip_four_readings);
    RUN_TEST(test_zero_readings);
    RUN_TEST(test_buffer_too_small);
    RUN_TEST(test_deserialize_too_short);
    RUN_TEST(test_deserialize_corrupt_count);
    RUN_TEST(test_deserialize_truncated_readings);
    RUN_TEST(test_all_sensor_types_roundtrip);
    RUN_TEST(test_negative_float_roundtrip);
    RUN_TEST(test_max_buffer_size);
    UNITY_END();
    return 0;
}
