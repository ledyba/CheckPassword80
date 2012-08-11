#! python3
# -*- coding: utf-8 -*-

from base import TABLE, TABLE_LEN, decodeAt, encodeAt, toFPGA

def encode(ans,pass_):
	key = ans+pass_
	passlen = len(pass_)
	enqlen = len(key)
	anslen = len(ans)
	buffer_="";
	for i in range(0, enqlen):
		k=0
		j = passlen-(i%passlen)-1;
		buffer_ += TABLE[encodeAt(i, j, TABLE.find(pass_[j]), TABLE.find(key[i]))];
	return buffer_;

URL="usushio.html"
KEY="akari"
encoded = encode(URL, KEY);
print( repr(encoded) );
print( toFPGA(encode(URL, KEY)) );
print( "len: {0} / {1}".format(len(URL), len(KEY)) )

