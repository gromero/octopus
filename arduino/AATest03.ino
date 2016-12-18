/*

Read 19-bit signature from CPLD register.
If the signature is 0x4ABCD it means no
address has been requested on the address
bus by the victm, hence the reset vector
address is not yet present
to be retrieved by the Arduino board.

Another way to verify for sure that 19-bit
vector address is not initialized is by
checking bit S (status). If S = 0 no
address indeed has been requested yet on
the bus.

*/

#define O_DATA0  2
#define O_DATA1  3

#define S        4

#define I_CLK    5

#define _G       6
#define _E       7

#define I_ADDR0  8
#define I_ADDR1  9
#define I_ADDR2  10
#define I_ADDR3  11
#define I_ADDR4  12


void setup() {
  pinMode(O_DATA0, INPUT);
  pinMode(O_DATA1, INPUT);

  pinMode(S, INPUT);

  pinMode(I_CLK,  OUTPUT);

  pinMode(_G,  OUTPUT);
  pinMode(_E,  OUTPUT);

  pinMode(I_ADDR0,  OUTPUT);
  pinMode(I_ADDR1,  OUTPUT);
  pinMode(I_ADDR2,  OUTPUT);
  pinMode(I_ADDR3,  OUTPUT);
  pinMode(I_ADDR4,  OUTPUT);

  digitalWrite(_G, HIGH); // OE disabled
  digitalWrite(_E, HIGH); // CE disabled

  digitalWrite(I_ADDR0, LOW);
  digitalWrite(I_ADDR1, LOW);
  digitalWrite(I_ADDR2, LOW);
  digitalWrite(I_ADDR3, LOW);
  digitalWrite(I_ADDR4, LOW);

  digitalWrite(I_CLK, LOW);

  // Set serial.
  Serial.begin(9600);
  while (!Serial) {
  ; // wait for serial port to connect.
    // Needed for native USB port only
  }

  // Setup OK.
  Serial.println("OK");
}

// Back-end clock (slow).
void clock()
{
  digitalWrite(I_CLK, HIGH);
  digitalWrite(I_CLK, LOW);
}

void loop() {
  unsigned int value[2]; // TODO: use uint32_t
  int addr;

  // Obtain 19-bit data (indeed 20-bit but 20th is hard-wired to zero.
  // Get 2-bit a time, higher bits first. Split into 16-bit, one half
  // to value[0] (bit 15-0) and to value[1] (18-16).
  value[0] = 0;
  value[1] = 0;

  for (addr = 9; addr >= 0; addr--) {
    addr & 1 << 0 ? digitalWrite(I_ADDR0, HIGH) :  digitalWrite(I_ADDR0, LOW);
    addr & 1 << 1 ? digitalWrite(I_ADDR1, HIGH) :  digitalWrite(I_ADDR1, LOW);
    addr & 1 << 2 ? digitalWrite(I_ADDR2, HIGH) :  digitalWrite(I_ADDR2, LOW);
    addr & 1 << 3 ? digitalWrite(I_ADDR3, HIGH) :  digitalWrite(I_ADDR3, LOW);
    addr & 1 << 4 ? digitalWrite(I_ADDR4, LOW) :  digitalWrite(I_ADDR4, LOW);

    clock();

    if (addr < 8) {
      value[0] = value[0] << 1;
      value[0] += digitalRead(O_DATA1);
      value[0] = value[0] << 1;
      value[0] += digitalRead(O_DATA0);
    } else {
      value[1] = value [1] << 1;
      value[1] += digitalRead(O_DATA1);
      value[1] = value[1] << 1;
      value[1] += digitalRead(O_DATA0);
    }
  }

  // Check signature
  if (value[1] == 4 && value[0] == 0xABCD) {
   Serial.print("Valid signature found: ");
   Serial.print("0x");
   Serial.print(value[1], HEX);
   Serial.println(value[0], HEX);
  } else {
    Serial.print("No valid signature found: ");
    Serial.print("0x");
    Serial.print(value[1], HEX);
    Serial.println(value[0], HEX);
  }

  delay(2000);
//while(1);
}
