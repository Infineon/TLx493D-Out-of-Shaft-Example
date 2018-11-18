/**
* For basic setup just create a Tlv493d() object. 
* This example is adpated from the repository from here: https://github.com/Infineon/TLV493D-A1B6-3DMagnetic-Sensor
* Please download the library from the above library to be used with this example.
*/

#include <Tlv493d.h>
Tlv493d Tlv493dMagnetic3DSensor = Tlv493d();

void setup() {
  Serial.begin(9600);
  while(!Serial);
  Tlv493dMagnetic3DSensor.begin();
}

void loop() {
  Tlv493dMagnetic3DSensor.updateData();
  delay(10);
  Serial.print(Tlv493dMagnetic3DSensor.getX());
  Serial.print(" ");
  Serial.print(Tlv493dMagnetic3DSensor.getY());
  Serial.print(" ");
  Serial.println(Tlv493dMagnetic3DSensor.getZ());
  delay(50);
}
