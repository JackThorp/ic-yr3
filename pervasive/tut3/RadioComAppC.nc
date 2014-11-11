#include "RadioComC.h"
configuration RadioComAppC {}
implementation {

  components MainC, LedsC, RadioComC;
  components new AMSenderC(AM_RADIO_COUNT_MSG);
  components new AMReceiverC(AM_RADIO_COUNT_MSG);
  components new TimerMilliC();
  components new TempC() as Temp_Sensor;
  components ActiveMessageC;

  RadioComC.Boot -> MainC.Boot;

  RadioComC.Receive     ->  AMReceiverC;
  RadioComC.AMSend      ->  AMSenderC;
  RadioComC.AMControl   ->  ActiveMessageC;
  RadioComC.MilliTimer  ->  TimerMilliC;
  RadioComC.Packet      ->  AMSenderC;
  RadioComC.Temp_Sensor ->  Temp_Sensor;
  RadioComC.Leds        ->  LedsC;
}

