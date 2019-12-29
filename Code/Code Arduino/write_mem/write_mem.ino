#define DATAOUT 12//MOSI
#define DATAIN  11//MISO 
#define SPICLOCK  13//sck
#define SLAVESELECT 10//ss

//opcodes
#define WREN  6
#define WRDI  4
#define RDSR  5
#define WRSR  1
#define READ  3
#define WRITE 2

unsigned char plan_mem[] = {32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,96,24,134,113,13,2,2,4,4,8,8,9,114,130,4,24,102,161,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,0,0,0,0,0,0,0,0,0,0,0,128,96,24,134,97,24,6,1,0,0,0,0,0,0,0,0,0,0,1,254,112,128,128,131,140,240,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,192,32,24,134,97,24,6,1,0,0,0,0,0,0,0,0,0,0,0,0,192,56,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,192,48,12,2,193,48,12,3,0,0,0,0,0,0,0,0,0,0,0,0,0,192,56,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,27,32,192,4,27,32,192,0,0,0,0,0,0,0,0,0,0,0,0,128,112,14,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,6,24,32,35,36,56,48,16,8,8,4,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,240,16,80,80,112,16,208,16,208,80,80,80,80,80,80,208,16,208,16,240,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,4,213,145,189,133,247,16,191,136,171,161,191,40,235,137,44,239,0,255,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,255,226,138,184,142,168,174,162,187,160,254,128,191,168,171,160,190,163,136,255

};
int compteur = 0;

char spi_transfer(volatile char data) {
  SPDR = data;                    // Start the transmission
  while (!(SPSR & (1<<SPIF)))     // Wait the end of the transmission
  {};
  return SPDR;                    // return the received byte
}

void writeMem(int address) {
  //plan_mem
  for(int i=0;i<(int)(sizeof(plan_mem)/64)+1;i++) {
    digitalWrite(SLAVESELECT,LOW);
    spi_transfer(WREN);
    digitalWrite(SLAVESELECT,HIGH);
    delay(10);
    digitalWrite(SLAVESELECT,LOW);
    //Serial.print("a = ");
    //Serial.println(address);
    spi_transfer(WRITE); //write instruction
    spi_transfer((char)(address>>8));   //send MSByte address first
    spi_transfer((char)(address));      //send LSByte address
    address += 64;
    for(int j=0;j<64;j++) {
      //Serial.println(j+i*64);
      spi_transfer(plan_mem[j+i*64]); //write data byte
    }
    digitalWrite(SLAVESELECT,HIGH);
    delay(10);
  }
  
  digitalWrite(SLAVESELECT,LOW);
  spi_transfer(WRDI); //write disable
  digitalWrite(SLAVESELECT,HIGH);
  delay(10);
}

unsigned char readMem(int address) {
  int data;
  digitalWrite(SLAVESELECT,LOW);
  spi_transfer(READ); //transmit read opcode
  spi_transfer((char)(address>>8));   //send MSByte address first
  spi_transfer((char)(address));      //send LSByte address
  data = spi_transfer(0xFF); //get data byte
  digitalWrite(SLAVESELECT,HIGH); //release chip, signal end transfer
  //Serial.println((unsigned char)(data));
  return (unsigned char)(data);
}

void setup() {
  Serial.begin(9600);

  pinMode(DATAOUT, OUTPUT);
  pinMode(DATAIN, INPUT);
  pinMode(SPICLOCK,OUTPUT);
  pinMode(SLAVESELECT,OUTPUT);
  digitalWrite(SLAVESELECT,HIGH); //disable device

  SPCR = (1<<SPE)|(1<<MSTR);
  //clr=SPSR;
  //clr=SPDR;
  delay(10);

  writeMem(0);

  int testeur = 1, cpt_err = 0;

  while(testeur) {
    int test0 = readMem(compteur);
    Serial.print(test0);
    Serial.print(" <= ");
    Serial.println(plan_mem[compteur]);
    if(test0 != plan_mem[compteur]) {
      Serial.print("error addr = ");
      Serial.println(compteur);
      cpt_err++;
    }
    compteur++;
    if(compteur > sizeof(plan_mem)-1) {
      compteur = 0;
      testeur = 0;
      Serial.println("----------------------");
      if(!cpt_err) {
        Serial.println("OK");
      }
    }
  }
  
}

void loop() {
  
}
