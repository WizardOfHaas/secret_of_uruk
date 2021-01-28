import sys
import os
import serial
import struct
from array import array

data = array('B')
size = os.path.getsize(sys.argv[1])

with open(sys.argv[1], 'rb') as f:
    data.fromfile(f, size)

ser = serial.Serial('/dev/ttyUSB0')
ser.baudrate = 9600
ser.write(">")
ser.write(struct.pack("<H", size))
ser.write(data)
