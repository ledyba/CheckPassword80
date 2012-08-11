#! python3
# -*- coding: utf-8 -*-

from base import TABLE, TABLE_LEN, decodeAt, toFPGA

def calc(key, plen):
	res = [None]*plen;
	klen = len(key)
	offset = klen-plen;
	for i in range(0, plen):
		j = plen-((offset+i)%plen)-1;
		if res[i] != None or res[j] != None:
			continue
		res[i]=[]
		res[j]=[]
		ki = TABLE.find(key[offset+i]);
		kj = TABLE.find(key[offset+j]);
		for ci in range(0,TABLE_LEN):
			for cj in range(0,TABLE_LEN):
				if decodeAt(i, j, cj, ki) == ci and decodeAt(j, i, ci, kj) == cj:
					res[i].append(TABLE[ci]);
					res[j].append(TABLE[cj]);
	return res

def decode(pass_,key):
	passlen = len(pass_)
	enqlen = len(key)
	buffer_="";
	for i in range(0, enqlen):
		k=0
		j = passlen-(i%passlen)-1;
		buffer_ += TABLE[decodeAt(i, j, TABLE.find(pass_[j]), TABLE.find(key[i]))];
	return buffer_;


