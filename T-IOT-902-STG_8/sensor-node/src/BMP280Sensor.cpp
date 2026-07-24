#include "BMP280Sensor.h"

bool BMP280Sensor::_initialized = false;
bool BMP280Sensor::_ready = false;

BMP280Sensor::BMP280Sensor(Adafruit_BMP280& bmp, SensorType type)
    : _bmp(bmp), _type(type) {}

void BMP280Sensor::begin() {
    if (!_initialized) {
        _ready = _bmp.begin(0x76);
        _initialized = true;
    }
}

SensorReading BMP280Sensor::read() {
    SensorReading r;
    r.type = _type;
    r.timestamp = millis();

    if (_type == SensorType::TEMPERATURE) {
        r.value = _bmp.readTemperature();
    } else {
        r.value = _bmp.readPressure() / 100.0f;
    }
    return r;
}

SensorType BMP280Sensor::getType() {
    return _type;
}

bool BMP280Sensor::isReady() {
    return _ready;
}
