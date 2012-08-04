
TABLE=" !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
TABLE_LEN=len(TABLE);

def decodeAt(klen, plen, i, j, p, k):
	offset = klen-plen;
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
		try:
			for ci in range(0,TABLE_LEN):
				for cj in range(0,TABLE_LEN):
					if decodeAt(klen, plen, i, j, cj, ki) == ci and decodeAt(klen, plen, j, i, ci, kj) == cj:
						res[i].append(TABLE[ci]);
						res[j].append(TABLE[cj]);
						raise Exception();
		except:
			pass
	return res

def decode(pass_,key):
	passlen = len(pass_)
	enqlen = len(key)
	buffer_="";
	for i in range(0, passlen):
		k=0
		j = passlen-((enqlen-passlen+i)%passlen)-1;
		buffer_ += TABLE[decodeAt(enqlen, passlen, i, j, TABLE.find(pass_[j]), TABLE.find(key[(enqlen-passlen)+i]))];
	return buffer_;

#print( decode("1q2w3e4r5t","n~m.b\'mx%?f2g\'{)-,&v20//") );
#print( decode("KR%%RKT$$T","n~m.b\'mx%?f2g\'{)-,&v20//") );
print( calc("n~m.b\'mx%?f2g\'{)-,&v20//", len("1q2w3e4r5t")) );
#for c in decode(" "*5," "*10):
#	print(TABLE.find(c));

