#pragma once

#include <Adafruit_BMP280.h>
#include "ISensor.h"

class BMP280Sensor : public ISensor {
public:
    BMP280Sensor(Adafruit_BMP280& bmp, SensorType type);

    void begin() override;
    SensorReading read() override;
    SensorType getType() override;
    bool isReady() override;

private:
    Adafruit_BMP280& _bmp;
    SensorType _type;
    static bool _initialized;
    static bool _ready;
};
