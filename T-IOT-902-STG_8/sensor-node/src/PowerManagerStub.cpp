#include "PowerManagerStub.h"

#ifdef ARDUINO
#include <Arduino.h>
#endif

void PowerManagerStub::sleep(uint32_t seconds) {
#ifdef ARDUINO
    delay(seconds * 1000);
#else
    (void)seconds;
#endif
}

WakeReason PowerManagerStub::getWakeReason() {
    return WakeReason::RESET;
}

uint8_t PowerManagerStub::getBatteryLevel() {
    return 100;
}
