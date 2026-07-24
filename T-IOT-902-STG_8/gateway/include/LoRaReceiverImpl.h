#pragma once

#include "ILoRaReceiver.h"

class LoRaReceiverImpl : public ILoRaReceiver {
public:
    LoRaReceiverImpl(long frequency = 868E6, int ss = 18, int reset = 14, int dio0 = 26);

    void begin() override;
    bool receive(LoRaPacket& packet) override;
    bool hasData() override;

private:
    long _frequency;
    int _ss;
    int _reset;
    int _dio0;
    bool _initialized;
    int _lastPacketSize;
};
