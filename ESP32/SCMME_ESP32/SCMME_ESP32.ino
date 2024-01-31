//bibliotecas
#include "max6675.h"
#include <WiFi.h>
#include <IOXhop_FirebaseESP32.h>
#include <ArduinoJson.h>
#include <iostream>
#include <string>

//conexão
#define WIFI_SSID "HOME IE"
#define WIFI_PASSWORD "luangitama"
#define FIREBASE_HOST "https://extruder-app-default-rtdb.firebaseio.com/"
#define FIREBASE_AUTH "ctJ9k963mErx0bQTQEmfAd0lXky51eoafEUi34Hn"

//botões de ligar/desligar
bool motorButton;
bool heaterButton;

//Ponte H L298N
int ponteHPin = 2;

//LED para demonstrar o controle do motor
int maxRPM = 100;
int minPWM = 1;
  
//LED para demonstrar a ativação do resistor
int led1 = 23;
int led2 = 22;
//int led3 = 17;
//int led4 = 16;

//Dados do termostato
float sensorHeater1;
float controlHeater1;
float sensorHeater2;
float controlHeater2;
/*float sensorHeater3;
float controlHeater3;
float sensorHeater4;
float controlHeater4;*/

//Dados do controlador de velocidade
float sensorMotor;
float controlMotor;

int encoderPin = 17;
float rpm;
volatile byte pulses;
long time_old;
int pulse_turn = 20;


//módulos de temperatura
struct Max6675Pins {
  int sckPin;
  int csPin;
  int soPin;
};

Max6675Pins modulo1 = {26, 25, 33};
Max6675Pins modulo2 = {13, 14, 27};
//Max6675Pins modulo3 = {26, 25, 33};
//Max6675Pins modulo4 = {21, 19, 18};

float readTemperature(const Max6675Pins& config){
  MAX6675 sensor(config.sckPin, config.csPin, config.soPin);

  return sensor.readCelsius();
}

bool checkTemperature(float control, float sensor){
  if(sensor >= control+5){
    return false;
  }
  if(sensor <= control-5){
    return true;
  }
}

void controlLED(boolean state, int pin){
  if(state){
    digitalWrite(pin, HIGH);
  } else{
    digitalWrite(pin, LOW);
  }
}

void  countPulses(){pulses++;}

void readRPM(){
  long time_curr = millis();
  if(time_curr -time_old >= 100){
    detachInterrupt(digitalPinToInterrupt(encoderPin));
    int dif = time_curr -time_old;
    rpm = (60*100/pulse_turn)*pulses;///(dif)*pulses;
    rpm /= dif;
    time_old = time_curr;
    pulses = 0;
    attachInterrupt(digitalPinToInterrupt(encoderPin), countPulses, FALLING);
  }
}


void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print("//////    ");
    delay(300);
  }
  delay(100);
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  motorButton = false;
  heaterButton = false;

  rpm=0;
  time_old=0;
  pulses=0;

  pinMode(encoderPin, INPUT);
  attachInterrupt(digitalPinToInterrupt(encoderPin), countPulses, FALLING);

  pinMode(led1, OUTPUT);
  pinMode(led2, OUTPUT);
  /*pinMode(led3, OUTPUT);
  pinMode(led4, OUTPUT);*/

  pinMode(ponteHPin, OUTPUT);
  analogWrite(ponteHPin, 0);
}

void loop() {

  /*motorButton = Firebase.getBool("velocity/button");

  if(motorButton){
    digitalWrite(in, HIGH);
  }*/
  
  readRPM();

  Firebase.setFloat("velocity/controller/motor/sensor", rpm);

  sensorHeater1 = readTemperature(modulo1);
  sensorHeater2 = readTemperature(modulo2);


  Serial.print("rpm: ");
  Serial.println(rpm);
  Serial.print("c: ");
  Serial.println(pulses);
  
  //sensorHeater3 = readTemperature(modulo3);
  //sensorHeater4 = readTemperature(modulo4);

  
  Firebase.setFloat("temperature/controller/heater01/sensor", sensorHeater1);
  controlHeater1 = Firebase.getFloat("temperature/controller/heater01/control");
  controlLED(checkTemperature(controlHeater1, sensorHeater1), led1);
  
  Firebase.setFloat("temperature/controller/heater02/sensor", sensorHeater2);
  controlHeater2 = Firebase.getFloat("temperature/controller/heater02/control");
  controlLED(checkTemperature(controlHeater2, sensorHeater2), led2);

  /*Firebase.setFloat("temperature/controller/heater03/sensor", sensorHeater3);
  controlHeater3 = Firebase.getFloat("temperature/controller/heater03/control");
  controlLED(checkTemperature(controlHeater3, sensorHeater3), led3);

  Firebase.setFloat("temperature/controller/heater04/sensor", sensorHeater4);
  controlHeater4 = Firebase.getFloat("temperature/controller/heater04/control");
  controlLED(checkTemperature(controlHeater4, sensorHeater4), led4);*/

  controlMotor = Firebase.getFloat("velocity/controller/motor/control");

  int pwm_PH = minPWM;
  pwm_PH += (controlMotor/maxRPM)*(255-minPWM);
  analogWrite(ponteHPin, pwm_PH);

  
}
