
#include <SoftwareSerial.h>
SoftwareSerial BT(10, 9);
const byte ledPin = 13;
const byte doorStatusPin = 2;
char val;

static int prevDoorStatus = 0;

void setup() {
  pinMode(ledPin, OUTPUT);
  pinMode(doorStatusPin, INPUT);
  // put your setup code here, to run once:
  BT.begin(9600);
}

void loop() {
  
  int doorStatus = 0;
  
  //告知這一輪是否已經report過了
  bool isReported = false;
  
  doorStatus = digitalRead(doorStatusPin);
  
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
        reportToServer(doorStatus);
        isReported = true;
        break;      
    }
  }
  
  if (isReported == false) {
    if (prevDoorStatus != doorStatus) {
       reportToServer(doorStatus);
    }
  }
  
  prevDoorStatus = doorStatus;
   
}

bool reportToServer(int status) {
  //傳送訊息回Server
  if (status == HIGH) {
    int bytesSent = BT.write("1");
  }else {
    int bytesSent = BT.write("0");
  }
}
