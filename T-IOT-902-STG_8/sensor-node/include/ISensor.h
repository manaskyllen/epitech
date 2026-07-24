#pragma once

#include "SensorData.h"

class ISensor {
public:
    virtual ~ISensor() = default;

    virtual void begin() = 0;
    virtual SensorReading read() = 0;
    virtual SensorType getType() = 0;
    virtual bool isReady() = 0;
};
