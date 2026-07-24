#include <Arduino.h>
#include <unity.h>
#include "DustSensor.h"

DustSensor dust(25, 32);

void setUp(void) {}
void tearDown(void) {}

void test_dust_init(void) {
    dust.begin();
    TEST_ASSERT_TRUE(dust.isReady());
}

void test_dust_read_range(void) {
    SensorReading r = dust.read();
    TEST_ASSERT_TRUE(r.value >= 0.0f);
    TEST_ASSERT_TRUE(r.value <= 500.0f);
    TEST_ASSERT_EQUAL_INT((int)SensorType::DUST, (int)r.type);
}

void test_dust_multiple_reads(void) {
    for (int i = 0; i < 3; i++) {
        SensorReading r = dust.read();
        TEST_ASSERT_TRUE(r.value >= 0.0f);
        TEST_ASSERT_TRUE(r.value <= 500.0f);
        delay(100);
    }
}

void setup() {
    delay(2000);
    UNITY_BEGIN();
    RUN_TEST(test_dust_init);
    RUN_TEST(test_dust_read_range);
    RUN_TEST(test_dust_multiple_reads);
    UNITY_END();
}

void loop() {}
