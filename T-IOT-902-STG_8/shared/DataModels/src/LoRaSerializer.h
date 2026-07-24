#pragma once

#include <cstdint>
#include <cstring>
#include "LoRaPacket.h"

class LoRaSerializer {
public:
    static constexpr size_t MAX_BUFFER_SIZE = 42;

    // Serialize a LoRaPacket into a binary buffer (little-endian).
    // Format: [nodeId:1][readingCount:1][timestamp:4]
    //   per reading: [type:1][value:4 float][timestamp:4]
    // Returns number of bytes written, or 0 on error.
    static size_t serialize(const LoRaPacket& packet, uint8_t* buffer, size_t bufferSize) {
        uint8_t count = packet.readingCount;
        if (count > 4) count = 4;

        size_t needed = 6 + (size_t)count * 9;
        if (bufferSize < needed) return 0;

        size_t pos = 0;
        buffer[pos++] = packet.nodeId;
        buffer[pos++] = count;
        writeU32(buffer, pos, packet.timestamp);
        pos += 4;

        for (uint8_t i = 0; i < count; i++) {
            buffer[pos++] = static_cast<uint8_t>(packet.readings[i].type);
            writeFloat(buffer, pos, packet.readings[i].value);
            pos += 4;
            writeU32(buffer, pos, packet.readings[i].timestamp);
            pos += 4;
        }

        return pos;
    }

    // Deserialize a binary buffer into a LoRaPacket.
    // Returns true on success.
    static bool deserialize(const uint8_t* buffer, size_t length, LoRaPacket& packet) {
        if (length < 6) return false;

        size_t pos = 0;
        packet.nodeId = buffer[pos++];
        uint8_t count = buffer[pos++];
        if (count > 4) return false;

        size_t needed = 6 + (size_t)count * 9;
        if (length < needed) return false;

        packet.timestamp = readU32(buffer, pos);
        pos += 4;
        packet.readingCount = count;

        for (uint8_t i = 0; i < count; i++) {
            packet.readings[i].type = static_cast<SensorType>(buffer[pos++]);
            packet.readings[i].value = readFloat(buffer, pos);
            pos += 4;
            packet.readings[i].timestamp = readU32(buffer, pos);
            pos += 4;
        }

        return true;
    }

private:
    static void writeU32(uint8_t* buf, size_t pos, uint32_t val) {
        buf[pos]     = (uint8_t)(val & 0xFF);
        buf[pos + 1] = (uint8_t)((val >> 8) & 0xFF);
        buf[pos + 2] = (uint8_t)((val >> 16) & 0xFF);
        buf[pos + 3] = (uint8_t)((val >> 24) & 0xFF);
    }

    static uint32_t readU32(const uint8_t* buf, size_t pos) {
        return (uint32_t)buf[pos]
             | ((uint32_t)buf[pos + 1] << 8)
             | ((uint32_t)buf[pos + 2] << 16)
             | ((uint32_t)buf[pos + 3] << 24);
    }

    static void writeFloat(uint8_t* buf, size_t pos, float val) {
        uint32_t bits;
        memcpy(&bits, &val, sizeof(bits));
        writeU32(buf, pos, bits);
    }

    static float readFloat(const uint8_t* buf, size_t pos) {
        uint32_t bits = readU32(buf, pos);
        float val;
        memcpy(&val, &bits, sizeof(val));
        return val;
    }
};
