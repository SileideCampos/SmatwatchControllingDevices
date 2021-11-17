#include <WiFiUdp.h>
#include <Espalexa.h>

#define button1 16
#define rele1 2
bool Status1 = 0 ;

const char* ssid = "your-ssid";
const char* senha = "yout-password";
unsigned int localPort = 3333;
char pacote[3];

IPAddress ip(192,168,0,15);
IPAddress gateway(192,168,0,1);
IPAddress subnet(255,255,255,0);

void firstLightChanged(uint8_t brightness);

WiFiUDP conexao;
Espalexa espalexa;

void setup() {
  pinMode(button1,INPUT);
  pinMode(rele1,OUTPUT);
  Serial.begin(9600);
  Serial.println("iniciar conexao");
 
  if (!WiFi.config(ip, gateway, subnet)) {
    Serial.println("Falha ao configurar a rede.");
  }
  
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid,senha);
  while(WiFi.waitForConnectResult() != WL_CONNECTED){
    Serial.println("Problemas ao conectar.");
    delay(2000);
    WiFi.begin(ssid,senha);
  }
  Serial.println(WiFi.localIP());
  conexao.begin(localPort);
  
  espalexa.addDevice("Escritorio", firstLightChanged);
  espalexa.begin();
  
  if (WiFi.status() == WL_CONNECTED){
    Serial.println("Conectado Setup");
  }else{
    Serial.println("Desconectado Setup");
  }
  

}

void loop() {
  
  digitalWrite(rele1,Status1);  
  
  if (pulseIn(button1, HIGH) > 0) {
    Serial.println("button1");
    delay(100);
    Status1 = !Status1;    
  }
  
  int tamanhoPacote = conexao.parsePacket();
  if(tamanhoPacote == 3){
    String recebe;
    recebe = conexao.readString();
    Serial.println(recebe);
    if (recebe == "OON"){
      Status1 = 0;
      conexao.beginPacket(conexao.remoteIP(), conexao.remotePort());
      conexao.print(Status1);
      conexao.endPacket();
      Serial.println("ligou");
    }else if (recebe == "OFF"){
      Status1 = 1;
      conexao.beginPacket(conexao.remoteIP(), conexao.remotePort());
      conexao.print(Status1);
      conexao.endPacket();
      Serial.println("desligou");
    }else if (recebe == "STS"){      
      Serial.println(Status1);
      conexao.beginPacket(conexao.remoteIP(), conexao.remotePort());
      conexao.print(Status1);
      conexao.endPacket();
    }
  }
  
  if (WiFi.status() != WL_CONNECTED){
    Serial.println("Sem acesso a rede. Reconectando...");
    WiFi.reconnect();
    delay(4000); //tentar baixar o tempo
  }else{
    Serial.print("Conectou: ");
    Serial.println(WiFi.localIP());
  }

  espalexa.loop();  
}

void firstLightChanged(uint8_t brightness) {
    Serial.print("Status alterado pela Alexa.");
    if (brightness) {
      Serial.print("ON, brightness ");
      Serial.println(brightness);
      Status1 = 0;
    }
    else  {
      Serial.println("OFF");
      Status1 = 1;
    }
}
