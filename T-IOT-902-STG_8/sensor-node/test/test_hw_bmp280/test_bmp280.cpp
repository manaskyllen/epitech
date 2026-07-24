#include <Arduino.h>
#include <unity.h>
#include <Adafruit_BMP280.h>

Adafruit_BMP280 bmp;

void setUp(void) {}
void tearDown(void) {}

void test_bmp280_init(void) {
    bool ok = bmp.begin(0x76);
    TEST_ASSERT_TRUE(ok);
}

void test_bmp280_temp_range(void) {
    float temp = bmp.readTemperature();
    TEST_ASSERT_FLOAT_WITHIN(62.5f, 22.5f, temp); // -40 to 85
}

void test_bmp280_pressure_range(void) {
    float pressure = bmp.readPressure() / 100.0f;
    TEST_ASSERT_FLOAT_WITHIN(400.0f, 700.0f, pressure); // 300 to 1100
}

void setup() {
    delay(2000);
    UNITY_BEGIN();
    RUN_TEST(test_bmp280_init);
    RUN_TEST(test_bmp280_temp_range);
    RUN_TEST(test_bmp280_pressure_range);
    UNITY_END();
}

void loop() {}
