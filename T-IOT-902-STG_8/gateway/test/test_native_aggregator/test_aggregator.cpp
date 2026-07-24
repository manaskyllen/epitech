#include <unity.h>
#include "DataAggregatorImpl.h"

void setUp(void) {}
void tearDown(void) {}

static LoRaPacket makePacket(uint8_t nodeId, uint8_t readingCount) {
    LoRaPacket p = {};
    p.nodeId = nodeId;
    p.timestamp = nodeId * 1000;
    p.readingCount = readingCount > 4 ? 4 : readingCount;
    for (uint8_t i = 0; i < p.readingCount; i++) {
        p.readings[i].type = SensorType::TEMPERATURE;
        p.readings[i].value = 20.0f + nodeId + i;
        p.readings[i].timestamp = p.timestamp + i;
    }
    return p;
}

void test_initial_state(void) {
    DataAggregatorImpl agg;
    TEST_ASSERT_EQUAL(0, agg.getPacketCount());
    TEST_ASSERT_NOT_NULL(agg.getPackets());
}

void test_add_single(void) {
    DataAggregatorImpl agg;
    LoRaPacket p = makePacket(1, 2);
    agg.addPacket(p);
    TEST_ASSERT_EQUAL(1, agg.getPacketCount());
    TEST_ASSERT_EQUAL_UINT8(1, agg.getPackets()[0].nodeId);
    TEST_ASSERT_EQUAL_UINT8(2, agg.getPackets()[0].readingCount);
}

void test_add_multiple(void) {
    DataAggregatorImpl agg;
    for (uint8_t i = 0; i < 10; i++) {
        agg.addPacket(makePacket(i, 1));
    }
    TEST_ASSERT_EQUAL(10, agg.getPacketCount());
}

void test_clear(void) {
    DataAggregatorImpl agg;
    agg.addPacket(makePacket(1, 1));
    agg.addPacket(makePacket(2, 1));
    TEST_ASSERT_EQUAL(2, agg.getPacketCount());
    agg.clear();
    TEST_ASSERT_EQUAL(0, agg.getPacketCount());
}

void test_overflow_32_plus_1(void) {
    DataAggregatorImpl agg;
    for (int i = 0; i < 33; i++) {
        agg.addPacket(makePacket((uint8_t)(i % 256), 1));
    }
    TEST_ASSERT_EQUAL(32, agg.getPacketCount()); // capped at MAX_PACKETS
}

void test_clear_and_readd(void) {
    DataAggregatorImpl agg;
    for (int i = 0; i < 32; i++) {
        agg.addPacket(makePacket((uint8_t)i, 1));
    }
    TEST_ASSERT_EQUAL(32, agg.getPacketCount());
    agg.clear();
    TEST_ASSERT_EQUAL(0, agg.getPacketCount());

    agg.addPacket(makePacket(99, 3));
    TEST_ASSERT_EQUAL(1, agg.getPacketCount());
    TEST_ASSERT_EQUAL_UINT8(99, agg.getPackets()[0].nodeId);
    TEST_ASSERT_EQUAL_UINT8(3, agg.getPackets()[0].readingCount);
}

void test_data_integrity(void) {
    DataAggregatorImpl agg;
    for (uint8_t i = 0; i < 5; i++) {
        agg.addPacket(makePacket(i + 1, i + 1));
    }

    const LoRaPacket* packets = agg.getPackets();
    for (uint8_t i = 0; i < 5; i++) {
        TEST_ASSERT_EQUAL_UINT8(i + 1, packets[i].nodeId);
        uint8_t expected = (i + 1) > 4 ? 4 : (i + 1);
        TEST_ASSERT_EQUAL_UINT8(expected, packets[i].readingCount);
        TEST_ASSERT_EQUAL_UINT32((uint32_t)(i + 1) * 1000, packets[i].timestamp);
    }
}

void test_max_packets_constant(void) {
    TEST_ASSERT_EQUAL(32, DataAggregatorImpl::MAX_PACKETS);
}

int main(int argc, char **argv) {
    UNITY_BEGIN();
    RUN_TEST(test_initial_state);
    RUN_TEST(test_add_single);
    RUN_TEST(test_add_multiple);
    RUN_TEST(test_clear);
    RUN_TEST(test_overflow_32_plus_1);
    RUN_TEST(test_clear_and_readd);
    RUN_TEST(test_data_integrity);
    RUN_TEST(test_max_packets_constant);
    UNITY_END();
    return 0;
}
