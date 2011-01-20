/*
 www.ArduCopter.com - www.DIYDrones.com
 Copyright (c) 2010.  All rights reserved.
 An Open Source Arduino based multicopter.
 
 File     : ArducopterNG.pde
 Version  : v1.0, 11 October 2010
 Author(s): ArduCopter Team
 Ted Carancho (AeroQuad), Jose Julio, Jordi Muñoz,
 Jani Hirvinen, Ken McEwans, Roberto Navoni,          
 Sandro Benigno, Chris Anderson

 Author(s) : ArduPirates deveopment team                                  
          Philipp Maloney, Norbert, Hein, Igor, Emile  
          
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
 
/* ********************************************************************** */
/* Hardware : ArduPilot Mega + Sensor Shield (Production versions)        */
/* Mounting position : RC connectors pointing backwards                   */
/* This code use this libraries :                                         */
/*   APM_RC : Radio library (with InstantPWM)                             */
/*   AP_ADC : External ADC library                                        */
/*   DataFlash : DataFlash log library                                    */
/*   APM_BMP085 : BMP085 barometer library                                */
/*   AP_Compass : HMC5843 compass library [optional]                      */
/*   GPS_MTK or GPS_UBLOX or GPS_NMEA : GPS library    [optional]         */

/**** Switch Functions *****
// FLIGHT MODE
//  This is determine by DIP Switch 3. // When switching over you have to reboot APM.
// DIP3 down (On) = Acrobatic Mode.  Yellow LED is Flashing. 
// DIP3 up (Off) = Stable Mode.  AUTOPILOT MODE LEDs status lights become applicable.  See below.


 // AUTOPILOT MODE (only works in Stable mode)
 AUX2 OFF && AUX1 OFF = Stable Mode              (AP_mode = 2) Yellow & Red LEDs both OFF
 AUX2 OFF && AUX1 ON  = Altitude Hold only       (AP_mode = 3) Yellow LED ON and RED LED OFF
 AUX2 ON  && AUX1 OFF = Position Hold only       (AP_mode = 4) Yellow LED OFF and RED LED ON (GPS Not Logged - RED LED Flashing)
 AUX2 ON  && AUX1 ON  = Position & Altitude Hold (AP_mode = 5) Yellow & Red LEDs both ON (GPS Not Logged - RED LED Flashing)
// Remember In Configurator MODE(channel) is AUX2

/* ************************************************************ */

/* ************************************************************ */
/* **************** MAIN PROGRAM - MODULES ******************** */
/* ************************************************************ */

/* ************************************************************ */
// User MODULES
//
// Please check your modules settings for every new software downloads you have.
// Also check repository / ArduCopter wiki pages for ChangeLogs and software notes
//
// Comment out with // modules that you are not using
//
// Do check ArduUser.h settings file too !!
//
///////////////////////////////////////
//  Modules Config
// --------------------------

#define IsGPS            // Do we have a GPS connected.  See ArduUser for different GPS Selections.
#define IsMAG            // Do we have a Magnetometer connected, if have remember to activate it from Configurator
#define IsAM           // Do we have motormount LED's. AM = Atraction Mode
//#define IsCAM          // Do we have camera stabilization in use, If you activate, check OUTPUT pins from ArduUser.h
                         // DIP2 down (ON) = Camera Stabilization enabled, DIP2 up (OFF) = Camera Stabilization disabled.
//#define UseCamTrigger  // Do we want to use CH9 (Pin PL3) for camera trigger during GPS Hold or Altitude Hold.                  

//#define UseAirspeed  // Quads don't use AirSpeed... Legacy, jp 19-10-10
#define UseBMP         // Use pressure sensor for altitude hold?
//#define BATTERY_EVENT 1   // (boolean) 0 = don't read battery, 1 = read battery voltage (only if you have it _wired_ up!)
#define IsSONAR        // are we using a Sonar for altitude hold?
//#define IsRANGEFINDER  // are we using range finders for obstacle avoidance?

#define CONFIGURATOR



////////////////////
// Serial ports & speeds

// Serial data, do we have FTDI cable or Xbee on Telemetry port as our primary command link
// If we are using normal FTDI/USB port as our telemetry/configuration, keep next line disabled
//#define SerXbee

// Telemetry port speed, default is 115200
//#define SerBau  19200
//#define SerBau  38400
//#define SerBau  57600
#define SerBau  115200


/* ************************************************* */
//    PWM - QUAD COPTER SETUP                       //

// Frame build condiguration
// FLIGHT_MODE_+    // Traditional "one arm as nose" frame configuration
// FLIGHT_MODE_X    // 2x Options (see below).
// 
//  FLIGHT_MODE_X (APM-front between Front and Right motor).
//   F  CW  0....Front....0 CCW  R        // 0 = Motors
//          ......***......               // *** = APM (APM-front between Front and Right motor)
//          ......***......               // ***
//          ......***......               // *** 
//   L CCW  0....Back.....0  CW  B          L = Left motor, 
//                                          R = Right motor, 
//                                          B = Back motor,
//                                          F = Front motor.  

//  FLIGHT_MODE_X_45Degree (APM-front pointing towards front motor).
//   F  CW  0....Front....0 CCW  R        // 0 = Motors
//          ...****........               // ****  = APM (APM-front pointing towards front motor)
//          ......****.....               //    **** 
//          .........****..               //       ****
//   L CCW  0....Back.....0  CW  B          L = Left motor, 
//                                          R = Right motor, 
//                                          B = Back motor,
//                                          F = Front motor.  


// To change between flight orientations just use DIP switch for that. DIP1 up (off) = X-mode(45Degree), DIP1 down (on)= + mode
// When selecting Flight_Mode_X choice one of the two options below.
//#define FLIGHT_MODE_X            // (APM-front between Front and Right motor).  See layout above. Dip1 is not applicable
#define FLIGHT_MODE_X_45Degree   // (APM-front pointing towards front motor).  See layout above.  Default.  We can switch between + and X mode 

// Double check in configurator - Serial command "T" enter.
// remember after changing DIP switch you must reboot APM.

/**********************************************/
//    PWM - HEXA COPTER SETUP   
//
//  Just change AIRFRAME to HEXA in ArduUser.h

// Frame build condiguration
//Hexa Mode - 6 Motor system

//           F CW 0 
//          ....FRONT....                // 0 = Motors
//    L CCW 0....***....0 CCW R
//          .....***.....                // *** = APM 
//    L CW  0....***....0 CW  R          // ***
//          .....BACK....                // *** 
//          B CCW 0                  F = Front motor, L = Left motors, R = Right motors, B = Back motor.

// Double check in configurator - Serial command "T" enter.
// remember after changing DIP switch you must reboot APM.

/**********************************************/

//  Magnetometer Setup

#ifdef IsMAG
// To get Magneto offsets, switch to CLI mode and run offset calibration. During calibration
// you need to roll/bank/tilt/yaw/shake etc your ArduCoptet. Don't kick like Jani always does :)
//#define MAGOFFSET -76,22.5,-55.5  // Hein's Quad calibration settings.  You have to determine your own.
#define MAGOFFSET -70,55.5,-61.5  // Hein's Hexa calibration settings.  You have to determine your own.

// MAGCALIBRATION is the correction angle in degrees (can be + or -). You must calibrating your magnetometer to show magnetic north correctly.
// After calibration you will have to determine the declination value between Magnetic north and true north, see following link
// http://code.google.com/p/arducopter/wiki/Quad_Magnetos under additional settings. Both values have to be incorporated
// You can check Declination to your location from http://www.magnetic-declination.com/
// Example:  Magnetic north calibration show -1.2 degrees offset and declination (true north) is -5.6 then the MAGCALIBRATION should be -6.8.
// Your GPS readings is based on true north.
// For Magnetic north calibration make sure that your Magnetometer is truly showing 0 degress when your ArduQuad is looking to the North.
// Use a real compass (! not your iPhone) to point your ArduQuad to the magnetic north and then adjust this 
// value until you have a 0 dergrees reading in the configurator's artificial horizon. 
// Once you have achieved this fine tune in the configurator's serial monitor by pressing "T" (capital t).

//#define MAGCALIBRATION -21.65      //  Quad Hein, South Africa, Centurion.  You have to determine your own.
#define MAGCALIBRATION  1.65      //  Hexa Hein, South Africa, Centurion.  You have to determine your own.

// orientations for DIYDrones magnetometer
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_UP_PINS_FORWARD
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_UP_PINS_FORWARD_RIGHT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_UP_PINS_RIGHT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_UP_PINS_BACK_RIGHT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_UP_PINS_BACK
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_UP_PINS_BACK_LEFT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_UP_PINS_LEFT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_UP_PINS_FORWARD_LEFT
#define MAGORIENTATION AP_COMPASS_COMPONENTS_DOWN_PINS_FORWARD      // Hein Hexa
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_DOWN_PINS_FORWARD_RIGHT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_DOWN_PINS_RIGHT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_DOWN_PINS_BACK_RIGHT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_DOWN_PINS_BACK
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_DOWN_PINS_BACK_LEFT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_DOWN_PINS_LEFT
//#define MAGORIENTATION AP_COMPASS_COMPONENTS_DOWN_PINS_FORWARD_LEFT

// orientations for Sparkfun magnetometer
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_UP_PINS_FORWARD
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_UP_PINS_FORWARD_RIGHT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_UP_PINS_RIGHT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_UP_PINS_BACK_RIGHT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_UP_PINS_BACK
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_UP_PINS_BACK_LEFT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_UP_PINS_LEFT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_UP_PINS_FORWARD_LEFT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_DOWN_PINS_FORWARD       //Hein quad
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_DOWN_PINS_FORWARD_RIGHT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_DOWN_PINS_RIGHT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_DOWN_PINS_BACK_RIGHT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_DOWN_PINS_BACK
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_DOWN_PINS_BACK_LEFT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_DOWN_PINS_LEFT
//#define MAGORIENTATION AP_COMPASS_SPARKFUN_COMPONENTS_DOWN_PINS_FORWARD_LEFT

#endif

/**********************************************/
// PID TUNING WITH YOUR RADIO

//PID Tuning using the flightmode 3 position channel in Radio.  You should have at least a 7 channel radio.
//Normally Aux1 will be your 3 position flightmode channel.  Your radio also have to be in Acro (plane) mode.
//Select below if you want to use this function
//#define Use_PID_Tuning

/**********************************************/


/* ************************************************************ */
/* **************** MAIN PROGRAM - INCLUDES ******************* */
/* ************************************************************ */

#include <avr/io.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>
#include <FastSerial.h>
#include <math.h>
#include <APM_RC.h> 		// ArduPilot Mega RC Library
#include <AP_ADC.h>		// ArduPilot Mega Analog to Digital Converter Library 
#include <APM_BMP085.h> 	// ArduPilot Mega BMP085 Library 
#include <DataFlash.h>		// ArduPilot Mega Flash Memory Library
#include <AP_Compass.h>	        // ArduPilot Mega Magnetometer Library
#include <Wire.h>               // I2C Communication library
#include <EEPROM.h>             // EEPROM 
#include <AP_RangeFinder.h>     // RangeFinders (Sonars, IR Sensors)
#include <AP_GPS.h>
#include "Arducopter.h"
#include "ArduUser.h"


#if AIRFRAME == HELI
#include "Heli.h"
#endif

/* Software version */
#define VER 1.54    // Current software version (only numeric values)

// Sensors - declare one global instance
AP_ADC_ADS7844		adc;
APM_BMP085_Class	APM_BMP085;
AP_Compass_HMC5843	AP_Compass;
#ifdef IsSONAR
AP_RangeFinder_MaxsonarXL  AP_RangeFinder_down;  // Default sonar for altitude hold
//AP_RangeFinder_MaxsonarLV  AP_RangeFinder_down;  // Alternative sonar is AP_RangeFinder_MaxsonarLV
#endif
#ifdef IsRANGEFINDER
AP_RangeFinder_MaxsonarLV  AP_RangeFinder_frontRight;
AP_RangeFinder_MaxsonarLV  AP_RangeFinder_backRight;
AP_RangeFinder_MaxsonarLV  AP_RangeFinder_backLeft;
AP_RangeFinder_MaxsonarLV  AP_RangeFinder_frontLeft;
#endif

/* ************************************************************ */
/* ************* MAIN PROGRAM - DECLARATIONS ****************** */
/* ************************************************************ */

byte flightMode;

unsigned long currentTime;  // current time in milliseconds
unsigned long currentTimeMicros = 0, previousTimeMicros = 0;  // current and previous loop time in microseconds
unsigned long mainLoop = 0;
unsigned long mediumLoop = 0;
unsigned long slowLoop = 0;

// 3D Location vectors
// -------------------
struct Location home;                   // home location
struct Location current_loc;            // current location
struct Location next_WP;                // next Waypoint to navigate;
long 	target_altitude;		// used for
long 	offset_altitude;		// used for
long    ground_alt;
boolean	home_is_set = false;            // Flag for if we have gps lock and have set the home location

// GPS variables
// -------------
byte 	ground_start_count	= 5;			// have we achieved first lock and set Home?
const 	float t7			= 10000000.0;	// used to scale GPS values for EEPROM storage
float 	scaleLongUp			= 1;			// used to reverse longtitude scaling
float 	scaleLongDown 		= 1;			// used to reverse longtitude scaling
boolean GPS_light			= false;		// status of the GPS light

// Location & Navigation 
// ---------------------
byte 	wp_radius			= 3;			// meters
long	nav_bearing;						// deg * 100 : 0 to 360 current desired bearing to navigate
long 	target_bearing;						// deg * 100 : 0 to 360 location of the plane to the target
long 	crosstrack_bearing;					// deg * 100 : 0 to 360 desired angle of plane to target

// Location Errors
// ---------------
long 	bearing_error;						// deg * 100 : 0 to 36000 

// Waypoints
// ---------
long 	GPS_wp_distance;					// meters - distance between plane and next waypoint
long 	wp_distance;						// meters - distance between plane and next waypoint
long 	wp_totalDistance;					// meters - distance between old and next waypoint
byte 	wp_total;							// # of Commands total including way
byte 	wp_index;							// Current active command index
byte 	next_wp_index;						// Current active command index

/* ************************************************************ */
/* **************** MAIN PROGRAM - SETUP ********************** */
/* ************************************************************ */
void setup() {

  APM_Init();                // APM Hardware initialization (in System.pde)

  mainLoop = millis();       // Initialize timers
  mediumLoop = mainLoop;
  GPS_timer = mainLoop;
  motorArmed = 0;
  
  GEOG_CORRECTION_FACTOR = 0;   // Geographic correction factor will be automatically calculated

  Read_adc_raw();            // Initialize ADC readings...
  
#ifdef SerXbee
  Serial.begin(SerBau);
  Serial.print("ArduCopter v");
  Serial.println(VER);
  Serial.println("Serial data on Telemetry port");
  Serial.println("No commands or output on this serial, check your Arducopter.pde if needed to change.");
  Serial.println();
  Serial.println("General info:");
  if(!SW_DIP1) Serial.println("Flight mode: + ");
  if(SW_DIP1) Serial.println("Flight mode: x ");
#endif 


  delay(10);
  digitalWrite(LED_Green,HIGH);     // Ready to go...  
}


/* ************************************************************ */
/* ************** MAIN PROGRAM - MAIN LOOP ******************** */
/* ************************************************************ */

// Sensor reading loop is inside AP_ADC and runs at 400Hz (based on Timer2 interrupt)

// * fast rate loop => Main loop => 200Hz
// read sensors
// IMU : update attitude
// motor control
// Asyncronous task : read transmitter
// * medium rate loop (60Hz)
// Asyncronous task : read GPS
// * slow rate loop (10Hz)
// magnetometer
// barometer (20Hz)
// sonar (20Hz)
// obstacle avoidance (20Hz)
// external command/telemetry
// Battery monitor



/* ***************************************************** */
// Main loop 
void loop()
{
  
  currentTimeMicros = micros();
  currentTime = currentTimeMicros / 1000;

  // Main loop at 200Hz (IMU + control)
  if ((currentTime-mainLoop) > 5)    // about 200Hz (every 5ms)
  {
    G_Dt = (currentTimeMicros-previousTimeMicros) * 0.000001;   // Microseconds!!!
    mainLoop = currentTime;
    previousTimeMicros = currentTimeMicros;

    //IMU DCM Algorithm
    Read_adc_raw();       // Read sensors raw data
    Matrix_update(); 
    Normalize();          
    Drift_correction();
    Euler_angles();

    // Read radio values (if new data is available)
    if (APM_RC.GetState() == 1) {  // New radio frame?
#if AIRFRAME == QUAD    
      read_radio();
#endif
#if AIRFRAME == HEXA    
      read_radio();
#endif
#if AIRFRAME == HELI
      heli_read_radio();
#endif
#ifdef Use_PID_Tuning  
      PID_Tuning();  // See Functions.
#endif
    }

    // Attitude control
    if(flightMode == FM_STABLE_MODE) {    // STABLE Mode
      gled_speed = 1200;
      if (AP_mode == AP_NORMAL_STABLE_MODE) {   // Normal mode
#if AIRFRAME == QUAD
        Attitude_control_v3(command_rx_roll,command_rx_pitch,command_rx_yaw);
#endif        
#if AIRFRAME == HEXA
        Attitude_control_v3(command_rx_roll,command_rx_pitch,command_rx_yaw);
#endif       
#if AIRFRAME == HELI
        heli_attitude_control(command_rx_roll,command_rx_pitch,command_rx_collective,command_rx_yaw);
#endif
	  } else if (AP_mode == AP_RTL){
         all_led_speed = 1200;
#if AIRFRAME == QUAD
        Attitude_control_v3(command_rx_roll,command_rx_pitch,command_rtl_yaw);
#endif        
#if AIRFRAME == HEXA
        Attitude_control_v3(command_rx_roll,command_rx_pitch,command_rtl_yaw);
#endif       
#if AIRFRAME == HELI
        heli_attitude_control(command_rx_roll,command_rx_pitch,command_rx_collective,command_rtl_yaw);
#endif		
      }else{                        // Automatic mode : GPS position hold mode
#if AIRFRAME == QUAD      
        Attitude_control_v3(command_rx_roll+command_gps_roll+command_RF_roll,command_rx_pitch+command_gps_pitch+command_RF_pitch,command_rx_yaw);
#endif        
#if AIRFRAME == HEXA      
        Attitude_control_v3(command_rx_roll+command_gps_roll+command_RF_roll,command_rx_pitch+command_gps_pitch+command_RF_pitch,command_rx_yaw);
#endif   
#if AIRFRAME == HELI
        heli_attitude_control(command_rx_roll+command_gps_roll,command_rx_pitch+command_gps_pitch,command_rx_collective,command_rx_yaw);
#endif
      }
    }
    else {                 // ACRO Mode
      gled_speed = 400;
      Rate_control_v2();
      // Reset yaw, so if we change to stable mode we continue with the actual yaw direction
      command_rx_yaw = ToDeg(yaw);
    }

    // Send output commands to motor ESCs...
#if AIRFRAME == QUAD     // we update the heli swashplate at about 60hz
    motor_output();
#endif  
#if AIRFRAME == HEXA     
    motor_output();
#endif    

#ifdef IsCAM
  // Do we have cameras stabilization connected and in use?
  if(!SW_DIP2){ 
    camera_output();
#ifdef UseCamTrigger
    CamTrigger();
#endif
  }
#endif

    // Autopilot mode functions - GPS Hold, Altitude Hold + object avoidance
    if (AP_mode == AP_GPS_HOLD || AP_mode == AP_ALT_GPS_HOLD)
    {
//      digitalWrite(LED_Yellow,HIGH);      // Yellow LED ON : GPS Position Hold MODE

      // Do GPS Position hold (latitude & longitude)
      if (target_position) 
      {
#ifdef IsGPS
        if (GPS.new_data)     // New GPS info?
          {
          if (GPS.fix)
          {
            read_GPS_data();    // In Navigation.pde
            //Position_control(target_latitude,target_longitude);     // Call GPS position hold routine
            Position_control_v2(target_latitude,target_longitude);     // V2 of GPS Position holdCall GPS position hold routine
          }
          else
          {
            command_gps_roll=0;
            command_gps_pitch=0;
          }
        }
#endif
      } else {  // First time we enter in GPS position hold we capture the target position as the actual position
        #ifdef IsGPS
        if (GPS.fix){   // We need a GPS Fix to capture the actual position...
          target_latitude = GPS.latitude;
          target_longitude = GPS.longitude;
          target_position=1;
        }
        #endif
        command_gps_roll=0;
        command_gps_pitch=0;
        Reset_I_terms_navigation();  // Reset I terms (in Navigation.pde)
      }
    }
    if (AP_mode == AP_ALTITUDE_HOLD || AP_mode == AP_ALT_GPS_HOLD)
    {
     // Switch on altitude control if we have a barometer or Sonar
      #if (defined(UseBMP) || defined(IsSONAR))
      if( altitude_control_method == ALTITUDE_CONTROL_NONE ) 
      {
          // by default turn on altitude hold using barometer
          #ifdef UseBMP
          if( press_baro_altitude != 0 ) 
          {
            altitude_control_method = ALTITUDE_CONTROL_BARO;  
            target_baro_altitude = press_baro_altitude;  
            baro_altitude_I = 0;  // don't carry over any I values from previous times user may have switched on altitude control
          }
          #endif
          
          // use sonar if it's available
          #ifdef IsSONAR
          if( sonar_status == SONAR_STATUS_OK && press_sonar_altitude != 0 ) 
          {
            altitude_control_method = ALTITUDE_CONTROL_SONAR;
            target_sonar_altitude = constrain(press_sonar_altitude,AP_RangeFinder_down.min_distance*3,sonar_threshold);
          }
          sonar_altitude_I = 0;  // don't carry over any I values from previous times user may have switched on altitude control          
          #endif
          
          // capture current throttle to use as base for altitude control
          initial_throttle = ch_throttle;
          ch_throttle_altitude_hold = ch_throttle;      
      }
 
      // Sonar Altitude Control
      #ifdef IsSONAR 
      if( sonar_new_data ) // if new sonar data has arrived
      {
        // Allow switching between sonar and barometer
        #ifdef UseBMP
        
        // if SONAR become invalid switch to barometer
        if( altitude_control_method == ALTITUDE_CONTROL_SONAR && sonar_valid_count <= -3  )
        {
          // next target barometer altitude to current barometer altitude + user's desired change over last sonar altitude (i.e. keeps up the momentum)
          altitude_control_method = ALTITUDE_CONTROL_BARO;
          target_baro_altitude = press_baro_altitude;// + constrain((target_sonar_altitude - press_sonar_altitude),-50,50);
        }
   
        // if SONAR becomes valid switch to sonar control
        if( altitude_control_method == ALTITUDE_CONTROL_BARO && sonar_valid_count >= 3  )
        {
          altitude_control_method = ALTITUDE_CONTROL_SONAR;
          if( target_sonar_altitude == 0 ) {  // if target sonar altitude hasn't been intialised before..
            target_sonar_altitude = press_sonar_altitude;// + constrain((target_baro_altitude - press_baro_altitude),-50,50);  // maybe this should just use the user's last valid target sonar altitude         
          }
          // ensure target altitude is reasonable
          target_sonar_altitude = constrain(target_sonar_altitude,AP_RangeFinder_down.min_distance*3,sonar_threshold);
        }      
        #endif  // defined(UseBMP)
       
        // main Sonar control
        if( altitude_control_method == ALTITUDE_CONTROL_SONAR )
        {
          if( sonar_status == SONAR_STATUS_OK ) {
            ch_throttle_altitude_hold = Altitude_control_Sonar(press_sonar_altitude,target_sonar_altitude);  // calculate throttle to maintain altitude
          } else {
            // if sonar_altitude becomes invalid we return control to user temporarily
            ch_throttle_altitude_hold = ch_throttle;
          }            
  
          // modify the target altitude if user moves stick more than 100 up or down
          if( abs(ch_throttle-initial_throttle)>100 ) 
          {
            target_sonar_altitude += (ch_throttle-initial_throttle)/25;
            if( target_sonar_altitude < AP_RangeFinder_down.min_distance*3 )
                target_sonar_altitude = AP_RangeFinder_down.min_distance*3;
            #if !defined(UseBMP)   // limit the upper altitude if no barometer used
            if( target_sonar_altitude > sonar_threshold)
                target_sonar_altitude = sonar_threshold;
            #endif     
          }
        }
        sonar_new_data = 0;  // record that we've consumed the sonar data
      }  // new sonar data
      #endif // #ifdef IsSONAR
      
      // Barometer Altitude control
      #ifdef UseBMP
      if( baro_new_data && altitude_control_method == ALTITUDE_CONTROL_BARO )   // New altitude data?
      {
        ch_throttle_altitude_hold = Altitude_control_baro(press_baro_altitude,target_baro_altitude);   // calculate throttle to maintain altitude
        baro_new_data=0;  // record that we have consumed the new data
        
        // modify the target altitude if user moves stick more than 100 up or down
        if (abs(ch_throttle-initial_throttle)>100) 
        {
          target_baro_altitude += (ch_throttle-initial_throttle)/25;  // Change in stick position => altitude ascend/descend rate control
        }
      }
      #endif
      #endif // defined(UseBMP) || defined(IsSONAR)
      
      // Object avoidance
      #ifdef IsRANGEFINDER
      if( RF_new_data ) 
      {
        Obstacle_avoidance(RF_SAFETY_ZONE);  // main obstacle avoidance function
        RF_new_data = 0;  // record that we have consumed the rangefinder data
      }
      #endif
    }
	if (AP_mode == AP_RTL)
	{
		if(home_is_set)
		{
			if(GPS.fix)
			{
				//yaw_control_RTL(home.lat, home.lng);
                          navigate();
                        }
		}
	}
    if (AP_mode == AP_NORMAL_STABLE_MODE)
    {
//      digitalWrite(LED_Yellow,LOW);
      target_position=0;
      if( altitude_control_method != ALTITUDE_CONTROL_NONE )
      {
        altitude_control_method = ALTITUDE_CONTROL_NONE;  // turn off altitude control
      }
    } 
  }

  // Medium loop (about 60Hz) 
  if ((currentTime-mediumLoop)>=17){
    mediumLoop = currentTime;
    
#if AIRFRAME == HELI    
    // Send output commands to heli swashplate...
    heli_moveSwashPlate();
#endif

    // Each of the six cases executes at 10Hz
    switch (medium_loopCounter){
    case 0:   // Magnetometer reading (10Hz)
      medium_loopCounter++;
      slowLoop++;
#ifdef IsGPS
	  update_GPS();     // Read GPS data 
#endif
#ifdef IsMAG
      if (MAGNETOMETER == 1) {
        AP_Compass.read();     // Read magnetometer
        AP_Compass.calculate(roll,pitch);  // Calculate heading
      }
#endif
      break;
    case 1:  // Barometer + RangeFinder reading (2x10Hz = 20Hz)
      medium_loopCounter++;
#ifdef UseBMP
      if (APM_BMP085.Read()){
        read_baro();
        baro_new_data = 1;
      }
#endif
#ifdef IsSONAR
      read_Sonar(); 
      sonar_new_data = 1;  // process sonar values at 20Hz     
#endif
#ifdef IsRANGEFINDER
      read_RF_Sensors();
      RF_new_data = 1;      
#endif
      break;
    case 2:  // Send serial telemetry (10Hz)
      medium_loopCounter++;
#ifdef CONFIGURATOR
      sendSerialTelemetry();
#endif
      break;
    case 3:  // Read serial telemetry (10Hz)
      medium_loopCounter++;
#ifdef CONFIGURATOR
      readSerialCommand();
#endif
      break;
    case 4:  // second Barometer + RangeFinder reading (2x10Hz = 20Hz)
      medium_loopCounter++;
#ifdef UseBMP
      if (APM_BMP085.Read()){
        read_baro();
        baro_new_data = 1;
      }
#endif
#ifdef IsSONAR
      read_Sonar(); 
      sonar_new_data = 1;  // process sonar values at 20Hz     
#endif
#ifdef IsRANGEFINDER
      read_RF_Sensors();
      RF_new_data = 1;
#endif
      break;
    case 5:  //  Battery monitor (10Hz)
      medium_loopCounter=0;
#if BATTERY_EVENT == 1
      read_battery();         // Battery monitor
#endif
      break;	
    }
    // stuff that happens at 60 hz
    // ---------------------------
	
    // use Yaw to find our bearing error
    calc_bearing_error();
  }

  // AM and Mode status LED lights
  if(millis() - gled_timer > gled_speed) {
    gled_timer = millis();
    if(gled_status == HIGH) { 
      digitalWrite(LED_Green, LOW);
      if (flightMode == FM_ACRO_MODE)
        digitalWrite(LED_Yellow, LOW);
#ifdef IsGPS
      if ((AP_mode == AP_GPS_HOLD || AP_mode == AP_ALT_GPS_HOLD) && GPS.fix < 1)      // Position Hold (GPS position control)
        digitalWrite(LED_Red,LOW);      // Red LED OFF : GPS not FIX
#endif

#ifdef IsAM      
      digitalWrite(RELAY, LOW);
#endif
      gled_status = LOW;
//      SerPrln("L");
    } 
    else {
      digitalWrite(LED_Green, HIGH);
      if (flightMode == FM_ACRO_MODE)
        digitalWrite(LED_Yellow, HIGH);
#ifdef IsGPS
      if ((AP_mode == AP_GPS_HOLD || AP_mode == AP_ALT_GPS_HOLD) && GPS.fix < 1)      // Position Hold (GPS position control)
        digitalWrite(LED_Red,HIGH);      // Red LED ON : GPS not FIX
#endif

#ifdef IsAM
      if(motorArmed) digitalWrite(RELAY, HIGH);
#endif
      gled_status = HIGH;
    } 
  }
  if(flightMode == AP_RTL)
  {
    if(millis() - all_led_timer > all_led_speed) {
    all_led_timer = millis();
    if(all_led_status == LOW)
    {
       digitalWrite(LED_Yellow, HIGH);
       digitalWrite(LED_Green, HIGH);
       digitalWrite(LED_Red, HIGH);
       all_led_status == HIGH;  
     }
   else
     {
       all_led_status == LOW;
     }
   }
  }

}

void update_GPS(){

    GPS.update();     // Read GPS data 
	
	if (GPS.new_data && GPS.fix) {
		//send_message(MSG_LOCATION);

		// for performance
		// ---------------
		//gps_fix_count++;
		
		if(ground_start_count > 1){
			ground_start_count--;
		
		} else if (ground_start_count == 1) {
		
			// We countdown N number of good GPS fixes
			// so that the altitude is more accurate
			// -------------------------------------
			if (current_loc.lat == 0) {
				Serial.println("!! bad loc");
				ground_start_count = 5;
				
			} else {

				//if (log_bitmask & MASK_LOG_CMD)
				//	Log_Write_Startup(TYPE_GROUNDSTART_MSG);
				
				init_home();
				// init altitude
				current_loc.alt = GPS.altitude;
				ground_start_count = 0;
			}
		}

		/* disabled for now
		// baro_offset is an integrator for the gps altitude error 
		baro_offset 	+= altitude_gain * (float)(GPS.altitude - current_loc.alt);
		*/
		
		current_loc.lng = GPS.longitude;	// Lon * 10 * *7
		current_loc.lat = GPS.latitude;		// Lat * 10 * *7
		
		//COGX = cos(ToRad(GPS.ground_course / 100.0));
		//COGY = sin(ToRad(GPS.ground_course / 100.0));

      }
}

// run this at setup on the ground
// -------------------------------
void init_home()
{
	Serial.println("MSG: init home");

	// Extra read just in case
	// -----------------------
	//GPS.Read();

	// block until we get a good fix
	// -----------------------------
	while (!GPS.new_data || !GPS.fix) {
		GPS.update();
	}
	//home.id 	= CMD_WAYPOINT;
	home.lng 	= GPS.longitude;				// Lon * 10**7
	home.lat 	= GPS.latitude;				// Lat * 10**7
	home.alt 	= GPS.altitude;
	home_is_set = true;

        //TEST
        /*
        home.lng = 9180919;
        home.lat = 45469225;
        */

	// ground altitude in centimeters for pressure alt calculations
	// ------------------------------------------------------------
	ground_alt 			= GPS.altitude;
	//pressure_altitude 	= GPS.altitude;  // Set initial value for filter
	//save_EEPROM_pressure();

	// Save Home to EEPROM
	// -------------------
	//set_wp_with_index(home, 0);

	// Save prev loc
	// -------------
	//prev_WP = home;
}
