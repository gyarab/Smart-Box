#include <ESP8266WiFi.h>  //https://github.com/esp8266/Arduino
#include <ESP8266HTTPClient.h>
#include <DNSServer.h> 
#include <ESP8266WebServer.h>
#include <WiFiManager.h>  //https://github.com/tzapu/WiFiManager

#define GreenLed 4
#define RedLed 14
#define Zamek 15
#define Tlacitko 12
#define Buzzer 5

char falseArray[] = "false";

void setup () {
  
  pinMode(GreenLed, OUTPUT);
  pinMode(RedLed, OUTPUT);
  pinMode(Zamek, OUTPUT);
  pinMode(Tlacitko, INPUT);
  pinMode(Buzzer, OUTPUT);
  digitalWrite(RedLed, HIGH);
  digitalWrite(GreenLed, LOW);

  Serial.begin(115200);
}

void loop() {
  if (digitalRead(Tlacitko) == 0) {
    WiFiManager wifiManager;
    wifiManager.resetSettings();
    wifiManager.setTimeout(150);
    
    if (!wifiManager.startConfigPortal("SmartboxAP")) {
      Serial.println("timeout");
      delay(3000);

      ESP.restart();
      delay(5000);
    }
  }

  
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    // "http://jsonplaceholder.typicode.com/users/1"
    // "http://polar-plateau-63565.herokuapp.com/box/1/locked"
    http.begin("http://polar-plateau-63565.herokuapp.com/box/1/locked");  //request destination
    int httpCode = http.GET(); //send request

    if (httpCode > 0) {
      char * lockStatus;
      const char ch = ' ';
      String httpResponse = http.getString();
      char str_array[httpResponse.length()];
      
      httpResponse.toCharArray(str_array, httpResponse.length());
      lockStatus = strchr(str_array, ch);
      Serial.println(lockStatus + 1);
      if ( strcmp(lockStatus + 1, falseArray) == 0) {
        Serial.println("False detected");
        digitalWrite(RedLed, LOW);
        digitalWrite(Buzzer, HIGH);
        digitalWrite(GreenLed, HIGH);
        digitalWrite(Zamek, HIGH);
        delay(200);
        digitalWrite(Zamek, LOW);
        digitalWrite(Buzzer, LOW);
        delay(10000);
        digitalWrite(GreenLed, LOW);
      }

    }
    http.end();   //Close connection

  }
  delay(3000);    //Send a request every 3 seconds

}
