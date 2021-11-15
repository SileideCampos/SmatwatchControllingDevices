/*******************************************************************

   A Telegram bot for taking a photo with an ESP32Cam
   Using "UniversalTelegramBot" Library on Arduino IDE
   
*******************************************************************/
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <UniversalTelegramBot.h>
#include "esp_camera.h"
#include <ArduinoJson.h>
#include "camera_pins.h"
#include "camera_code.h"
#include <WiFiUdp.h>

//#define CAMERA_MODEL_WROVER_KIT
//#define CAMERA_MODEL_ESP_EYE
//#define CAMERA_MODEL_M5STACK_PSRAM
//#define CAMERA_MODEL_M5STACK_WIDE
#define CAMERA_MODEL_AI_THINKER

// Wifi network station credentials
#define WIFI_SSID "YOUR-SSID"
#define WIFI_PASSWORD "YOUR-PASSWORD"
// Telegram BOT Token (Get from Botfather)
//FORMAT TOKEN: "0000000000:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
#define BOT_TOKEN "YOUR TOKEN"
String usuario = "YOUR-NUMBER-USER";

#define FLASH_LED_PIN 4
const unsigned long BOT_MTBS = 1000; 
unsigned long bot_lasttime; 
WiFiClientSecure secured_client;
UniversalTelegramBot bot(BOT_TOKEN, secured_client);
WiFiUDP conexao;
unsigned int localPort = 8888;
char pacote[4];
bool flashState = LOW;
camera_fb_t *fb = NULL;
bool isMoreDataAvailable();
byte *getNextBuffer();
int getNextBufferLen();
bool dataAvailable = false;

void handleNewMessages(int numNewMessages)
{
  Serial.println("handleNewMessages");
  Serial.println(String(numNewMessages));

  for (int i = 0; i < numNewMessages; i++)
  {
    String chat_id = String(bot.messages[i].chat_id);
    String text = bot.messages[i].text;
    Serial.println(chat_id);
      
    String from_name = bot.messages[i].from_name;
    if (from_name == "")
      from_name = "Guest";

    if (text == "/flash")
    {
      flashState = !flashState;
      digitalWrite(FLASH_LED_PIN, flashState);
    }

    if (text == "/photo")
    {
      fb = NULL;
      // Take Picture with Camera
      fb = esp_camera_fb_get();
      if (!fb)
      {
        Serial.println("Camera capture failed");
        bot.sendMessage(chat_id, "Camera capture failed", "");
        return;
      }
      dataAvailable = true;
      Serial.println("Sending");
      bot.sendPhotoByBinary(chat_id, "image/jpeg", fb->len,
                            isMoreDataAvailable, nullptr,
                            getNextBuffer, getNextBufferLen);

      Serial.println("done!");

      esp_camera_fb_return(fb);
    }

    if (text == "/start")
    {
      String welcome = "Welcome to the ESP32Cam Telegram bot.\n\n";
      welcome += "/photo : will take a photo\n";
      welcome += "/flash : toggle flash LED (VERY BRIGHT!)\n";
      bot.sendMessage(chat_id, welcome, "Markdown");
    }
  }
}

bool isMoreDataAvailable()
{
  if (dataAvailable)
  {
    dataAvailable = false;
    return true;
  }
  else
  {
    return false;
  }
}

byte *getNextBuffer()
{
  if (fb)
  {
    return fb->buf;
  }
  else
  {
    return nullptr;
  }
}

int getNextBufferLen()
{
  if (fb)
  {
    return fb->len;
  }
  else
  {
    return 0;
  }
}

void setup()
{
  Serial.begin(115200);
  Serial.println();
  
  pinMode(FLASH_LED_PIN, OUTPUT);
  digitalWrite(FLASH_LED_PIN, flashState); //defaults to low

  if (!setupCamera())
  {
    Serial.println("Camera Setup Failed!");
    while (true)
    {
      delay(100);
    }
  }

  // attempt to connect to Wifi network:
  Serial.print("Connecting to Wifi SSID ");
  Serial.print(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  secured_client.setCACert(TELEGRAM_CERTIFICATE_ROOT); // Add root certificate for api.telegram.org
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(500);
  }
  Serial.print("\nWiFi connected. IP address: ");
  Serial.println(WiFi.localIP());

  Serial.print("Retrieving time: ");
  configTime(0, 0, "pool.ntp.org"); // get UTC time via NTP
  time_t now = time(nullptr);
  while (now < 24 * 3600)
  {
    Serial.print(".");
    delay(100);
    now = time(nullptr);
  }
  Serial.println(now);

  // Make the bot wait for a new message for up to 60seconds
  bot.longPoll = 60;

  conexao.begin(localPort);
  v = 1;
}

void loop()
{
  if (millis() - bot_lasttime > BOT_MTBS) {
    int numNewMessages = bot.getUpdates(bot.last_message_received + 1);

    while (numNewMessages) {
      Serial.println("got response");
      handleNewMessages(numNewMessages);
      numNewMessages = bot.getUpdates(bot.last_message_received + 1);
    }

    bot_lasttime = millis();
  }

  int tamanhoPacote = conexao.parsePacket();    
  if (tamanhoPacote>0){
    conexao.read(pacote, 4);
    Serial.println(pacote);
    if (pacote[0] == '1'){   
      // Turn Flash ON
      digitalWrite(FLASH_LED_PIN, HIGH);
      
      fb = NULL;
      // Take Picture with Camera
      fb = esp_camera_fb_get();
      if (!fb){
        // Send Error to ChatBot telegram
        Serial.println("Camera capture failed");
        bot.sendMessage(usuario, "Camera capture failed", "");
        return;
      }
      dataAvailable = true;
      Serial.println("Sending..");      
      digitalWrite(FLASH_LED_PIN, LOW);
      // Send Picture to ChatBot telegram
      bot.sendPhotoByBinary(usuario, "image/jpeg", fb->len,
                            isMoreDataAvailable, nullptr,
                            getNextBuffer, getNextBufferLen);

      Serial.println("done!");

      esp_camera_fb_return(fb);
      
    }
  }  
}
