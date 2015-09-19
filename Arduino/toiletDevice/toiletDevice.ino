
#include <SoftwareSerial.h>
SoftwareSerial BT(10, 9);
const byte ledPin = 13;
char val;
bool doorStatus = true;

void setup() {
  pinMode(ledPin, OUTPUT);
  // put your setup code here, to run once:
  BT.begin(9600);
  BT.println("OK");
}

void loop() {
  // put your main code here, to run repeatedly:
  if (BT.available()){
    val = BT.read();
    switch (val){
      case '0':
        digitalWrite(ledPin, 0);
        break;
      case '1':
        digitalWrite(ledPin, 1);
        break;  
      case 'T':
        //傳送訊息回Server
        if (doorStatus == 1) {
           int bytesSent = BT.write("1");
        }else {
          int bytesSent = BT.write("0");
        }
        
        break;      
    }
  }
}
