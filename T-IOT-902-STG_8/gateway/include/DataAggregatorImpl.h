#pragma once

#include <cstring>
#include "IDataAggregator.h"

class DataAggregatorImpl : public IDataAggregator {
public:
    static constexpr size_t MAX_PACKETS = 32;

    DataAggregatorImpl() : _count(0) {
        memset(_packets, 0, sizeof(_packets));
    }

    void addPacket(const LoRaPacket& packet) override {
        if (_count < MAX_PACKETS) {
            _packets[_count++] = packet;
        }
    }

    size_t getPacketCount() override {
        return _count;
    }

    const LoRaPacket* getPackets() override {
        return _packets;
    }

    void clear() override {
        _count = 0;
    }

private:
    LoRaPacket _packets[MAX_PACKETS];
    size_t _count;
};
