#pragma once

#include "LoRaPacket.h"

class ILoRaSender {
public:
    virtual ~ILoRaSender() = default;

    virtual void begin() = 0;
    virtual bool send(const LoRaPacket& packet) = 0;
    virtual bool isAvailable() = 0;
};
