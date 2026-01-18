/*
 * PocketGM ESP32 BLE Controller
 * 
 * Dit programma maakt de ESP32 een BLE peripheral die:
 * - Button presses stuurt naar de Flutter app
 * - Vibratie commando's ontvangt van de Flutter app
 * 
 * Pins:
 * - Button 1: GPIO 16 (INCREMENT)
 * - Button 2: GPIO 17 (CONFIRM)
 * - Motor/Vibrator: GPIO 4
 */

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Pin definities
#define BUTTON_PIN1 16  // Increment button
#define BUTTON_PIN2 17  // Confirm button
#define MOTOR_PIN 4     // Vibration motor

// BLE UUIDs - moeten overeenkomen met Flutter app
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define BUTTON_CHAR_UUID    "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define MOTOR_CHAR_UUID     "beb5483e-36e1-4688-b7f5-ea07361b26a9"

BLEServer* pServer = NULL;
BLECharacteristic* pButtonCharacteristic = NULL;
BLECharacteristic* pMotorCharacteristic = NULL;

bool deviceConnected = false;
bool oldDeviceConnected = false;

// Button state tracking
bool button1State = true;  // HIGH when not pressed (INPUT_PULLUP)
bool button2State = true;
bool button1Debounce = false;
bool button2Debounce = false;
unsigned long button1DebounceTime = 0;
unsigned long button2DebounceTime = 0;
const unsigned long DEBOUNCE_DELAY = 50;

// Motor control
unsigned long motorStopTime = 0;
bool motorRunning = false;

// Callback voor motor characteristic (ontvangen van vibratie commando's)
class MotorCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    uint8_t* data = pCharacteristic->getData();
    size_t len = pCharacteristic->getLength();
    
    if (len >= 2) {
      // Duration in milliseconds (little endian)
      uint16_t duration = data[0] | (data[1] << 8);
      
      if (duration == 0) {
        // Stop motor
        digitalWrite(MOTOR_PIN, LOW);
        motorRunning = false;
      } else {
        // Start motor for specified duration
        digitalWrite(MOTOR_PIN, HIGH);
        motorStopTime = millis() + duration;
        motorRunning = true;
      }
    }
  }
};

// Callback voor BLE server connectie status
class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("Device connected");
    // Korte vibratie om connectie te bevestigen
    digitalWrite(MOTOR_PIN, HIGH);
    delay(100);
    digitalWrite(MOTOR_PIN, LOW);
  }

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("Device disconnected");
  }
};

void setup() {
  Serial.begin(115200);
  delay(1000);  // Wacht even tot Serial klaar is
  Serial.println();
  Serial.println("=====================================");
  Serial.println("PocketGM ESP32 BLE Controller starting...");
  Serial.println("=====================================");

  // Pin setup
  Serial.println("Setting up pins...");
  pinMode(BUTTON_PIN1, INPUT_PULLUP);
  pinMode(BUTTON_PIN2, INPUT_PULLUP);
  pinMode(MOTOR_PIN, OUTPUT);
  digitalWrite(MOTOR_PIN, LOW);
  Serial.println("Pins configured.");

  // Test motor even
  Serial.println("Testing motor...");
  digitalWrite(MOTOR_PIN, HIGH);
  delay(200);
  digitalWrite(MOTOR_PIN, LOW);
  Serial.println("Motor test done.");

  // BLE initialisatie
  Serial.println("Initializing BLE...");
  BLEDevice::init("PocketGM");
  Serial.println("BLE initialized.");
  
  // Maak BLE Server
  Serial.println("Creating BLE server...");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  // Maak BLE Service
  Serial.println("Creating BLE service...");
  BLEService* pService = pServer->createService(SERVICE_UUID);

  // Button Characteristic - voor notificaties naar de app
  Serial.println("Creating characteristics...");
  pButtonCharacteristic = pService->createCharacteristic(
    BUTTON_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_NOTIFY
  );
  // Voeg descriptor toe voor notifications
  pButtonCharacteristic->addDescriptor(new BLE2902());

  // Motor Characteristic - voor ontvangen van vibratie commando's
  pMotorCharacteristic = pService->createCharacteristic(
    MOTOR_CHAR_UUID,
    BLECharacteristic::PROPERTY_WRITE |
    BLECharacteristic::PROPERTY_WRITE_NR
  );
  pMotorCharacteristic->setCallbacks(new MotorCallbacks());

  // Start service
  Serial.println("Starting service...");
  pService->start();

  // Start advertising
  Serial.println("Starting advertising...");
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // Helpt met iPhone connectie issues
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("=====================================");
  Serial.println("BLE advertising started!");
  Serial.println("Device name: PocketGM");
  Serial.println("Waiting for connections...");
  Serial.println("=====================================");
}

void loop() {
  // Motor timeout check
  if (motorRunning && millis() >= motorStopTime) {
    digitalWrite(MOTOR_PIN, LOW);
    motorRunning = false;
  }

  // Button 1 handling met debounce
  bool currentButton1 = digitalRead(BUTTON_PIN1) == LOW;
  if (currentButton1 != button1State) {
    if (!button1Debounce) {
      button1Debounce = true;
      button1DebounceTime = millis();
    } else if (millis() - button1DebounceTime > DEBOUNCE_DELAY) {
      button1State = currentButton1;
      button1Debounce = false;
      
      if (button1State) {
        // Button 1 pressed - always vibrate for feedback
        digitalWrite(MOTOR_PIN, HIGH);
        delay(150);
        digitalWrite(MOTOR_PIN, LOW);
        
        // Send notification if connected
        if (deviceConnected) {
          uint8_t buttonValue = 1;
          pButtonCharacteristic->setValue(&buttonValue, 1);
          pButtonCharacteristic->notify();
          Serial.println("Button 1 pressed - notified");
        } else {
          Serial.println("Button 1 pressed - not connected");
        }
      }
    }
  } else {
    button1Debounce = false;
  }

  // Button 2 handling met debounce
  bool currentButton2 = digitalRead(BUTTON_PIN2) == LOW;
  if (currentButton2 != button2State) {
    if (!button2Debounce) {
      button2Debounce = true;
      button2DebounceTime = millis();
    } else if (millis() - button2DebounceTime > DEBOUNCE_DELAY) {
      button2State = currentButton2;
      button2Debounce = false;
      
      if (button2State) {
        // Button 2 pressed - always vibrate for feedback
        digitalWrite(MOTOR_PIN, HIGH);
        delay(150);
        digitalWrite(MOTOR_PIN, LOW);
        
        // Send notification if connected
        if (deviceConnected) {
          uint8_t buttonValue = 2;
          pButtonCharacteristic->setValue(&buttonValue, 1);
          pButtonCharacteristic->notify();
          Serial.println("Button 2 pressed - notified");
        } else {
          Serial.println("Button 2 pressed - not connected");
        }
      }
    }
  } else {
    button2Debounce = false;
  }

  // Herstart advertising als device disconnect
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);  // Geef de bluetooth stack tijd om klaar te zijn
    pServer->startAdvertising();
    Serial.println("Restarted advertising");
    oldDeviceConnected = deviceConnected;
  }
  
  // Connectie status opslaan
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }

  delay(10);  // Kleine delay voor stabiliteit
}
