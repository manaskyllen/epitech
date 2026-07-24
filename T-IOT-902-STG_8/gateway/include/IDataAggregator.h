#pragma once

#include <cstddef>
#include "LoRaPacket.h"

class IDataAggregator {
public:
    virtual ~IDataAggregator() = default;

    virtual void addPacket(const LoRaPacket& packet) = 0;
    virtual size_t getPacketCount() = 0;
    virtual const LoRaPacket* getPackets() = 0;
    virtual void clear() = 0;
};
