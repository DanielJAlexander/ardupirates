/*
 www.ArduCopter.com - www.DIYDrones.com
 Copyright (c) 2010.  All rights reserved.
 An Open Source Arduino based multicopter.
 
 File     : Motors.pde
 Version  : v1.0, Aug 27, 2010
 Author(s): ArduCopter Team
 Ted Carancho (aeroquad), Jose Julio, Jordi Muñoz,
 Jani Hirvinen, Ken McEwans, Roberto Navoni,          
 Sandro Benigno, Chris Anderson
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 * ************************************************************** *
 ChangeLog:
 
 
 * ************************************************************** *
 TODO:
 
 
 * ************************************************************** */



// Send output commands to ESC´s
void motor_output()
{
  int throttle;
  byte throttle_mode=0;
 
  throttle = ch_throttle;
  #ifdef UseBMP
  if (AP_mode == AP_AUTOMATIC_MODE)
    {
    throttle = ch_throttle_altitude_hold;
    throttle_mode=1;
    }
  #endif
  
  if ((throttle_mode==0)&&(ch_throttle < (MIN_THROTTLE + 100)))  // If throttle is low we disable yaw (neccesary to arm/disarm motors safely)
    control_yaw = 0; 

  // Copter motor mix
  if (motorArmed == 1) {   
#ifdef IsAM
    digitalWrite(FR_LED, HIGH);    // AM-Mode
#endif

#if AIRFRAME == QUAD
    // Quadcopter mix
    if(flightOrientation) {
          // For X mode - APM front between front and right motor 
          rightMotor = constrain(throttle - control_roll + control_pitch + control_yaw, minThrottle, 2000); // Right motor
          leftMotor = constrain(throttle + control_roll - control_pitch + control_yaw, minThrottle, 2000);  // Left motor
          frontMotor = constrain(throttle + control_roll + control_pitch - control_yaw, minThrottle, 2000); // Front motor
          backMotor = constrain(throttle - control_roll - control_pitch - control_yaw, minThrottle, 2000);  // Back motor
        } else {
          // For + mode 
          rightMotor = constrain(throttle - control_roll + control_yaw, minThrottle, 2000);
          leftMotor = constrain(throttle + control_roll + control_yaw, minThrottle, 2000);
          frontMotor = constrain(throttle + control_pitch - control_yaw, minThrottle, 2000);
          backMotor = constrain(throttle - control_pitch - control_yaw, minThrottle, 2000);
        }
#endif 
#if AIRFRAME == HEXA
   // Hexacopter mix
        LeftCWMotor = constrain(throttle + control_roll - control_yaw, minThrottle, 2000); // Left Motor CW
        LeftCCWMotor = constrain(throttle + (0.43*control_roll) + (0.89*control_pitch) + control_yaw, minThrottle, 2000); // Left Motor CCW
        RightCWMotor = constrain(throttle - (0.43*control_roll) + (0.89*control_pitch) - control_yaw, minThrottle, 2000); // Right Motor CW
        RightCCWMotor = constrain(throttle - control_roll + control_yaw, minThrottle, 2000); // Right Motor CCW
        BackCWMotor = constrain(throttle - (0.44*control_roll) - control_pitch - control_yaw, minThrottle, 2000);  // Back Motor CW
        BackCCWMotor = constrain(throttle + (0.44*control_roll) - control_pitch + control_yaw, minThrottle, 2000); // Back Motor CCW
#endif 

  } else {    // MOTORS DISARMED

#ifdef IsAM
    digitalWrite(FR_LED, LOW);    // AM-Mode
#endif
    digitalWrite(LED_Green,HIGH); // Ready LED on

#if AIRFRAME == QUAD
      rightMotor = MIN_THROTTLE;
      leftMotor = MIN_THROTTLE;
      frontMotor = MIN_THROTTLE;
      backMotor = MIN_THROTTLE;
#endif

#if AIRFRAME == HEXA
      LeftCWMotor = MIN_THROTTLE;
      LeftCCWMotor = MIN_THROTTLE;
      RightCWMotor = MIN_THROTTLE;
      RightCCWMotor = MIN_THROTTLE;
      BackCWMotor = MIN_THROTTLE;
      BackCCWMotor = MIN_THROTTLE;
#endif

    // Reset_I_Terms();
    roll_I = 0;     // reset I terms of PID controls
    pitch_I = 0;
    yaw_I = 0; 
    
    // Initialize yaw command to actual yaw when throttle is down...
    command_rx_yaw = ToDeg(yaw);
  }

//#if MOTORTYPE == PWM
  // Send commands to motors
#if AIRFRAME == QUAD
    APM_RC.OutputCh(0, rightMotor);   // Right motor
    APM_RC.OutputCh(1, leftMotor);    // Left motor
    APM_RC.OutputCh(2, frontMotor);   // Front motor
    APM_RC.OutputCh(3, backMotor);    // Back motor   
#endif

#if AIRFRAME == HEXA
    APM_RC.OutputCh(0, LeftCWMotor);    // Left Motor CW
    APM_RC.OutputCh(1, LeftCCWMotor);    // Left Motor CCW
    APM_RC.OutputCh(2, RightCWMotor);   // Right Motor CW
    APM_RC.OutputCh(3, RightCCWMotor);   // Right Motor CCW    
    APM_RC.OutputCh(6, BackCWMotor);   // Back Motor CW
    APM_RC.OutputCh(7, BackCCWMotor);   // Back Motor CCW    
#endif

  // InstantPWM => Force inmediate output on PWM signals
#if AIRFRAME == QUAD   
     // InstantPWM
    APM_RC.Force_Out0_Out1();
    APM_RC.Force_Out2_Out3();
#endif

#if AIRFRAME == HEXA
      // InstantPWM
    APM_RC.Force_Out0_Out1();
    APM_RC.Force_Out2_Out3();
    APM_RC.Force_Out6_Out7();
#endif
//#elif MOTORTYPE == I2C

//#else
//# error You need to define your motor type on ArduUder.pde file
//#endif    
}

