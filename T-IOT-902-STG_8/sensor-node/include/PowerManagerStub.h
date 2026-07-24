#pragma once

#include "IPowerManager.h"

class PowerManagerStub : public IPowerManager {
public:
    void sleep(uint32_t seconds) override;
    WakeReason getWakeReason() override;
    uint8_t getBatteryLevel() override;
};
