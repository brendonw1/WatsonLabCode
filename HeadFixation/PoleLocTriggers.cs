// Puts Zaber linear actuators (NA Series) under the control of
// Bpod through a Matlab script for pole location in head-fixed mice:
// PoleLocTraining.m, also available in this repository.
//
// Necessary hardware
//
// - Bpod State Machine combined with Bpod Analog Output Module
//   (USB ports COM10 and COM6, respectively): sends digital and
//   analog commands to Zaber, among other functions
//   (see PoleLocTraining.m).
//
// - Zaber X-MCB2 (USB port COM8): converts Bpod commands into actuator
//   movements through the triggers configured below, provided that
//   cabling is set up correctly. This Zaber device handles up to six
//   triggers and four stream buffers.
//
// USAGE ______________________________________________________________
// Load the Zaber Console software, open the X-MCB2 device, and run
// this script to set the triggers. Check if "completed" appears in the
// Script Output area. Repeat if the device was restarted.
//
// LSBuenoJr, with inputs from Zaber Technical Support and Wiki 
// (https://www.zaber.com/wiki/Software/Zaber_Console/Scripting) ______



// Basic settings
#template(Simple)
var both      = PortFacade.GetConversation(1);
var axis1     = PortFacade.GetConversation(1,1);
var axis2     = PortFacade.GetConversation(1,2);
both.Request("home");
both.PollUntilIdle();

// Stream buffer parameters (defined in pilot studies).
var delay     = 1000;  // In milliseconds
var axis1_pos = 50000; // In microsteps
var axis2_pos = 0;

// Sets a stream buffer to control axis 1 and, therefore, the vertical
// extension/retraction of the whisker pole. This stream buffer sends
// both axes "back home" after a delay.
both.Request("stream buffer 1 erase");
both.Request("stream 1 setup store 1 2");

both.Request("stream 1 line rel " + (axis1_pos) + " " + (axis2_pos));
both.Request("stream 1 wait" + " " + (delay));
both.Request("stream 1 line abs 0 0");
both.Request("stream 1 setup disable");

// Assigns the stream buffer as trigger #1.
both.Request("trigger 1 when io di 2 == 0");
both.Request("trigger 1 action a stream 1 setup live 1 2");
both.Request("trigger 1 action b stream 1 call 1");
both.Request("trigger 1 enable");

// Sets the other five available triggers without using stream buffers.
// These triggers will horizontally move axis 2 to locations defined in
// pilot studies.
both.Request("trigger 2 when io ai 1 > 10000");
both.Request("trigger 2 action a 2 move abs 10000");
both.Request("trigger 2 enable");

both.Request("trigger 3 when io ai 2 > 10000");
both.Request("trigger 3 action a 2 move abs 20000");
both.Request("trigger 3 enable");

both.Request("trigger 4 when io ai 3 > 10000");
both.Request("trigger 4 action a 2 move abs 30000");
both.Request("trigger 4 enable");

both.Request("trigger 5 when io ai 4 > 10000");
both.Request("trigger 5 action a 2 move abs 40000");
both.Request("trigger 5 enable");

both.Request("trigger 6 when io di 3 == 1");
both.Request("trigger 6 action a 2 move abs 50000");
both.Request("trigger 6 enable");