
TABLE=" !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

def decode(pass_,key):
	passlen = len(pass_)
	enqlen = len(key)
	buffer_="";
	k=0
	for i in range(0, passlen):
		k=0
		j = passlen-((enqlen-passlen+i)%passlen)-1;
		chr1 = TABLE.find(pass_[j]);
		chr2 = TABLE.find(key[(enqlen-passlen)+i]);
		if chr2 < chr1+j:
			nbase = chr1+j-chr2;
			if nbase <=95:
				k=95
			elif nbase <= 190:
				k=190
			else:
				k=95*3;
		k += (chr2-chr1-j)
		buffer_ += TABLE[k];
	return buffer_;

print( decode("1q2w3e4r5t","n~m.b\'mx%?f2g\'{)-,&v20//") );
for c in decode(" "*5," "*10):
	print(TABLE.find(c));

