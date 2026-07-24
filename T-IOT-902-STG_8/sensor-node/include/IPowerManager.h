#pragma once

#include <cstdint>
#include "WakeReason.h"

class IPowerManager {
public:
    virtual ~IPowerManager() = default;

    virtual void sleep(uint32_t seconds) = 0;
    virtual WakeReason getWakeReason() = 0;
    virtual uint8_t getBatteryLevel() = 0;
};
