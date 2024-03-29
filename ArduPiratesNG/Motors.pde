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
  #if (defined(UseBMP) || defined(IsSONAR))
  if (AP_mode == AP_ALTITUDE_HOLD || AP_mode == AP_ALT_GPS_HOLD)
  {
    throttle = ch_throttle_altitude_hold;
    throttle_mode=1;
  }
  #endif
 
  if ((throttle_mode==0)&&(ch_throttle < (MIN_THROTTLE + 100)))  // If throttle is low we disable yaw (neccesary to arm/disarm motors safely)
    control_yaw = 0; 

  // Copter mix
  if (motorArmed == 1) {   
#ifdef IsAM
    digitalWrite(FR_LED, HIGH);    // AM-Mode
#endif

#if AIRFRAME == QUAD
    // Quadcopter mix

#ifndef FLIGHT_MODE_X
    if(flightOrientation) {
          //FLIGHT_MODE_X_45Degree
          // For X mode - (APM-front pointing towards front motor)
          rightMotor = constrain(throttle - control_roll + control_yaw, minThrottle, 2000);
          leftMotor = constrain(throttle + control_roll + control_yaw, minThrottle, 2000);
          frontMotor = constrain(throttle + control_pitch - control_yaw, minThrottle, 2000);
          backMotor = constrain(throttle - control_pitch - control_yaw, minThrottle, 2000);
        } else {
          // For + mode 
          rightMotor = constrain(throttle - control_roll + control_yaw, minThrottle, 2000);
          leftMotor = constrain(throttle + control_roll + control_yaw, minThrottle, 2000);
          frontMotor = constrain(throttle + control_pitch - control_yaw, minThrottle, 2000);
          backMotor = constrain(throttle - control_pitch - control_yaw, minThrottle, 2000);
        }
#endif
#ifdef FLIGHT_MODE_X      
          // For X mode - APM front between front and right motor 
          rightMotor = constrain(throttle - control_roll + control_pitch + control_yaw, minThrottle, 2000); // Right motor
          leftMotor = constrain(throttle + control_roll - control_pitch + control_yaw, minThrottle, 2000);  // Left motor
          frontMotor = constrain(throttle + control_roll + control_pitch - control_yaw, minThrottle, 2000); // Front motor
          backMotor = constrain(throttle - control_roll - control_pitch - control_yaw, minThrottle, 2000);  // Back motor
#endif
#endif 

#if AIRFRAME == HEXA
   // Hexacopter mix
        LeftCWMotor = constrain(throttle + control_roll - (0.5 * control_pitch) - control_yaw, minThrottle, 2000); // Left Motor CW
        LeftCCWMotor = constrain(throttle + control_roll + (0.5 * control_pitch) + control_yaw, minThrottle, 2000); // Left Motor CCW
        RightCWMotor = constrain(throttle - control_roll - (0.5 * control_pitch) - control_yaw, minThrottle, 2000); // Right Motor CW
        RightCCWMotor = constrain(throttle - control_roll + (0.5 * control_pitch) + control_yaw, minThrottle, 2000); // Right Motor CCW
        FrontCWMotor = constrain(throttle + control_pitch - control_yaw, minThrottle, 2000);  // Front Motor CW
        BackCCWMotor = constrain(throttle - control_pitch + control_yaw, minThrottle, 2000); // Back Motor CCW
#endif 

#if AIRFRAME == OCTA
   // Octacopter mix
        Front_MotorCW = constrain(throttle + control_pitch - control_yaw, minThrottle, 2000);  // Front Motor CW
        Front_Right_MotorCCW = constrain(throttle + (0.71*control_pitch) - (0.71*control_roll) + control_yaw, minThrottle, 2000);  // Front Right Motor CCW
        Right_MotorCW = constrain(throttle - control_roll - control_yaw, minThrottle, 2000); // Right Motor CW
        Back_Right_MotorCCW = constrain(throttle - (0.71*control_pitch) - (0.71*control_roll) + control_yaw, minThrottle, 2000); // Back Right Motor CCW
        Back_MotorCW = constrain(throttle - control_pitch - control_yaw, minThrottle, 2000); // Back Motor CW
        Back_Left_MotorCCW = constrain(throttle - (0.71 * control_pitch) + (0.71*control_roll) + control_yaw, minThrottle, 2000); // Back Left Motor CCW
        Left_MotorCW = constrain(throttle + control_roll - control_yaw, minThrottle, 2000); // Left Motor CW
        Front_Left_MotorCCW = constrain(throttle + (0.71*control_pitch) + (0.71*control_roll) + control_yaw, minThrottle, 2000);  // Front Left Motor CCW
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
      FrontCWMotor = MIN_THROTTLE;
      BackCCWMotor = MIN_THROTTLE;
#endif

#if AIRFRAME == OCTA
      Front_MotorCW = MIN_THROTTLE;         // Front Motor CW
      Front_Right_MotorCCW = MIN_THROTTLE;  // Front Right Motor CCW
      Right_MotorCW = MIN_THROTTLE;         // Right Motor CW
      Back_Right_MotorCCW = MIN_THROTTLE;   // Back Right Motor CCW
      Back_MotorCW = MIN_THROTTLE;          // Back Motor CW
      Back_Left_MotorCCW = MIN_THROTTLE;    // Back Left Motor CCW
      Left_MotorCW = MIN_THROTTLE;          // Left Motor CW
      Front_Left_MotorCCW = MIN_THROTTLE;   // Front Left Motor CCW
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
    APM_RC.OutputCh(0, LeftCWMotor);     // Left Motor CW
    APM_RC.OutputCh(1, LeftCCWMotor);    // Left Motor CCW
    APM_RC.OutputCh(2, RightCWMotor);    // Right Motor CW
    APM_RC.OutputCh(3, RightCCWMotor);   // Right Motor CCW    
    APM_RC.OutputCh(6, FrontCWMotor);    // Front Motor CW
    APM_RC.OutputCh(7, BackCCWMotor);    // Back Motor CCW    
#endif

#if AIRFRAME == OCTA
    APM_RC.OutputCh(0, Front_MotorCW);        // Front Motor CW
    APM_RC.OutputCh(1, Front_Right_MotorCCW); // Front Right Motor CCW
    APM_RC.OutputCh(2, Right_MotorCW);        // Right Motor CW
    APM_RC.OutputCh(3, Back_Right_MotorCCW);  // Back Right Motor CCW    
    APM_RC.OutputCh(6, Back_MotorCW);         // Back Motor CW
    APM_RC.OutputCh(7, Back_Left_MotorCCW);   // Back Left Motor CCW
    APM_RC.OutputCh(9, Left_MotorCW);         // Left Motor CW          // Connection PB5 on APM
    APM_RC.OutputCh(10, Front_Left_MotorCCW); // Front Left Motor CCW   // Connection PE3 on APM  
#endif

  // InstantPWM => Force inmediate output on PWM signals
#if AIRFRAME == QUAD   
     // InstantPWM
    APM_RC.Force_Out0_Out1();
    APM_RC.Force_Out2_Out3();
#endif

#if ((AIRFRAME == HEXA) || (AIRFRAME == OCTA))
      // InstantPWM
    APM_RC.Force_Out0_Out1();  // Force Channel 0, 1 & 8
    APM_RC.Force_Out2_Out3();  // Force Channel 2, 3 & 9
    APM_RC.Force_Out6_Out7();  // Force Channel 6, 7 & 10.
#endif

//#elif MOTORTYPE == I2C

//#else
//# error You need to define your motor type on ArduUder.pde file
//#endif    
}


