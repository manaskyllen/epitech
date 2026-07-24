#pragma once

#include <cstdint>

enum class SensorType {
    DUST,
    TEMPERATURE,
    HUMIDITY,
    PRESSURE,
    SOUND
};

struct SensorReading {
    SensorType type;
    float value;
    uint32_t timestamp;
};
