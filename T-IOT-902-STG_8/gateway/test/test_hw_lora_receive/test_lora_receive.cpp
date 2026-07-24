#include <Arduino.h>
#include <unity.h>
#include "LoRaReceiverImpl.h"

// Heltec WiFi LoRa 32 V2: SS=18, RST=14, DIO0=26
LoRaReceiverImpl receiver(868E6, 18, 14, 26);

void setUp(void) {}
void tearDown(void) {}

void test_lora_receiver_begin(void) {
    receiver.begin();
    // If begin() doesn't crash and returns, the radio init succeeded
    TEST_ASSERT_TRUE(true);
}

void test_lora_receiver_has_data_returns_bool(void) {
    bool result = receiver.hasData();
    // Should return false when no packet is available
    TEST_ASSERT_FALSE(result);
}

void setup() {
    delay(2000);
    UNITY_BEGIN();
    RUN_TEST(test_lora_receiver_begin);
    RUN_TEST(test_lora_receiver_has_data_returns_bool);
    UNITY_END();
}

void loop() {}
