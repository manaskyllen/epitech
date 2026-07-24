#pragma once

#include "ILoRaSender.h"

class LoRaSenderImpl : public ILoRaSender {
public:
    LoRaSenderImpl(long frequency = 868E6, int ss = 18, int reset = 23, int dio0 = 26);

    void begin() override;
    bool send(const LoRaPacket& packet) override;
    bool isAvailable() override;

private:
    long _frequency;
    int _ss;
    int _reset;
    int _dio0;
    bool _initialized;
};
