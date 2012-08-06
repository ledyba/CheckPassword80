#! python3
# -*- coding: utf-8 -*-

from base import TABLE, TABLE_LEN
import serial

def receiveFPGA(devname):
	com = serial.Serial(
		port=devname,
		baudrate=9600,
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
		first = ord((serial.to_bytes(com.read(1)))[0])
		if first != 255: #first character
			print("oops.Invalid seq: {0}".format(first));
			continue
		data = serial.to_bytes(com.read(10));
		decoded='';
		for c in data:
			decoded += TABLE[ord(c)];
		print("Received: "+decoded)
receiveFPGA("/dev/ttyUSB0")


