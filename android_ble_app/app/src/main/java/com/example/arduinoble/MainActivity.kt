package com.example.arduinoble

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : AppCompatActivity() {

    // UI Elements
    private lateinit var statusText: TextView
    private lateinit var scanButton: Button
    private lateinit var joystickView: JoystickView
    private lateinit var disconnectButton: Button
    private lateinit var logText: TextView

    // Bluetooth
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothLeScanner: BluetoothLeScanner? = null
    private var bluetoothGatt: BluetoothGatt? = null
    private var messageCharacteristic: BluetoothGattCharacteristic? = null

    // Scanning
    private var isScanning = false
    private val handler = Handler(Looper.getMainLooper())
    private val SCAN_PERIOD: Long = 10000 // 10 seconds

    // Arduino device
    private val ARDUINO_DEVICE_NAME = "ArloBot"

    // BLE UUIDs (must match Arduino sketch)
    private val SERVICE_UUID = UUID.fromString("19B10000-E8F2-537E-4F6C-D104768A1214")
    private val CHARACTERISTIC_UUID = UUID.fromString("19B10001-E8F2-537E-4F6C-D104768A1214")

    // Permission request code
    private val PERMISSION_REQUEST_CODE = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize UI elements
        statusText = findViewById(R.id.statusText)
        scanButton = findViewById(R.id.scanButton)
        joystickView = findViewById(R.id.joystickView)
        disconnectButton = findViewById(R.id.disconnectButton)
        logText = findViewById(R.id.logText)

        // Initialize Bluetooth
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter
        bluetoothLeScanner = bluetoothAdapter?.bluetoothLeScanner

        // Check if BLE is supported
        if (bluetoothAdapter == null) {
            Toast.makeText(this, "Bluetooth not supported on this device", Toast.LENGTH_LONG).show()
            finish()
            return
        }

        // Set up button listeners
        scanButton.setOnClickListener {
            if (checkPermissions()) {
                startScan()
            } else {
                requestPermissions()
            }
        }

        // Set up joystick listener
        joystickView.setOnJoystickMoveListener(object : JoystickView.OnJoystickMoveListener {
            override fun onJoystickMove(x: Float, y: Float) {
                sendJoystickPosition(x, y)
            }
        })

        disconnectButton.setOnClickListener {
            disconnectFromDevice()
        }

        addLog("App started. Click 'Scan for Arduino' to begin.")
    }

    private fun checkPermissions(): Boolean {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT
            )
        } else {
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
        }

        return permissions.all {
            ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestPermissions() {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT
            )
        } else {
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
        }

        ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                addLog("Permissions granted")
                startScan()
            } else {
                addLog("Permissions denied. Cannot scan for BLE devices.")
                Toast.makeText(this, "BLE permissions are required", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun startScan() {
        if (isScanning) {
            addLog("Already scanning...")
            return
        }

        if (!checkPermissions()) {
            requestPermissions()
            return
        }

        addLog("Starting BLE scan...")
        updateStatus(getString(R.string.status_scanning))

        isScanning = true
        scanButton.isEnabled = false

        // Stop scanning after SCAN_PERIOD
        handler.postDelayed({
            stopScan()
        }, SCAN_PERIOD)

        try {
            bluetoothLeScanner?.startScan(scanCallback)
        } catch (e: SecurityException) {
            addLog("Error: Permission denied")
            isScanning = false
            scanButton.isEnabled = true
        }
    }

    private fun stopScan() {
        if (!isScanning) return

        isScanning = false
        scanButton.isEnabled = true

        try {
            bluetoothLeScanner?.stopScan(scanCallback)
            addLog("Scan stopped")

            if (bluetoothGatt == null) {
                updateStatus(getString(R.string.status_idle))
            }
        } catch (e: SecurityException) {
            addLog("Error stopping scan")
        }
    }

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            super.onScanResult(callbackType, result)

            try {
                val deviceName = result.device.name
                if (deviceName == ARDUINO_DEVICE_NAME) {
                    addLog("Found Arduino device: $deviceName")
                    stopScan()
                    connectToDevice(result.device)
                }
            } catch (e: SecurityException) {
                addLog("Error: Permission denied while scanning")
            }
        }

        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
            addLog("Scan failed with error code: $errorCode")
            isScanning = false
            scanButton.isEnabled = true
            updateStatus(getString(R.string.status_idle))
        }
    }

    private fun connectToDevice(device: BluetoothDevice) {
        addLog("Connecting to ${device.address}...")
        updateStatus(getString(R.string.status_connecting))

        try {
            bluetoothGatt = device.connectGatt(this, false, gattCallback)
        } catch (e: SecurityException) {
            addLog("Error: Permission denied while connecting")
        }
    }

    private val gattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> {
                    runOnUiThread {
                        addLog("Connected to GATT server")
                        updateStatus(getString(R.string.status_connected))
                        joystickView.isEnabled = true
                        disconnectButton.isEnabled = true
                    }

                    try {
                        // Discover services
                        handler.postDelayed({
                            try {
                                gatt.discoverServices()
                            } catch (e: SecurityException) {
                                runOnUiThread {
                                    addLog("Error: Permission denied")
                                }
                            }
                        }, 600)
                    } catch (e: SecurityException) {
                        runOnUiThread {
                            addLog("Error: Permission denied")
                        }
                    }
                }
                BluetoothProfile.STATE_DISCONNECTED -> {
                    runOnUiThread {
                        addLog("Disconnected from GATT server")
                        updateStatus(getString(R.string.status_disconnected))
                        joystickView.isEnabled = false
                        disconnectButton.isEnabled = false
                        scanButton.isEnabled = true
                    }
                    bluetoothGatt = null
                    messageCharacteristic = null
                }
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                val service = gatt.getService(SERVICE_UUID)
                if (service != null) {
                    messageCharacteristic = service.getCharacteristic(CHARACTERISTIC_UUID)
                    runOnUiThread {
                        addLog("Services discovered. Ready to send messages!")
                    }
                } else {
                    runOnUiThread {
                        addLog("Error: Service not found")
                    }
                }
            } else {
                runOnUiThread {
                    addLog("Service discovery failed with status: $status")
                }
            }
        }
    }

    private fun sendJoystickPosition(x: Float, y: Float) {
        val characteristic = messageCharacteristic
        val gatt = bluetoothGatt

        if (characteristic == null || gatt == null) {
            return
        }

        // Format: "X:0.50,Y:-0.75"
        val message = String.format("X:%.2f,Y:%.2f", x, y)

        try {
            characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            characteristic.value = message.toByteArray(Charsets.UTF_8)

            gatt.writeCharacteristic(characteristic)
        } catch (e: SecurityException) {
            addLog("Error: Permission denied")
        } catch (e: Exception) {
            addLog("Error sending joystick position: ${e.message}")
        }
    }

    private fun disconnectFromDevice() {
        try {
            bluetoothGatt?.disconnect()
            bluetoothGatt?.close()
            bluetoothGatt = null
            messageCharacteristic = null
            addLog("Disconnecting...")
        } catch (e: SecurityException) {
            addLog("Error: Permission denied")
        }
    }

    private fun updateStatus(status: String) {
        runOnUiThread {
            statusText.text = status
        }
    }

    private fun addLog(message: String) {
        runOnUiThread {
            val timestamp = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
            val currentLog = logText.text.toString()
            logText.text = "$currentLog\n[$timestamp] $message"

            // Auto-scroll to bottom
            val scrollAmount = logText.layout?.getLineTop(logText.lineCount) ?: 0
            if (scrollAmount > logText.height) {
                logText.scrollTo(0, scrollAmount - logText.height)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopScan()
        disconnectFromDevice()
    }
}
