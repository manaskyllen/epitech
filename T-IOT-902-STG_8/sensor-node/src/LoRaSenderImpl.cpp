#include "LoRaSenderImpl.h"
#include "LoRaSerializer.h"
#include <LoRa.h>

LoRaSenderImpl::LoRaSenderImpl(long frequency, int ss, int reset, int dio0)
    : _frequency(frequency), _ss(ss), _reset(reset), _dio0(dio0), _initialized(false) {}

void LoRaSenderImpl::begin() {
    LoRa.setPins(_ss, _reset, _dio0);
    _initialized = LoRa.begin(_frequency);
    if (_initialized) {
        LoRa.setTxPower(17);
    }
}

bool LoRaSenderImpl::send(const LoRaPacket& packet) {
    if (!_initialized) return false;

    uint8_t buffer[LoRaSerializer::MAX_BUFFER_SIZE];
    size_t len = LoRaSerializer::serialize(packet, buffer, sizeof(buffer));
    if (len == 0) return false;

    LoRa.beginPacket();
    LoRa.write(buffer, len);
    return LoRa.endPacket() == 1;
}

bool LoRaSenderImpl::isAvailable() {
    return _initialized;
}
