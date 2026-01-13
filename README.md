# ArloBot - BLE Controlled Differential Drive Robot

A 3D-printable robot controlled via Bluetooth Low Energy (BLE) from an Android smartphone. The robot uses an Arduino UNO R4 WiFi with L298P motor driver shield to control a differential drive system with two DC motors. Features include joystick control, 3D-printable chassis, and wireless operation.

## Assembly Guide

**[Complete Assembly Diagram and Build Instructions](ASSEMBLY_DIAGRAM.md)**

This comprehensive guide includes:
- Visual diagrams showing how all parts fit together
- Complete 3D printed parts list
- Electronic components and wiring diagrams
- Step-by-step assembly instructions
- Pin mappings and hardware specifications

## Project Structure

```
.
├── ASSEMBLY_DIAGRAM.md            # Complete assembly guide and diagrams
├── arduino_ble_project/
│   └── arduino_ble_project.ino    # Arduino sketch for robot control
├── android_ble_app/               # Android application
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml
│   │           ├── java/com/example/arduinoble/
│   │           │   └── MainActivity.kt
│   │           └── res/
│   │               ├── layout/
│   │               │   └── activity_main.xml
│   │               └── values/
│   │                   ├── strings.xml
│   │                   └── colors.xml
│   └── build.gradle
└── 3d_models/                     # 3D printable robot parts
    ├── robot_chassis.scad         # OpenSCAD chassis design
    ├── robot_wheels.scad          # OpenSCAD wheel designs
    ├── bottom_plate.stl           # Main chassis base
    ├── motor_mount.stl            # Motor mounting brackets (print 2x)
    ├── caster_bracket.stl         # Rear caster mount
    ├── top_plate.stl              # Optional upper deck
    ├── wheel_65mm.stl             # Standard wheel (print 2x)
    ├── wheel_65mm_smooth.stl      # Smooth tread variant
    └── wheel_65mm_diamond.stl     # Diamond tread variant
```

## Hardware Requirements

### Electronics
- Arduino UNO R4 WiFi (has built-in BLE support)
- L298P Motor Driver Shield
- DC motors, 37mm diameter (2x)
- Ball caster, 15mm diameter (1x)
- Battery pack (6-12V, check L298P specifications)
- USB cable for Arduino programming
- Android smartphone with BLE support (Android 6.0+)

### 3D Printed Parts
- Bottom plate (1x)
- Motor mount brackets (2x)
- Caster bracket (1x)
- Wheels, 65mm diameter (2x)
- Top plate (1x, optional)

### Fasteners
- M3 screws (various lengths: 6mm, 10mm, 16mm)
- M3 nuts
- M3 standoffs, 30mm length (4x, for top plate)

See [ASSEMBLY_DIAGRAM.md](ASSEMBLY_DIAGRAM.md) for complete specifications and assembly instructions.

## Software Requirements

### Arduino IDE Setup

1. **Install Arduino IDE** (version 2.0 or later)
   - Download from: https://www.arduino.cc/en/software

2. **Install ArduinoBLE Library**
   - Open Arduino IDE
   - Go to `Tools` > `Manage Libraries`
   - Search for "ArduinoBLE"
   - Install the library by Arduino

3. **Select Board**
   - Go to `Tools` > `Board` > `Arduino UNO R4 Boards` > `Arduino UNO R4 WiFi`
   - Select the correct port under `Tools` > `Port`

### Android Studio Setup

1. **Install Android Studio**
   - Download from: https://developer.android.com/studio

2. **Requirements**
   - Android SDK API 23 or higher
   - Kotlin plugin (included by default)

## Installation & Setup

### Arduino Setup

1. Open `arduino_ble_project/arduino_ble_project.ino` in Arduino IDE

2. Verify the code compiles:
   - Click the checkmark icon (Verify)

3. Upload to Arduino:
   - Connect your Arduino UNO R4 WiFi via USB
   - Click the right arrow icon (Upload)

4. Open Serial Monitor:
   - Go to `Tools` > `Serial Monitor`
   - Set baud rate to `9600`
   - You should see: "BLE device is now advertising..."

### Android App Setup

1. Open Android Studio

2. Open the `android_ble_app` project:
   - File > Open > Select `android_ble_app` folder

3. Sync Gradle files:
   - Android Studio should automatically sync
   - If not, click `File` > `Sync Project with Gradle Files`

4. Build the project:
   - Build > Make Project

5. Run on your Android device:
   - Connect your Android phone via USB with USB Debugging enabled
   - OR use an Android emulator (must support BLE)
   - Click the green play button (Run 'app')

## Usage

### Step 1: Start Arduino

1. Power on your Arduino UNO R4 WiFi (or connect battery to robot)
2. Open Serial Monitor to see BLE status
3. The device will start advertising as "ArloBot"

### Step 2: Connect from Android App

1. Launch the "Arduino BLE" app on your Android phone

2. Grant permissions when prompted:
   - Bluetooth permissions (Android 12+)
   - Location permissions (Android 6-11)

3. Tap "Scan for Arduino"
   - The app will scan for BLE devices
   - When "ArloBot" is found, it will automatically connect

4. Wait for connection:
   - Status will change to "Connected to Arduino"
   - The "Send Message to Arduino" button will be enabled

### Step 3: Control Robot

1. Use the joystick on the Android app to control the robot
   - Push up to move forward
   - Push down to move backward
   - Push left/right to turn
   - Diagonal movements combine turning and forward/backward motion

2. Check Arduino Serial Monitor:
   - You should see joystick data like:
   ```
   X: 0.50 Y: 0.75 | L: 1.00 R: 0.25
   ```
   - X/Y are joystick positions (-1.0 to 1.0)
   - L/R are left and right motor speeds

3. The robot will move according to differential drive control

### Step 4: Disconnect (Optional)

- Tap "Disconnect" to close the BLE connection
- Or simply close the app
- Arduino will return to advertising mode

## How It Works

### Arduino Side

1. **Initialization**
   - Initializes motor control pins for L298P shield
   - Starts BLE and creates a service with UUID `19B10000-E8F2-537E-4F6C-D104768A1214`
   - Creates a characteristic with UUID `19B10001-E8F2-537E-4F6C-D104768A1214`
   - Begins advertising as "ArloBot"

2. **Connection**
   - Waits for a BLE central device (Android phone) to connect
   - Maintains connection while central is connected

3. **Robot Control**
   - Monitors the characteristic for joystick data writes
   - Parses X and Y values from "X:0.50,Y:-0.75" format
   - Applies differential drive algorithm: Left=Y+X, Right=Y-X
   - Controls motor speeds and directions via L298P shield
   - Logs joystick and motor values to Serial port

### Android Side

1. **Permission Handling**
   - Requests necessary Bluetooth and location permissions
   - Handles different permission requirements for Android 6-11 vs 12+

2. **Scanning**
   - Scans for BLE devices advertising as "ArloBot"
   - Automatically connects when found

3. **Connection**
   - Connects to the GATT server
   - Discovers services and characteristics

4. **Joystick Control**
   - Displays virtual joystick interface
   - Converts touch input to X/Y coordinates (-1.0 to 1.0)
   - Continuously writes joystick data to the characteristic
   - Arduino receives data and controls robot motors

## Customization

### Change Device Name

**Arduino (`arduino_ble_project.ino`):**
```cpp
BLE.setLocalName("YourCustomName");  // Default: "ArloBot"
```

**Android (`MainActivity.kt`):**
```kotlin
private val ARDUINO_DEVICE_NAME = "YourCustomName"  // Default: "ArloBot"
```

### Change UUIDs

Generate new UUIDs at: https://www.uuidgenerator.net/

Update both Arduino and Android code with matching UUIDs.

### Adjust Motor Speed Limits

**Arduino (`arduino_ble_project.ino`):**
```cpp
#define MAX_SPEED 255  // Change to lower value (e.g., 128) for slower speeds
#define DEADZONE 0.1   // Adjust joystick sensitivity
```

## Troubleshooting

### Arduino Issues

**Problem:** BLE won't start
- **Solution:** Ensure you have the ArduinoBLE library installed
- **Solution:** Check that you selected Arduino UNO R4 WiFi board

**Problem:** Can't upload sketch
- **Solution:** Check USB connection
- **Solution:** Try a different USB cable
- **Solution:** Press the reset button and try again

### Android Issues

**Problem:** Can't find Arduino device
- **Solution:** Ensure Arduino is powered on and advertising
- **Solution:** Grant all requested permissions
- **Solution:** Enable Bluetooth on your phone
- **Solution:** Try scanning again

**Problem:** App crashes on startup
- **Solution:** Check that all permissions are granted
- **Solution:** Ensure your phone supports BLE

**Problem:** Can't send message
- **Solution:** Wait for "Services discovered" in the log
- **Solution:** Disconnect and reconnect

### Connection Issues

**Problem:** Connection drops frequently
- **Solution:** Keep phone close to Arduino (within 10 meters)
- **Solution:** Avoid obstacles between devices
- **Solution:** Check for Bluetooth interference

## Technical Details

### BLE Service Structure

- **Service UUID:** `19B10000-E8F2-537E-4F6C-D104768A1214`
- **Characteristic UUID:** `19B10001-E8F2-537E-4F6C-D104768A1214`
- **Characteristic Properties:** Write
- **Max Message Length:** 100 bytes

### Android Permissions

**Android 12+ (API 31+):**
- `BLUETOOTH_SCAN`
- `BLUETOOTH_CONNECT`

**Android 6-11 (API 23-30):**
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `BLUETOOTH`
- `BLUETOOTH_ADMIN`

## Next Steps

Here are some ideas to extend this project:

1. **Add Sensors:** Install ultrasonic sensors for obstacle detection
2. **Two-way Communication:** Send battery voltage and sensor data back to Android
3. **Line Following:** Add IR sensors and line-following mode
4. **Autonomous Navigation:** Implement obstacle avoidance algorithms
5. **Status Indicators:** Add LEDs to show connection status and battery level
6. **Speed Control:** Add speed presets (slow, medium, fast) in Android app
7. **Data Logging:** Record robot telemetry and movement patterns

## License

This project is provided as-is for educational purposes.

## Support

For issues with:
- **Arduino IDE/Board:** Visit https://support.arduino.cc/
- **Android Development:** Visit https://developer.android.com/support
