#pragma once

#include "ISensor.h"

#ifdef ARDUINO
#include <Arduino.h>
#endif

class DustSensor : public ISensor {
public:
    DustSensor(uint8_t iledPin = 25, uint8_t aoutPin = 32);

    void begin() override;
    SensorReading read() override;
    SensorType getType() override;
    bool isReady() override;

    static float convertToUgM3(int rawValue);

private:
    uint8_t _iledPin;
    uint8_t _aoutPin;
    bool _ready;
};
