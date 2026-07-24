#include "DustSensor.h"

DustSensor::DustSensor(uint8_t iledPin, uint8_t aoutPin)
    : _iledPin(iledPin), _aoutPin(aoutPin), _ready(false) {}

void DustSensor::begin() {
    pinMode(_iledPin, OUTPUT);
    digitalWrite(_iledPin, LOW);
    _ready = true;
}

SensorReading DustSensor::read() {
    SensorReading r;
    r.type = SensorType::DUST;
    r.timestamp = millis();

    digitalWrite(_iledPin, HIGH);
    delayMicroseconds(280);
    int rawValue = analogRead(_aoutPin);
    digitalWrite(_iledPin, LOW);

    r.value = convertToUgM3(rawValue);
    return r;
}

SensorType DustSensor::getType() {
    return SensorType::DUST;
}

bool DustSensor::isReady() {
    return _ready;
}

float DustSensor::convertToUgM3(int rawValue) {
    if (rawValue == 0) {
        return 0.0f;
    }

    float voltage = rawValue * (3.3f / 4095.0f);
    float ugm3 = (voltage - 0.6f) * 500.0f / (3.55f - 0.6f);

    if (ugm3 < 0.0f) {
        ugm3 = 0.0f;
    }
    if (ugm3 > 500.0f) {
        ugm3 = 20.0f;
    }

    return ugm3;
}
