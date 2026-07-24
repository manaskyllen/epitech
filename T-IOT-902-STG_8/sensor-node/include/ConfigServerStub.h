#pragma once

#include "IConfigServer.h"

class ConfigServerStub : public IConfigServer {
public:
    void begin() override;
    void stop() override;
    bool isClientConnected() override;
    void handleRequests() override;
};
