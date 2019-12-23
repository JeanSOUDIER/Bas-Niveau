C:\Program Files\P_1\Tools\ARDUINO\hardware\tools\avr\bin\avrdude.exe


-U lfuse:w:0xC4:m -U hfuse:w:0xD1:m -e -v -patmega16 -carduino -PCOM4 -b19200 -D -Uflash:w:"$(ProjectDir)Debug\$(ItemFileName).hex":i -Ueeprom:w:"$(ProjectDir)eeprom.eep":i -C"C:\Program Files\P_1\Tools\ARDUINO\hardware\tools\avr\etc\avrdude.conf"

-U lfuse:w:0xC4:m -U hfuse:w:0xD1:m -e -v -patmega16 -carduino -PCOM4 -b19200 -D -Uflash:w:"$(ProjectDir)Debug\$(ItemFileName).hex":i -C"C:\Program Files\P_1\Tools\ARDUINO\hardware\tools\avr\etc\avrdude.conf"