/**
* For basic setup just create a Tle493d() object. If you want to use the wake up mode please use Tle493d_w2b6(). Also
* the setUpdateRate() method is slightly different for different variants
* This example is from the repository from here: https://github.com/Infineon/TLE493D-3DMagnetic-Sensor/
* Please download the library from the above library to be used with this example.
*/

#include <Tle493d.h>
Tle493d Tle493dMagnetic3DSensor = Tle493d();

void setup() {
  Serial.begin(9600);
  while (!Serial);
  Tle493dMagnetic3DSensor.begin();
  Tle493dMagnetic3DSensor.enableTemp();
}

void loop() {
  Tle493dMagnetic3DSensor.updateData();
  delay(10);
  Serial.print(Tle493dMagnetic3DSensor.getX());
  Serial.print(" ");
  Serial.print(Tle493dMagnetic3DSensor.getY());
  Serial.print(" ");
  Serial.println(Tle493dMagnetic3DSensor.getZ());
  delay(50);
}
