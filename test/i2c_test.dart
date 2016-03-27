import 'dart:io';

import './../lib/rpi_i2c.dart';

String resultI2cdetect = '''
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- 04 -- -- -- -- -- -- -- -- -- -- --
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
70: -- -- -- -- -- -- -- --
''';

main() async {
  print('I2C tests START');
  RPI_I2C i2cBus = new RPI_I2C();

  i2cBus.detect(1, testData: resultI2cdetect).then(print);

  i2cBus.detect(1).then(print);

  await i2cBus.sendBlock(1, 0x06, 0x00, [0x02, 0x00, 0x00, 0x00]); //Eteind
  await sleep(new Duration(milliseconds: 500));
  await i2cBus.sendBlock(1, 0x06, 0x00, [0x02, 0xFF, 0xFF, 0xFF]); //Blanc
  await sleep(new Duration(milliseconds: 500));
  await i2cBus.sendBlock(1, 0x06, 0x00, [0x02, 0xFF, 0x00, 0x00]); //Red
  await sleep(new Duration(milliseconds: 500));
  await i2cBus.sendBlock(1, 0x06, 0x00, [0x02, 0x00, 0xFF, 0x00]); //Green
  await sleep(new Duration(milliseconds: 500));
  await i2cBus.sendBlock(1, 0x06, 0x00, [0x02, 0x00, 0x00, 0xFF]); //Blue
  await sleep(new Duration(milliseconds: 500));

  print('I2C tests END');
}
