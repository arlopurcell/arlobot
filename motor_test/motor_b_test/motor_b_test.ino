/*
  Motor B Pin Discovery Test

  Motor A works with: ENA=3, IN1=12, IN2=13
  This tests different pin combinations for Motor B only.
*/

// Motor A pins (known to work)
#define MOTOR_A_ENA  3
#define MOTOR_A_IN1  12
#define MOTOR_A_IN2  13

// Test configurations for Motor B
struct MotorBPins {
  int ENB, IN3, IN4;
  const char* name;
};

MotorBPins configs[] = {
  {11, 8, 7, "Config 1: ENB=11, IN3=8, IN4=7"},
  {11, 7, 8, "Config 2: ENB=11, IN3=7, IN4=8"},
  {10, 8, 7, "Config 3: ENB=10, IN3=8, IN4=7"},
  {10, 7, 8, "Config 4: ENB=10, IN3=7, IN4=8"},
  {5, 8, 7, "Config 5: ENB=5, IN3=8, IN4=7"},
  {5, 7, 8, "Config 6: ENB=5, IN3=7, IN4=8"},
  {6, 8, 7, "Config 7: ENB=6, IN3=8, IN4=7"},
  {6, 7, 8, "Config 8: ENB=6, IN3=7, IN4=8"},
  {9, 8, 7, "Config 9: ENB=9, IN3=8, IN4=7"},
  {9, 7, 8, "Config 10: ENB=9, IN3=7, IN4=8"},
};

int numConfigs = 10;

void setup() {
  Serial.begin(9600);
  Serial.println("Motor B Pin Discovery Test");
  Serial.println("==========================");
  Serial.println("Motor A is configured correctly.");
  Serial.println("Testing Motor B configurations...");
  Serial.println();

  // Initialize Motor A pins (known working)
  pinMode(MOTOR_A_ENA, OUTPUT);
  pinMode(MOTOR_A_IN1, OUTPUT);
  pinMode(MOTOR_A_IN2, OUTPUT);

  delay(2000);
}

void loop() {
  // First, test Motor A to confirm it's working
  Serial.println("*** Testing Motor A (should work) ***");
  digitalWrite(MOTOR_A_IN1, HIGH);
  digitalWrite(MOTOR_A_IN2, LOW);
  analogWrite(MOTOR_A_ENA, 255);
  delay(2000);

  analogWrite(MOTOR_A_ENA, 0);
  digitalWrite(MOTOR_A_IN1, LOW);
  digitalWrite(MOTOR_A_IN2, LOW);
  delay(1000);

  Serial.println("Motor A test complete.\n");

  // Now test all Motor B configurations
  for (int i = 0; i < numConfigs; i++) {
    testMotorB(configs[i]);
    delay(1500);
  }

  Serial.println("\n*** All Motor B configs tested! ***");
  Serial.println("Which config made Motor B spin?");
  Serial.println("Repeating in 5 seconds...\n");
  delay(5000);
}

void testMotorB(MotorBPins pins) {
  Serial.println("========================================");
  Serial.println(pins.name);
  Serial.println("========================================");

  // Initialize Motor B pins
  pinMode(pins.ENB, OUTPUT);
  pinMode(pins.IN3, OUTPUT);
  pinMode(pins.IN4, OUTPUT);

  // Test Motor B Forward
  Serial.println("Motor B FORWARD...");
  digitalWrite(pins.IN3, HIGH);
  digitalWrite(pins.IN4, LOW);
  analogWrite(pins.ENB, 255);
  delay(2000);

  // Stop
  analogWrite(pins.ENB, 0);
  delay(500);

  // Test Motor B Backward
  Serial.println("Motor B BACKWARD...");
  digitalWrite(pins.IN3, LOW);
  digitalWrite(pins.IN4, HIGH);
  analogWrite(pins.ENB, 255);
  delay(2000);

  // Stop
  analogWrite(pins.ENB, 0);
  digitalWrite(pins.IN3, LOW);
  digitalWrite(pins.IN4, LOW);

  Serial.println("Test complete.\n");
}
