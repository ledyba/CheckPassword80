
TABLE=" !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

def decode(pass_,key):
	passlen = len(pass_)
	enqlen = len(key)
	buffer_="";
	k=0
	j=passlen-1
	for i in range(0, enqlen-1):
		k=0
		if j<0:
			j=passlen-1;
		chr1 = TABLE.find(pass_[j]);
		print(pass_[j])
		chr2 = TABLE.find(key[i]);
		if chr2 < chr1+j:
			nbase = int( (chr1+j-chr2+4)/95 );
			k += (nbase*95)
		k += (chr2-chr1-j)
		buffer_ += TABLE[k];
		j-=1;
	return buffer_;

print( decode("1q2w3e4r5t","n~m.b\'mx%?f2g\'{)-,&v20//") );
