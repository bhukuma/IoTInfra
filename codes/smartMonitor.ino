#define BAUD_RATE 115200
#include "secrets.h"
#include "EmonLib.h" 
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include "WiFi.h"
#include "DHT.h"
#include <time.h> // Include time library

#define DHTPIN 17     // Digital pin connected to the DHT sensor
#define DHTTYPE DHT11   // DHT 11
#define DO_PIN 13
#define AWS_IOT_PUBLISH_TOPIC   "esp32-pub"
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32-sub"
#define RELAY_CONTROL_TOPIC     "esp32-relay"  // New MQTT topic for relay control
const int analogPin = 33;  // A0 pin of MQ-9 is connected to GPIO34
const int relayPin = 22;
int baselineValue = 900;


#define PIN_ANALOG_IN  32
int digitalPin = 13;
int analogVal = 0;
int adcVal = 0;
int gasIntense;
int fire;
int fireIntense;
float h;
float t;
float vltg;
float curnt;
float pwr;
float enrgycuntilnow;
float costilnow;
float energyin24hrs;
float estmtdcost24hrs;
//double f;


EnergyMonitor emon1;          // Create an instance for voltage sensor
EnergyMonitor emon2;          // Create an instance for current sensor

// Pin configurations
const int voltagePin = 34;    // Pin connected to ZMPT101B (voltage sensor)
const int currentPin = 35;    // Pin connected to SCT-013-030 (current sensor)

// Calibration factors (adjust as needed for your sensors)
const float voltageCalibration = 128.0; // Calibrate according to your sensor
const float currentCalibration = 7.5; // Calibrate according to SCT-013-030

// Variables for calculation
float voltage, current, power;
float cumulativeEnergy = 0;    // Total energy consumed in kWh
float energy24Hours = 0;       // Accumulate energy over 24 hours in kWh
const float costPerkWh = 0.12; // Electricity cost per kWh (adjust according to local rates)

unsigned long previousMillis = 0;
const long interval = 5000;    // Read sensor values every 5 seconds



 
DHT dht(DHTPIN, DHTTYPE);
WiFiClientSecure net = WiFiClientSecure();
PubSubClient client(net);
 
void connectAWS()
{ delay(1000);
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD); 
  Serial.println("Connecting to Wi-Fi");
 
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("");
 Serial.println("WiFi Connected");
 delay(1000);
 
client.setKeepAlive(20);  // Set keep-alive to 20 seconds

  // Configure WiFiClientSecure to use the AWS IoT device credentials
  net.setCACert(AWS_CERT_CA);
  net.setCertificate(AWS_CERT_CRT);
  net.setPrivateKey(AWS_CERT_PRIVATE);
 
  // Connect to the MQTT broker on the AWS endpoint we defined earlier
  client.setServer(AWS_IOT_ENDPOINT, 8883);
 
  // Create a message handler
  client.setCallback(messageHandler);
 
  Serial.println("Connecting to AWS IOT");
 
  while (!client.connect(THINGNAME))
  {
    Serial.print(".");
    delay(300);
  }
 
  if (!client.connected())
  {
    Serial.println("AWS IoT Timeout!");
    return;
  }
 
  // Subscribe to a topic
  client.subscribe(AWS_IOT_SUBSCRIBE_TOPIC);
  client.subscribe(RELAY_CONTROL_TOPIC); 
 
  Serial.println("AWS IoT Connected!");
}

void setup()
{
  Serial.begin(115200);
    // Initialize voltage sensor (emon1)
  emon1.voltage(voltagePin, voltageCalibration, 1.7);  // Pin, calibration, phase shift
  // Initialize current sensor (emon2)
  emon2.current(currentPin, currentCalibration);       // Pin, calibration
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, LOW); // Set relay to off initially
  pinMode(analogPin, INPUT);
  connectAWS();
  dht.begin();
  flame();
  gas();
  
}



void publishMessage()
{
  StaticJsonDocument<500> doc;

  doc["humidity"] = h;
  doc["temperature"] = t;
  doc["fireAlarm"] = fire;
  doc["adcVal"] = fireIntense;
  doc["gasIntense"] = gasIntense;
  doc["Voltage"] = vltg;
  doc["Curent"] = curnt;
  doc["Power"] = pwr;
  doc["enrgytilnowInKWh"] = enrgycuntilnow;
  doc["costTillNow"] = costilnow;
  doc["24hrsEnrgyForcast"] = estmtdcost24hrs;
  char jsonBuffer[512];
  serializeJson(doc, jsonBuffer); // print to client
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
}
 
void messageHandler(char* topic, byte* payload, unsigned int length)
{
  Serial.print("incoming: ");
  Serial.println(topic);
 
  StaticJsonDocument<200> doc;
  deserializeJson(doc, payload);
  const char* message = doc["message"];
  Serial.println(message);

    if (strcmp(topic, RELAY_CONTROL_TOPIC) == 0) {
    const char* relayCommand = doc["relay"];  // Expect a key "relay" in the message

    if (strcmp(relayCommand, "ON") == 0) {
      digitalWrite(relayPin, HIGH);  // Turn relay on
      Serial.println("Relay turned ON");
    } 
    else if (strcmp(relayCommand, "OFF") == 0) {
      digitalWrite(relayPin, LOW);   // Turn relay off
      Serial.println("Relay turned OFF");
    }
  } else {
    const char* message = doc["message"];
    Serial.println(message);
  }
}

void flame()
{
  Serial.begin(115200);
  pinMode(digitalPin, INPUT);
 
  int digitalVal = digitalRead(digitalPin);  //Read digital signal;
  int adcVal = analogRead(PIN_ANALOG_IN);
  int dacVal = map(adcVal, 0, 4095, 0, 255);
  double voltage = adcVal / 4095.0 * 3.3;
  Serial.printf("digitalVal: %d, \t ADC Val: %d, \t DAC Val: %d, \t Voltage: %.2fV\n",digitalVal, adcVal, dacVal, voltage);
  fire = digitalVal;
  fireIntense = adcVal;
}

void temp()
{  
  Serial.begin(115200);
  h = dht.readHumidity();
  t = dht.readTemperature();
   if (isnan(h) || isnan(t) )  // Check if any reads failed and exit early (to try again).
  {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }
  Serial.print(F("Humidity: "));
  Serial.print(h);
  Serial.print(F("%  Temperature: "));
  Serial.print(t);
  Serial.println(F("°C "));

}

void energyMeter() {
  Serial.begin(115200);
  unsigned long currentMillis = millis();
  
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    
    // Read voltage and current
    emon1.calcVI(20, 2000);  // Calculate voltage and current, 20 cycles, 2000 ms timeout
    voltage = emon1.Vrms;    // Extract voltage value
    current = emon2.calcIrms(1480);  // Extract current value

    // Calculate instantaneous power
    power = voltage * current;  // Power = Voltage * Current (Watts)
    
    // Print the values
    Serial.print("Voltage: ");
    Serial.print(voltage);
    Serial.print(" V, Current: ");
    Serial.print(current);
    Serial.print(" A, Power: ");
    Serial.print(power);
    Serial.println(" W");

    // Calculate energy consumed in this interval (in kWh)
    float energyPerSecond = (power / 1000.0) / 3600.0;  // Energy in kWh per second
    cumulativeEnergy += energyPerSecond * (interval / 1000.0);  // Accumulate total energy consumed

    // Estimate energy consumption for the next 24 hours (in kWh)
    energy24Hours += energyPerSecond * (interval / 1000.0);  // Accumulate energy for 24 hours forecast

    // Forecast cost for 24 hours and total cost so far
    float estimatedCost = energy24Hours * costPerkWh;
    float costTillNow = cumulativeEnergy * costPerkWh;
    vltg=voltage;
    curnt=current;
    pwr=power;
    enrgycuntilnow=cumulativeEnergy;
    costilnow=costTillNow;
    energyin24hrs=energy24Hours;
    estmtdcost24hrs=estimatedCost;

    // Display cumulative energy consumption and cost so far
    Serial.print("Energy Consumed Till Now: ");
    Serial.print(cumulativeEnergy);
    Serial.println(" kWh");

    Serial.print("Cost Till Now: $");
    Serial.print(costTillNow);
    Serial.println();

    // Display forecasted energy consumption and cost for 24 hours
    Serial.print("Estimated Energy (24 hours): ");
    Serial.print(energy24Hours);
    Serial.println(" kWh");
    Serial.print("Estimated Cost (24 hours): $");
    Serial.print(estimatedCost);
    Serial.println();
  }
}

void gas() {
  int currentValue = analogRead(analogPin);

  if (currentValue < 100 || currentValue > 4095) {
    Serial.println("Error: Gas Sensor not detected or malfunctioning!");
    delay(1000);
    return;
  }

  int gasLevel = currentValue - baselineValue;
  if (gasLevel < 0) gasLevel = 0;

  Serial.print("Calibrated Sensor Value: ");
  Serial.println(gasLevel);

  gasIntense = gasLevel;
}
 
unsigned long lastSensorReadTime = 0;
const long sensorReadInterval = 15000;  // 15 seconds

void loop()
{
  client.loop();  // Keep MQTT connection alive and process incoming messages

  unsigned long currentMillis = millis();
  
  // Delay sensor readings by 15 seconds without blocking
  if (currentMillis - lastSensorReadTime >= sensorReadInterval) {
    lastSensorReadTime = currentMillis;

    // Run the sensor functions every 15 seconds
    flame();
    temp();
    energyMeter();
    gas();
    
    Serial.print("--------------------------------------------------------------------------------------------------------------------------------\n");
    publishMessage();
  }

  // You can still publish messages at a different rate if needed
   // Optionally move this inside the if statement if you want to publish only after sensor readings
}
