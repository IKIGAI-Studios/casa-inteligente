#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <ESP32Servo.h>
#include <DHT11.h>

DHT11 dht11(4); // Pin del DHT11 conectado al 4

BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;

#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define LED_CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define DOOR_CHARACTERISTIC_UUID "a1b2c3d4-5678-90ab-cdef-1234567890ab"
#define TEMPERATURE_CHARACTERISTIC_UUID "abcdef12-3456-7890-abcd-ef1234567890"

int LED_PIN = 22;
Servo miServo;
const int SERVO_PIN = 18;

class MyServerCallbacks : public BLEServerCallbacks
{
  void onConnect(BLEServer *pServer)
  {
    deviceConnected = true;
    BLEDevice::startAdvertising();
  };

  void onDisconnect(BLEServer *pServer)
  {
    deviceConnected = false;
    digitalWrite(LED_PIN, HIGH);
  }
};

class MyLEDCallbacks : public BLECharacteristicCallbacks
{
  void onWrite(BLECharacteristic *pCharacteristic)
  {
    String value = pCharacteristic->getValue().c_str();

    if (value.length() > 0)
    {
      Serial.print("Received value for LED: ");
      Serial.println(value);

      if (value == "on")
      {
        digitalWrite(LED_PIN, LOW); // Enciende el LED
        Serial.println("LED Encendido");
      }
      else if (value == "off")
      {
        digitalWrite(LED_PIN, HIGH); // Apaga el LED
        Serial.println("LED Apagado");
      }
      else
      {
        Serial.println("Received invalid value for LED");
      }
      Serial.println("**********");
    }
  }
};

class MyDoorCallbacks : public BLECharacteristicCallbacks
{
  void onWrite(BLECharacteristic *pCharacteristic)
  {
    String value = pCharacteristic->getValue().c_str();

    if (value.length() > 0)
    {
      Serial.print("Received value for Door: ");
      Serial.println(value);

      if (value == "open")
      {
        miServo.write(90); // Mueve el servo a 90 grados (abrir)
        Serial.println("Puerta Abierta");
      }
      else if (value == "close")
      {
        miServo.write(0); // Mueve el servo a 0 grados (cerrar)
        Serial.println("Puerta Cerrada");
      }
      else
      {
        Serial.println("Received invalid value for Door");
      }
      Serial.println("**********");
    }
  }
};

void setup()
{
  Serial.begin(115200);

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, HIGH);

  miServo.attach(SERVO_PIN);

  // Create the BLE Device
  BLEDevice::init("ESP32 Controller");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic for LED
  BLECharacteristic *ledCharacteristic = pService->createCharacteristic(
      LED_CHARACTERISTIC_UUID,
      BLECharacteristic::PROPERTY_READ |
          BLECharacteristic::PROPERTY_WRITE |
          BLECharacteristic::PROPERTY_NOTIFY |
          BLECharacteristic::PROPERTY_INDICATE);
  ledCharacteristic->setCallbacks(new MyLEDCallbacks());
  ledCharacteristic->setValue("Control LED");
  ledCharacteristic->addDescriptor(new BLE2902());

  // Create a BLE Characteristic for Door
  BLECharacteristic *doorCharacteristic = pService->createCharacteristic(
      DOOR_CHARACTERISTIC_UUID,
      BLECharacteristic::PROPERTY_READ |
          BLECharacteristic::PROPERTY_WRITE |
          BLECharacteristic::PROPERTY_NOTIFY |
          BLECharacteristic::PROPERTY_INDICATE);
  doorCharacteristic->setCallbacks(new MyDoorCallbacks());
  doorCharacteristic->setValue("Control Door");
  doorCharacteristic->addDescriptor(new BLE2902());

  // Create a BLE Characteristic for Temperature
  BLECharacteristic *temperatureCharacteristic = pService->createCharacteristic(
      TEMPERATURE_CHARACTERISTIC_UUID,
      BLECharacteristic::PROPERTY_READ |
          BLECharacteristic::PROPERTY_NOTIFY);
  temperatureCharacteristic->addDescriptor(new BLE2902());

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0); // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println("Waiting a client connection to notify...");
}

void loop()
{
  if (!deviceConnected && oldDeviceConnected)
  {
    delay(500);                  // give the bluetooth stack the chance to get things ready
    pServer->startAdvertising(); // restart advertising
    Serial.println("start advertising");
    oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected)
  {
    oldDeviceConnected = deviceConnected;
  }

  if (deviceConnected)
  {
    float temperature = dht11.readTemperature();
    if (temperature != DHT11::ERROR_CHECKSUM && temperature != DHT11::ERROR_TIMEOUT)
    {
      if (isnan(temperature))
      {
        Serial.println("Failed to read from DHT sensor!");
        return;
      }
      String tempString = String(temperature);
      pCharacteristic->setValue(tempString.c_str());
      pCharacteristic->notify();
      Serial.print("Temperature: ");
      Serial.println(tempString);
    }
    else
    {
      // Print error message based on the error code.
      Serial.println(DHT11::getErrorString(temperature));
    }
    delay(2000); // Update every 2 seconds
  }
}
