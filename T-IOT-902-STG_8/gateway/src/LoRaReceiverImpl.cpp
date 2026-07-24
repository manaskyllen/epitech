#include "LoRaReceiverImpl.h"
#include "LoRaSerializer.h"
#include <LoRa.h>

LoRaReceiverImpl::LoRaReceiverImpl(long frequency, int ss, int reset, int dio0)
    : _frequency(frequency), _ss(ss), _reset(reset), _dio0(dio0),
      _initialized(false), _lastPacketSize(0) {}

void LoRaReceiverImpl::begin() {
    LoRa.setPins(_ss, _reset, _dio0);
    _initialized = LoRa.begin(_frequency);
}

bool LoRaReceiverImpl::receive(LoRaPacket& packet) {
    if (!_initialized || _lastPacketSize == 0) return false;

    uint8_t buffer[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = 0;

    while (LoRa.available() && len < sizeof(buffer)) {
        buffer[len++] = (uint8_t)LoRa.read();
    }

    _lastPacketSize = 0;
    return LoRaSerializer::deserialize(buffer, len, packet);
}

bool LoRaReceiverImpl::hasData() {
    if (!_initialized) return false;
    _lastPacketSize = LoRa.parsePacket();
    return _lastPacketSize > 0;
}
