#define ARDUINO_INPUT 10  // arduino_input

// eq = i0 XOR i1, defined on verilog source file 
#define I0            8   // i0
#define I1            9   // i1

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(ARDUINO_INPUT, OUTPUT);

  // I0 XOR I1 => eq (led on)
  pinMode(I0, OUTPUT);
  pinMode(I1, OUTPUT);

  digitalWrite(I0, LOW);
  digitalWrite(I1, LOW);
}

// blink led on Arduino and Amani64 board
void loop() {
  digitalWrite(LED_BUILTIN, HIGH);     // turn the LED on (HIGH is the voltage level)
  digitalWrite(ARDUINO_INPUT, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(100);                          // wait for a second
  digitalWrite(LED_BUILTIN, LOW);      // turn the LED off by making the voltage LOW
  digitalWrite(ARDUINO_INPUT, LOW);    // turn the LED on (HIGH is the voltage level)
  delay(100);                          // wait for a second
}
