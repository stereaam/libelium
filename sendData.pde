#include <WaspWIFI_PRO.h>
#include <WaspSensorGas_v30.h>
#include <WaspFrame.h>

char node_ID[] = "Sterea_Libelium";

float temperature;
float batteryLevel;
float O2Val;

O2SensorClass O2Sensor(SOCKET_1);
// Percentage values of Oxygen
#define POINT1_PERCENTAGE 0.0    
#define POINT2_PERCENTAGE 5.0  

// Calibration Voltage Obtained during calibration process (in mV)
#define POINT1_VOLTAGE 0.35
#define POINT2_VOLTAGE 2.0

float concentrations[] = {POINT1_PERCENTAGE, POINT2_PERCENTAGE};
float voltages[] =       {POINT1_VOLTAGE, POINT2_VOLTAGE};

uint8_t socket = SOCKET0;
char type[] = "http";
char host[] = "82.78.81.178";
char port[] = "80";
uint8_t error;
uint8_t status;
unsigned long previous;

void setup()
{
 USB.ON();
 RTC.ON();
 RTC.setTime("13:01:11:06:12:33:00");
 frame.setID(node_ID);
 Gases.ON();
 O2Sensor.setCalibrationPoints(voltages, concentrations);
 O2Sensor.ON();
}


void loop()
{
   frame.createFrame(ASCII, node_ID); 
   
   temperature = Gases.getTemperature();
   frame.addSensor(SENSOR_GASES_TC, temperature);
   
   batteryLevel = PWR.getBatteryLevel();
   frame.addSensor(SENSOR_BAT, batteryLevel);

   O2Val = O2Sensor.readConcentration();
   frame.addSensor(SENSOR_GASES_O2, O2Val);
   
   frame.showFrame();

   delay(5000);

  previous = millis();
  error = WIFI_PRO.ON(socket);
  if (error == 0)
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }

  status =  WIFI_PRO.isConnected();

  if (status == true)
  {    
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
    delay(5000);
    
    error = WIFI_PRO.sendFrameToMeshlium(type, host, port, frame.buffer, frame.length);
    if (error == 0)
    {
      USB.println(F("HTTP OK"));          
      USB.print(F("HTTP Time from OFF state (ms):"));    
      USB.println(millis()-previous);
    }
    else
    {
      USB.println(F("Error calling 'getURL' function"));
      WIFI_PRO.printErrorCode();
    }
  }
  else
  {
    USB.print(F("WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }
  
}
