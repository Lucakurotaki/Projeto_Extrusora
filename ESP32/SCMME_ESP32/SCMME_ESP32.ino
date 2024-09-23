//bibliotecas
#include "max6675.h"
#include <WiFi.h>
#include <IOXhop_FirebaseESP32.h>
#include <ArduinoJson.h>
#include <iostream>
#include <string>
#include <Ticker.h>
Ticker timer;

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

//valores para regular o controle do motor
int maxRPM = 240;
int minPWM = 1;
  
//LED para demonstrar a ativação do resistor
int led1 = 23;
int led2 = 22;
int led3 = 17;
int led4 = 16;

//Estado do aquecedor
bool overTemp1 = true;
bool overTemp2 = true;
bool overTemp3 = true;
bool overTemp4 = true;

//Dados do termostato
float sensorHeater1;
float controlHeater1;
float sensorHeater2;
float controlHeater2;
float sensorHeater3;
float controlHeater3;
float sensorHeater4;
float controlHeater4;
float antSensorHeater1;
float antSensorHeater2;
float antSensorHeater3;
float antSensorHeater4;

//Dados do controlador de velocidade
int sensorMotor;
int controlMotor;

int encoderPin = 4;
float rpm = 0;
float antRpm;
unsigned int pulses = 0;
int pulse_turn = 20;


MAX6675 sensorTemp1(32, 33, 36);
MAX6675 sensorTemp2(25, 26, 39);
MAX6675 sensorTemp3(27, 14, 34);
MAX6675 sensorTemp4(19, 18, 35);

bool checkTemperature(float control, float sensor, bool tempState){
  if(sensor >= control+5){  
    return false;
  }else if (sensor < control+5 && sensor > control-5 && tempState == false){
    return false;
  }else{
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
  timer.detach(); //para o timer
  float pulsesFloat = (float)(unsigned long long int) pulses;
  antRpm = rpm;
  rpm = (pulsesFloat/ pulse_turn) * 60;
  pulses = 0; //reinicia a contagem dos pulsos
   timer.attach_ms(1000, readRPM);
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

  pinMode(encoderPin,INPUT);
  attachInterrupt(digitalPinToInterrupt(encoderPin), countPulses, RISING); //incrementa o contador de pulsos sempre que o pino for ativado
  timer.attach_ms(1000, readRPM);// habilita o timer a cada 1000 ms

  
  pinMode(led1, OUTPUT);
  pinMode(led2, OUTPUT);
  pinMode(led3, OUTPUT);
  pinMode(led4, OUTPUT);

  pinMode(ponteHPin, OUTPUT);

  
  xTaskCreatePinnedToCore(loop2, "loop2", 8192, NULL, 1, NULL, 0);//Cria a tarefa "loop2()" com prioridade 1, atribuída ao core 0
  delay(1);
}

unsigned long currentMillis;
unsigned long lastUpdateMillis;

void loop() {

  while(true){

Serial.println(rpm);
      
  ///**
    if(motorButton){//verifica se o motor consta como ligado no aplicativo
      int pwm_PH = controlMotor;
  //    Serial.print(pwm_PH);
      analogWrite(ponteHPin, pwm_PH);//regula a velocidade do motor
    }else{
      analogWrite(ponteHPin, 0);//desliga o motor
    }
  
  
  
    motorButton = Firebase.getBool("velocity/button"); delay(50);
  
    heaterButton = Firebase.getBool("temperature/button"); delay(50);
  
  
    if(heaterButton){

      antSensorHeater1 = sensorHeater1;
      antSensorHeater2 = sensorHeater2;
      antSensorHeater3 = sensorHeater3;
      antSensorHeater4 = sensorHeater4;

      
      //lê as temperaturas dos sensores
      sensorHeater1 = sensorTemp1.readCelsius();
      sensorHeater2 = sensorTemp2.readCelsius();
      sensorHeater3 = sensorTemp3.readCelsius();
      sensorHeater4 = sensorTemp4.readCelsius();
    
    
    
      bool tempState1 = checkTemperature(controlHeater1, sensorHeater1, overTemp1);
      controlLED(tempState1, led1);//regula a temperatura do aquecedor, nesse caso representado pelo LED
      overTemp1 = tempState1;
      
      bool tempState2 = checkTemperature(controlHeater2, sensorHeater2, overTemp2);
      controlLED(tempState2, led2);//regula a temperatura do aquecedor, nesse caso representado pelo LED
      overTemp2 = tempState2;
    
      bool tempState3 = checkTemperature(controlHeater3, sensorHeater3, overTemp3);
      controlLED(tempState3, led3);//regula a temperatura do aquecedor, nesse caso representado pelo LED
      overTemp3 = tempState3;
    
      bool tempState4 = checkTemperature(controlHeater4, sensorHeater4, overTemp4);
      controlLED(tempState4, led4);//regula a temperatura do aquecedor, nesse caso representado pelo LED
      overTemp4 = tempState4;
    //*/
    }
    else{
      controlLED(false, led1);
      controlLED(false, led2);
      controlLED(false, led3);
      controlLED(false, led4);
    }
  
    Serial.println("Um ciclo");
    
    delay(500);  
    
  }
}

void loop2(void*z){
  
  while(true){    

    if(motorButton){
      //obtem a velocidade definida pelo aplicativo
      controlMotor = Firebase.getFloat("velocity/controller/motor/control");
//      Serial.println("envio vel"); delay(50);
      if(antRpm != rpm) Firebase.setFloat("velocity/controller/motor/sensor", rpm);//envia a velocidade do sensor ao aplicativo
    }
    
    if(heaterButton){
      
      
      if(antSensorHeater1 != sensorHeater1) Firebase.setFloat("temperature/controller/heater01/sensor", sensorHeater1);//envia a temperatura do sensor ao aplicativo
      controlHeater1 = Firebase.getFloat("temperature/controller/heater01/control");//obtém a temperatura definida pelo aplicativo
      if(antSensorHeater2 != sensorHeater2) Firebase.setFloat("temperature/controller/heater02/sensor", sensorHeater2);
      controlHeater2 = Firebase.getFloat("temperature/controller/heater02/control");
      if(antSensorHeater3 != sensorHeater3) Firebase.setFloat("temperature/controller/heater03/sensor", sensorHeater3);
      controlHeater3 = Firebase.getFloat("temperature/controller/heater03/control");
      if(antSensorHeater4 != sensorHeater4) Firebase.setFloat("temperature/controller/heater04/sensor", sensorHeater4);
      controlHeater4 = Firebase.getFloat("temperature/controller/heater04/control");
    }
    
//    Serial.println("Um ciclo do Update");
    
  
    delay(500);  
  
  }

}
