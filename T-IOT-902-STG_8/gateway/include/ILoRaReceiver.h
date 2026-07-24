#pragma once

#include "LoRaPacket.h"

class ILoRaReceiver {
public:
    virtual ~ILoRaReceiver() = default;

    virtual void begin() = 0;
    virtual bool receive(LoRaPacket& packet) = 0;
    virtual bool hasData() = 0;
};
