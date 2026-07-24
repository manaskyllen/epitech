#include "ApiClientStub.h"

#ifdef ARDUINO
#include <Arduino.h>
#endif

void ApiClientStub::begin() {
#ifdef ARDUINO
    Serial.println("[ApiClientStub] begin");
#endif
}

bool ApiClientStub::sendData(const LoRaPacket* packets, size_t count) {
#ifdef ARDUINO
    Serial.printf("[ApiClientStub] sendData: %d packets\n", (int)count);
    for (size_t i = 0; i < count; i++) {
        Serial.printf("  packet[%d] node=%d readings=%d\n",
            (int)i, packets[i].nodeId, packets[i].readingCount);
    }
#else
    (void)packets;
    (void)count;
#endif
    return true;
}

bool ApiClientStub::isConnected() {
    return true;
}
