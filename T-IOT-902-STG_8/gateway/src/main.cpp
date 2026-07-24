#include <Arduino.h>
#include "ILoRaReceiver.h"
#include "IDataAggregator.h"
#include "IApiClient.h"
#include "LoRaPacket.h"
#include "LoRaReceiverImpl.h"
#include "DataAggregatorImpl.h"
#include "ApiClientStub.h"

// Heltec WiFi LoRa 32 V2: SS=18, RST=14, DIO0=26
LoRaReceiverImpl loraReceiver(868E6, 18, 14, 26);
DataAggregatorImpl aggregator;
ApiClientStub apiClient;

ILoRaReceiver* radio = &loraReceiver;
IDataAggregator* agg = &aggregator;
IApiClient* api = &apiClient;

constexpr size_t BATCH_SIZE = 10;

void setup() {
    Serial.begin(115200);
    radio->begin();
    api->begin();
    Serial.println("[Gateway] Initialized");
}

void loop() {
    if (radio->hasData()) {
        LoRaPacket packet;
        if (radio->receive(packet)) {
            Serial.printf("[Gateway] Received packet from node %d (%d readings)\n",
                packet.nodeId, packet.readingCount);
            agg->addPacket(packet);
        }
    }

    if (agg->getPacketCount() >= BATCH_SIZE) {
        if (api->isConnected()) {
            api->sendData(agg->getPackets(), agg->getPacketCount());
            agg->clear();
        }
    }
}
