#! python3
# -*- coding: utf-8 -*-

TABLE=" !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
TABLE_LEN=len(TABLE);

def toFPGA(key):
	klen = len(key);
	kint = 0;
	for c in key:
		kint <<= 8;
		kint |= TABLE.find(c);
	return "{0}'d{1}".format(klen*8, str(kint));

def decodeAt(i, j, p, k):
	d=0
	if k < p+j:
		nbase = p+j-k;
		if nbase <=95:
			d=95
		elif nbase <= 190:
			d=190
		else:
			d=95*3;
	d += (k-p-j)
	return d
	
def encodeAt(i, j, p, a):
	k = (a+p+j) % 95
	return k

