#include "RadioComC.h"
module RadioComC
{
  uses interface Timer<TMilli> as SensorTimer;
  uses interface Timer<TMilli> as LedTimer;
  uses interface Boot;
  uses interface Leds;
  uses interface Read<uint16_t> as Temp_Sensor;
}

implementation
{

  enum {
    SAMPLE_PERIOD = 1024,
    LED_FLASH_PERIOD = 50,
  };

  uint16_t temperature_value;

  event void Boot.booted()
  {
    temperature_value = 0;
    call SensorTimer.startPeriodic(SAMPLE_PERIOD);
  }

  event void SensorTimer.fired()
  {
    call Temp_Sensor.read();
    call LedTimer.startOneShot(LED_FLASH_PERIOD);
  }

  event void LedTimer.fired()
  {
    call Leds.led0Toggle();
  }

  event void Temp_Sensor.readDone(error_t result, uint16_t data) {
    temperature_value = data;

  }
}
