#pragma once

#include <cstdint>
#include "SensorData.h"

struct LoRaPacket {
    uint8_t nodeId;
    SensorReading readings[4];
    uint8_t readingCount;
    uint32_t timestamp;
};
