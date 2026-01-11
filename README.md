# Arduino UNO R4 WiFi + Android BLE Project

This project demonstrates Bluetooth Low Energy (BLE) communication between an Arduino UNO R4 WiFi board and an Android smartphone.

## Project Structure

```
.
├── arduino_ble_project/
│   └── arduino_ble_project.ino    # Arduino sketch
└── android_ble_app/               # Android application
    ├── app/
    │   ├── build.gradle
    │   └── src/
    │       └── main/
    │           ├── AndroidManifest.xml
    │           ├── java/com/example/arduinoble/
    │           │   └── MainActivity.kt
    │           └── res/
    │               ├── layout/
    │               │   └── activity_main.xml
    │               └── values/
    │                   ├── strings.xml
    │                   └── colors.xml
    └── build.gradle
```

## Hardware Requirements

- Arduino UNO R4 WiFi (has built-in BLE support)
- USB cable for Arduino
- Android smartphone with BLE support (Android 6.0+)

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

1. Power on your Arduino UNO R4 WiFi
2. Open Serial Monitor to see BLE status
3. The device will start advertising as "ArduinoR4"

### Step 2: Connect from Android App

1. Launch the "Arduino BLE" app on your Android phone

2. Grant permissions when prompted:
   - Bluetooth permissions (Android 12+)
   - Location permissions (Android 6-11)

3. Tap "Scan for Arduino"
   - The app will scan for BLE devices
   - When "ArduinoR4" is found, it will automatically connect

4. Wait for connection:
   - Status will change to "Connected to Arduino"
   - The "Send Message to Arduino" button will be enabled

### Step 3: Send Message

1. Tap "Send Message to Arduino" button

2. Check Arduino Serial Monitor:
   - You should see a message like:
   ```
   ----------------------------
   Message received: Hello from Android! Time: 1704902400000
   ----------------------------
   ```

3. The Android app log will confirm the message was sent

### Step 4: Disconnect (Optional)

- Tap "Disconnect" to close the BLE connection
- Or simply close the app
- Arduino will return to advertising mode

## How It Works

### Arduino Side

1. **Initialization**
   - Starts BLE and creates a service with UUID `19B10000-E8F2-537E-4F6C-D104768A1214`
   - Creates a characteristic with UUID `19B10001-E8F2-537E-4F6C-D104768A1214`
   - Begins advertising as "ArduinoR4"

2. **Connection**
   - Waits for a BLE central device (Android phone) to connect
   - Maintains connection while central is connected

3. **Message Reception**
   - Monitors the characteristic for writes
   - When a message is received, logs it to Serial port

### Android Side

1. **Permission Handling**
   - Requests necessary Bluetooth and location permissions
   - Handles different permission requirements for Android 6-11 vs 12+

2. **Scanning**
   - Scans for BLE devices advertising as "ArduinoR4"
   - Automatically connects when found

3. **Connection**
   - Connects to the GATT server
   - Discovers services and characteristics

4. **Message Sending**
   - Writes a string message to the characteristic
   - Arduino receives and logs the message

## Customization

### Change Device Name

**Arduino:**
```cpp
BLE.setLocalName("YourCustomName");
```

**Android:**
```kotlin
private val ARDUINO_DEVICE_NAME = "YourCustomName"
```

### Change UUIDs

Generate new UUIDs at: https://www.uuidgenerator.net/

Update both Arduino and Android code with matching UUIDs.

### Change Message Content

**Android (`MainActivity.kt`):**
```kotlin
val message = "Your custom message here"
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

1. **Two-way Communication:** Have Arduino send data back to Android
2. **Sensor Data:** Send sensor readings from Arduino to Android
3. **Multiple Characteristics:** Add more characteristics for different data types
4. **Control LEDs:** Use Android to control LEDs on Arduino
5. **Data Visualization:** Display Arduino sensor data in charts on Android

## License

This project is provided as-is for educational purposes.

## Support

For issues with:
- **Arduino IDE/Board:** Visit https://support.arduino.cc/
- **Android Development:** Visit https://developer.android.com/support
