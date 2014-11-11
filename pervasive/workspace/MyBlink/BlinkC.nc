/**
 * Implementation for MyBlink application. Post tasks to switch LED Toggle the red LED when a
 * Timer fires.
 **/

#include "Timer.h"

module BlinkC @safe()
{
  uses interface Timer<TMilli> as Timer0;
  uses interface Leds;
  uses interface Boot;
}
implementation
{
  event void Boot.booted()
  {
    call Timer0.startPeriodic( 1000 );
  }

  task void toggle() {
    dbg("MyBlinkC", "Toggle Task being executed.\n");
    call Leds.led0Toggle();
  }
 
  event void Timer0.fired()
  {
    dbg("MyBlinkC", "Timer 0 fired @ %s.\n", sim_time_string());
    post toggle();
  }
 
}

