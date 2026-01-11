/*
  Arduino UNO R4 WiFi BLE Joystick Receiver

  This sketch sets up the Arduino in BLE pairing mode and waits for
  a connection from an Android app. When joystick position data is
  received via BLE, it prints the position to the Serial port.

  Required Library: ArduinoBLE (install via Library Manager)
*/

#include <ArduinoBLE.h>

// BLE Service and Characteristic UUIDs
// You can generate your own UUIDs at https://www.uuidgenerator.net/
#define SERVICE_UUID        "19B10000-E8F2-537E-4F6C-D104768A1214"
#define CHARACTERISTIC_UUID "19B10001-E8F2-537E-4F6C-D104768A1214"

// BLE Service
BLEService messageService(SERVICE_UUID);

// BLE Characteristic - allows write from central device
BLEStringCharacteristic messageCharacteristic(CHARACTERISTIC_UUID, BLEWrite, 100);

void setup() {
  // Initialize serial communication
  Serial.begin(9600);
  while (!Serial);  // Wait for serial port to connect

  Serial.println("Arduino UNO R4 WiFi - BLE Joystick Receiver");
  Serial.println("============================================");

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
        String joystickPosition = messageCharacteristic.value();

        // Print the joystick position to serial
        Serial.print("Joystick: ");
        Serial.println(joystickPosition);
      }
    }

    // When the central device disconnects
    Serial.print("Disconnected from central device: ");
    Serial.println(central.address());
    Serial.println("Waiting for new connections...");
    Serial.println();
  }
}
