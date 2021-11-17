#include <WiFi.h>
#include <WiFiUdp.h>
#include <Espalexa.h>

int button1 = 4, rele1= 0;
bool Status1 = 0 ;

const char* ssid = "your-ssid";
const char* senha = "your-password";
unsigned int localPort = 3333;
char pacote[3];

IPAddress ip(192,168,0,10);
IPAddress gateway(192,168,0,1);
IPAddress subnet(255,255,255,0);

void firstLightChanged(uint8_t brightness);

WiFiUDP conexao;
Espalexa espalexa;

void setup() {
  pinMode(button1, INPUT);
  pinMode(rele1, OUTPUT);
  Serial.begin(115200);
  if (!WiFi.config(ip, gateway, subnet)) {
    Serial.println("Falha ao configurar rede");
  }
 
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, senha);
  while(WiFi.waitForConnectResult() != WL_CONNECTED){
    Serial.println("Problema ao conectar");
    delay(6000);
    WiFi.begin(ssid,senha);
  }
  Serial.println(WiFi.localIP());
  conexao.begin(localPort);
  espalexa.addDevice("Escritorio2", firstLightChanged);
  espalexa.begin();
  Serial.println("conectado"); 
}

void loop() {
  digitalWrite(rele1, Status1);
  
  espalexa.loop();  
  int tamanhoPacote = conexao.parsePacket();
  if(tamanhoPacote == 3){
    conexao.read(pacote,3);
    Serial.println(pacote);
    if (pacote == "OON"){
      Status1 = 1;
    }else if (pacote == "OFF"){
      Status1 = 0;
    }
  }
  
  if(digitalRead(button1) == 1){
    Serial.println("button == 1");
    Status1 = !Status1;
    //digitalWrite(rele1,Status1);
    //delay(200);
  }
  
  while(WiFi.waitForConnectResult() != WL_CONNECTED){
    WiFi.begin(ssid,senha);
    delay(200);
  }
   
}

void firstLightChanged(uint8_t brightness) {
  Serial.print("Device 1 changed to ");
  if (brightness) {
    Serial.print("ON, brightness ");
    Serial.println(brightness);
    Status1 = 0;
  }else{
    Serial.println("OFF");
    Status1 = 1;
  }
}
