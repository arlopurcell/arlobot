/*
  Arduino UNO R4 WiFi BLE Robot Controller

  This sketch sets up the Arduino in BLE pairing mode and waits for
  a connection from an Android app. When joystick position data is
  received via BLE, it controls two DC motors using differential drive.

  Required Library: ArduinoBLE (install via Library Manager)
*/

#include <ArduinoBLE.h>

// BLE Service and Characteristic UUIDs
// You can generate your own UUIDs at https://www.uuidgenerator.net/
#define SERVICE_UUID        "19B10000-E8F2-537E-4F6C-D104768A1214"
#define CHARACTERISTIC_UUID "19B10001-E8F2-537E-4F6C-D104768A1214"

// Motor Pin Definitions for L298P Shield
// Adjust these pins if your shield uses different connections
// Motor A (Left Motor)
#define MOTOR_A_PWM  10   // Speed control (ENA)
#define MOTOR_A_IN1  12   // Direction pin 1
#define MOTOR_A_IN2  13   // Direction pin 2

// Motor B (Right Motor)
#define MOTOR_B_PWM  5    // Speed control (ENB)
#define MOTOR_B_IN1  8    // Direction pin 1
#define MOTOR_B_IN2  7    // Direction pin 2

// Motor speed limits (0-255)
#define MAX_SPEED 255
#define DEADZONE 0.1      // Joystick deadzone to prevent motor jitter

// BLE Service
BLEService messageService(SERVICE_UUID);

// BLE Characteristic - allows write from central device
BLEStringCharacteristic messageCharacteristic(CHARACTERISTIC_UUID, BLEWrite, 100);

void setup() {
  // Initialize serial communication
  Serial.begin(9600);
  while (!Serial);  // Wait for serial port to connect

  Serial.println("Arduino UNO R4 WiFi - BLE Robot Controller");
  Serial.println("===========================================");

  // Initialize motor pins
  pinMode(MOTOR_A_PWM, OUTPUT);
  pinMode(MOTOR_A_IN1, OUTPUT);
  pinMode(MOTOR_A_IN2, OUTPUT);
  pinMode(MOTOR_B_PWM, OUTPUT);
  pinMode(MOTOR_B_IN1, OUTPUT);
  pinMode(MOTOR_B_IN2, OUTPUT);

  // Stop motors initially
  stopMotors();

  // Initialize BLE
  if (!BLE.begin()) {
    Serial.println("ERROR: Starting BLE failed!");
    while (1);  // Halt if BLE can't start
  }

  // Set BLE device name (this will appear when scanning)
  BLE.setLocalName("ArloBot");

  // Set the advertised service
  BLE.setAdvertisedService(messageService);

  // Add the characteristic to the service
  messageService.addCharacteristic(messageCharacteristic);

  // Add the service
  BLE.addService(messageService);

  // Set initial value for the characteristic
  messageCharacteristic.writeValue("");

  // Start advertising (pairing mode)
  BLE.advertise();

  Serial.println("Motors initialized");
  Serial.println("BLE device is now advertising...");
  Serial.println("Waiting for connections...");
  Serial.println("Device name: ArloBot");
  Serial.println();
}

void loop() {
  // Listen for BLE central devices (phone/tablet)
  BLEDevice central = BLE.central();

  // If a central device is connected
  if (central) {
    Serial.print("Connected to central device: ");
    Serial.println(central.address());

    // While the central device is connected
    while (central.connected()) {
      // Check if the characteristic has been written to
      if (messageCharacteristic.written()) {
        String joystickData = messageCharacteristic.value();

        // Parse joystick X and Y values from "X:0.50,Y:-0.75"
        float joyX = 0.0;
        float joyY = 0.0;

        if (parseJoystick(joystickData, joyX, joyY)) {
          // Apply differential drive algorithm
          float leftSpeed = joyY + joyX;
          float rightSpeed = joyY - joyX;

          // Clamp values to [-1.0, 1.0]
          leftSpeed = constrain(leftSpeed, -1.0, 1.0);
          rightSpeed = constrain(rightSpeed, -1.0, 1.0);

          // Control motors
          setMotorSpeed(leftSpeed, rightSpeed);

          // Debug output
          Serial.print("X: ");
          Serial.print(joyX, 2);
          Serial.print(" Y: ");
          Serial.print(joyY, 2);
          Serial.print(" | L: ");
          Serial.print(leftSpeed, 2);
          Serial.print(" R: ");
          Serial.println(rightSpeed, 2);
        }
      }
    }

    // When the central device disconnects
    Serial.print("Disconnected from central device: ");
    Serial.println(central.address());
    stopMotors();
    Serial.println("Waiting for new connections...");
    Serial.println();
  }
}

// Parse joystick data from format "X:0.50,Y:-0.75"
bool parseJoystick(String data, float &x, float &y) {
  int xIndex = data.indexOf("X:");
  int yIndex = data.indexOf("Y:");
  int commaIndex = data.indexOf(",");

  if (xIndex == -1 || yIndex == -1 || commaIndex == -1) {
    return false;
  }

  String xStr = data.substring(xIndex + 2, commaIndex);
  String yStr = data.substring(yIndex + 2);

  x = xStr.toFloat();
  y = yStr.toFloat();

  return true;
}

// Control both motors with differential drive
void setMotorSpeed(float leftSpeed, float rightSpeed) {
  // Apply deadzone
  if (abs(leftSpeed) < DEADZONE) leftSpeed = 0;
  if (abs(rightSpeed) < DEADZONE) rightSpeed = 0;

  // Control left motor
  if (leftSpeed > 0) {
    // Forward
    digitalWrite(MOTOR_A_IN1, HIGH);
    digitalWrite(MOTOR_A_IN2, LOW);
    analogWrite(MOTOR_A_PWM, (int)(leftSpeed * MAX_SPEED));
  } else if (leftSpeed < 0) {
    // Backward
    digitalWrite(MOTOR_A_IN1, LOW);
    digitalWrite(MOTOR_A_IN2, HIGH);
    analogWrite(MOTOR_A_PWM, (int)(-leftSpeed * MAX_SPEED));
  } else {
    // Stop
    digitalWrite(MOTOR_A_IN1, LOW);
    digitalWrite(MOTOR_A_IN2, LOW);
    analogWrite(MOTOR_A_PWM, 0);
  }

  // Control right motor
  if (rightSpeed > 0) {
    // Forward
    digitalWrite(MOTOR_B_IN1, HIGH);
    digitalWrite(MOTOR_B_IN2, LOW);
    analogWrite(MOTOR_B_PWM, (int)(rightSpeed * MAX_SPEED));
  } else if (rightSpeed < 0) {
    // Backward
    digitalWrite(MOTOR_B_IN1, LOW);
    digitalWrite(MOTOR_B_IN2, HIGH);
    analogWrite(MOTOR_B_PWM, (int)(-rightSpeed * MAX_SPEED));
  } else {
    // Stop
    digitalWrite(MOTOR_B_IN1, LOW);
    digitalWrite(MOTOR_B_IN2, LOW);
    analogWrite(MOTOR_B_PWM, 0);
  }
}

// Stop both motors
void stopMotors() {
  digitalWrite(MOTOR_A_IN1, LOW);
  digitalWrite(MOTOR_A_IN2, LOW);
  digitalWrite(MOTOR_B_IN1, LOW);
  digitalWrite(MOTOR_B_IN2, LOW);
  analogWrite(MOTOR_A_PWM, 0);
  analogWrite(MOTOR_B_PWM, 0);
}
