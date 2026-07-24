#pragma once

#include <cstddef>
#include "LoRaPacket.h"

class IApiClient {
public:
    virtual ~IApiClient() = default;

    virtual void begin() = 0;
    virtual bool sendData(const LoRaPacket* packets, size_t count) = 0;
    virtual bool isConnected() = 0;
};
