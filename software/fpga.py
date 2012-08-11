#! python3
# -*- coding: utf-8 -*-

from base import TABLE, TABLE_LEN
from decode import decode
import serial

PASSLEN=5
ENCODED="ciY`JWeqUV[bEXC`_"
ANSLEN=len(ENCODED)-PASSLEN
ENDSTRING=[94] * PASSLEN

def receiveFPGA(devname):
	com = serial.Serial(
		port=devname,
		baudrate=230400,
		bytesize=8,
		parity=serial.PARITY_NONE,
		stopbits=serial.STOPBITS_ONE,
		timeout=None,
		xonxoff=False,
		rtscts=False,
		writeTimeout=None,
		dsrdtr=False)
	data = None
	print("Receiving...");
	while True:
		#first = ord((serial.to_bytes(com.read(1)))[0])
		first = list(com.read(1))[0]
		if first != 255: #first character
			print("oops.Invalid seq: {0}".format(first));
			continue
		#data = serial.to_bytes(com.read(PASSLEN));
		#data = map((lambda x: ord(x)), data);
		data = list(com.read(PASSLEN))
		if data == ENDSTRING:
			return;
		decoded='';
		for c in data:
			decoded += TABLE[c];
		decrypt = decode(decoded, ENCODED);
		print("{0}:{1}".format(decoded, decrypt[0:ANSLEN], decrypt[ANSLEN:]==decoded))

#receiveFPGA("/dev/ttyUSB0")
receiveFPGA("COM4")


