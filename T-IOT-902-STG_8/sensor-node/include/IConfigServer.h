#pragma once

class IConfigServer {
public:
    virtual ~IConfigServer() = default;

    virtual void begin() = 0;
    virtual void stop() = 0;
    virtual bool isClientConnected() = 0;
    virtual void handleRequests() = 0;
};
