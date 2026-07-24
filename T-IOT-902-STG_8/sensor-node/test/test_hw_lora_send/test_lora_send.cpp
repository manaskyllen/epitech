#include <Arduino.h>
#include <unity.h>
#include "LoRaSenderImpl.h"

// LILYGO LoRa32: SS=18, RST=23, DIO0=26
LoRaSenderImpl sender(868E6, 18, 23, 26);

void setUp(void) {}
void tearDown(void) {}

void test_lora_sender_begin(void) {
    sender.begin();
    TEST_ASSERT_TRUE(sender.isAvailable());
}

void test_lora_sender_send_no_crash(void) {
    LoRaPacket packet = {};
    packet.nodeId = 1;
    packet.timestamp = millis();
    packet.readingCount = 1;
    packet.readings[0].type = SensorType::TEMPERATURE;
    packet.readings[0].value = 22.5f;
    packet.readings[0].timestamp = millis();

    bool result = sender.send(packet);
    TEST_ASSERT_TRUE(result);
}

void setup() {
    delay(2000);
    UNITY_BEGIN();
    RUN_TEST(test_lora_sender_begin);
    RUN_TEST(test_lora_sender_send_no_crash);
    UNITY_END();
}

void loop() {}
