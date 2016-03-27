library rpi_i2c;

import 'dart:async';
import 'dart:io';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:logging/logging.dart';



class RPI_I2C {
  final Logger log = new Logger('rpi_i2c');

  //..level = Level.INFO;

  static const I2C_BUS_ADDR_MIN = 0;
  static const I2C_BUS_ADDR_MAX = 5;
  static const I2C_SLAVE_ADDR_MIN = 0x03;
  static const I2C_SLAVE_ADDR_MAX = 0x77;
  static const I2C_DATA_ADDR_MIN = 0x00;
  static const I2C_DATA_ADDR_MAX = 0xFF;

  /*
  sudo i2cdetect -y 1
       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
  00:          -- 04 -- -- -- -- -- -- -- -- -- -- --
  10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  70: -- -- -- -- -- -- -- --
  */
  Future<List<int>> detect(int busAddress, {String testData: null}) async {
    List<String> slaves = new List<String>();

    if (!isRaspberryPi /* && testData == null*/) {
      //print('Not a RaspberryPi | $args');
      return new Future.value([]);
    } else {
      return Process.run('i2cdetect', ['-y', busAddress.toString()])
          .then((ProcessResult pr) {
        if (pr.exitCode == 0) {
          slaves = pr.stdout.split(' ')
            ..retainWhere((item) => item.length == 2)
            ..removeWhere((item) => item == '--');
          //..forEach((v){v = int.parse(v, radix:16);});

          List<int> slaves2 = new List<int>();
          slaves.forEach((v) => slaves2.add(int.parse(v, radix: 16)));

          return slaves2;
        } else {
          throw new StateError('i2cdetect error\n${pr.stderr}');
        }
      });
    }
  }

  /*
  i2cset -y 1 0x07 0x00 0x02 0x88 0x00 0x00 i
   */
  Future sendByte(int busAddress, int slaveAddress, int dataAddress,
      [int value = null]) {
    if (value == null) {
      return this._send(busAddress, slaveAddress, dataAddress, 'c');
    }
    assert(value >= 0x00 && value <= 0xFF);

    List<String> args = new List<String>();
    args.add(value.toString());

    return this._send(busAddress, slaveAddress, dataAddress, 'b', args);
  }

  /*
  i2cset -y 1 0x07 0x00 0x02 0xFF 0xFF 0xFF i
             [0x07 0x00 0x02 0x00 0x00 0x00 i -y]
   */
  Future sendBlock(int busAddress, int slaveAddress, int dataAddress,
      List<int> value) {
    List<String> args = new List<String>();
    value.forEach((v) {
      assert(v >= 0x00);
      assert(v <= 0xFF);
      args.add(v.toString());
    });

    return this._send(busAddress, slaveAddress, dataAddress, 'i', args);
  }

  Future _send(int busAddress, int slaveAddress, int dataAddress,
      [String mode, List<String> data]) {
    log.finest('$busAddress : $slaveAddress : $dataAddress : $data : $mode');
    assert(busAddress >= I2C_BUS_ADDR_MIN);
    assert(busAddress <= I2C_BUS_ADDR_MAX);
    assert(slaveAddress >= I2C_SLAVE_ADDR_MIN);
    assert(slaveAddress <= I2C_SLAVE_ADDR_MAX);
    assert(dataAddress >= 0x00);
    assert(dataAddress <= 0xFF);

    List<String> args = new List<String>();
    args.add('-y');
    args.add(busAddress.toString());
    args.add(slaveAddress.toString());
    args.add(dataAddress.toString());
    args.addAll(data);
    args.add(mode);

    if (!isRaspberryPi) {
      //print('Not a RaspberryPi | $args');
      return null;
    } else {
      //print('Run i2cset | $args');
      return Process.run('i2cset', args).then((ProcessResult pr) {
        if (pr.exitCode != 0) {
          print('i2cset $args');
          //throw new StateError('i2cset error\n${pr.stderr}');
          print(pr.stderr);
        }
      });
    }
  }
}
