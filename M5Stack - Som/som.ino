#include <WiFi.h>
#include <WiFiUdp.h>

const char* ssid = "STARK 2.4G";
const char* senha = "01550123";
char qrCode[150];
unsigned int localPort = 8888;
int modo = 2;
int pp = 5;
int vol = 16;
int vol2 = 17;
char pacote[4];

IPAddress ip(192,168,0,119);        
IPAddress gateway(192,168,0,1);  
IPAddress subnet(255,255,255,0);

WiFiUDP conexao;

void setup() {
  Serial.begin(115200);
  pinMode(25, INPUT);
  digitalWrite(25, LOW);           
  pinMode(modo, OUTPUT);
  digitalWrite(modo, HIGH);
  pinMode(pp, OUTPUT);
  digitalWrite(pp, HIGH);
  pinMode(vol, OUTPUT);
  digitalWrite(vol, HIGH);
  pinMode(vol2, OUTPUT);
  digitalWrite(vol2, HIGH);
  //M5.Lcd.qrcode("SEU CODIGO GERADO NO DELPHI", 40, 1, 500, 3);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid,senha);
    
  if (!WiFi.config(ip, gateway, subnet)) {
    Serial.println("Falha ao configurar STA");
  }
  
  while(WiFi.waitForConnectResult() != WL_CONNECTED){
    Serial.println("Problemas ao conectar!");    
    WiFi.begin(ssid,senha);
    delay(2000);
  }
  Serial.println("Conectado!");
  conexao.begin(localPort);
  
}

void loop() {
  //M5.update();
  
  int tamanhoPacote = conexao.parsePacket();
  if(tamanhoPacote > 0){
    conexao.read(pacote, 4);
    Serial.print(pacote);
    if (pacote[0] == '1'){
      digitalWrite(modo, LOW);
      delay(800);
      digitalWrite(modo, HIGH);
    }else if (pacote[0] == '2'){ 
      digitalWrite(vol, LOW);
      delay(1500);
      digitalWrite(vol, HIGH);
    }else if (pacote[0] == '3'){
      digitalWrite(vol2, LOW);
      delay(1500);
      digitalWrite(vol2, HIGH);
    }else if (pacote[0] == '4'){
      digitalWrite(pp, LOW);
      delay(1500);
      digitalWrite(pp, HIGH);
    }else if (pacote[0] == '5'){ //passar musica +
      digitalWrite(vol, LOW);
      delay(100);
      digitalWrite(vol, HIGH);
    }else if (pacote[0] == '6'){ //passar musica -
      digitalWrite(vol2, LOW);
      delay(100);
      digitalWrite(vol2, HIGH);
    }else if (pacote[0] == '7'){
      digitalWrite(modo, LOW);
      delay(1500);
      digitalWrite(modo, HIGH);
    }
  }
  
  conexao.flush();  
}
