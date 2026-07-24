#pragma once

#include "IApiClient.h"

class ApiClientStub : public IApiClient {
public:
    void begin() override;
    bool sendData(const LoRaPacket* packets, size_t count) override;
    bool isConnected() override;
};
