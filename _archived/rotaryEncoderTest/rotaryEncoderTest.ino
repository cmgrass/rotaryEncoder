// rotaryEncoderTest
// Christopher Grass - 20170321

// Define global variables
volatile int countVal = 0;

void setup()
  {
    Serial.begin(9600);
    attachInterrupt(0, encoderPulse, RISING);
  }

void loop()
  {
  }

void encoderPulse()
  {
    countVal = countVal + 1;
    Serial.println(countVal);
  }
