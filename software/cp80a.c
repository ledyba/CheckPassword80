#include <stdio.h>
#include <string.h>
#define MAX_SEARCH_LENGTH 100
#define DEC_LENGTH ENC_LENGTH
FILE* LogFile;
char Decrypted[MAX_SEARCH_LENGTH];
const char* Encrypted = "Sok[%~sbN\\LhddxVH\'bNM)ZZX~w6$}#0)!{&y)0},2%S_]Q]T[Lf\\OZbF";
char ENC_LENGTH;
const char* KEY_CHAR = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
char KEY_LENGTH;

char EncryptedKeyIndex[MAX_SEARCH_LENGTH];
char START_LENGTH[MAX_SEARCH_LENGTH][MAX_SEARCH_LENGTH];

char SearchText[MAX_SEARCH_LENGTH] = "";
char SearchTextIdx[MAX_SEARCH_LENGTH];

char strser(const char* a,char b,char size){
	char cnt = 0;
	const char* ap = a;
	while(*ap != b && cnt < size){
	cnt++;
	ap++;
	}
	return cnt;
}
void init_decrypter(){
	char i,j,k;
	char max = KEY_LENGTH;
	for(i=0;i<max;i++){
		EncryptedKeyIndex[i] = strser(KEY_CHAR,Encrypted[i],KEY_LENGTH);
		if(i <= 0)continue;
	 	k=i-1;
		for(j=0;j<max;j++){
			START_LENGTH[i][j] = k;
			if(k == 0) k = i;
			k--;
		}
	}
}
void dec(char length,char start,char end){
	char i = start,j = START_LENGTH[length][start];
	short k=0;
	char ch[2];
	for(;i<end;i++,k=0){
		ch[0] = SearchTextIdx[j];
		ch[1] = EncryptedKeyIndex[i];
        if(ch[1] < (ch[0] + j)){
        	short nbase = (ch[0] + j - ch[1]);
            if(nbase <= 95){
            	k +=95;
            }else if(nbase <= 95*2){
            	k += 95*2;
            }else if(nbase <= 95*3){
        		k += 95*3;
		}
	}
    k += (ch[1] - ch[0] - j);
    Decrypted[i] = KEY_CHAR[k];
    if(j == 0)j = length;
    j--;
	}
}
char key_dec(char length,char start,char end){
	char i = start,j = START_LENGTH[length][start],ret = 1;
	short k=0;
	char ch[2];
	char decrypted,dec_cnt = 0;
	for(;ret && i<end;i++,dec_cnt++,k=0){
		ch[0] = SearchTextIdx[j];
		ch[1] = EncryptedKeyIndex[i];
	    if(ch[1] < (ch[0] + j)){
			short nbase = (ch[0] + j - ch[1]);
			if(nbase <= 95){
				k +=95;
			}else if(nbase <= 95*2){
		    	k += 95*2;
		    }else if(nbase <= 95*3){
		    	k += 95*3;
			}
		}
	    k += (ch[1] - ch[0] - j);
	    decrypted = KEY_CHAR[k];
	    Decrypted[i] = decrypted;
	    ret &= decrypted == SearchText[dec_cnt];
	    if(j == 0)j = length;
	    j--;
	}
	return ret;
}
void log_key(const char* key,const char* path){
	LogFile = fopen("dec.txt","a");
	fprintf(LogFile,"%s:%s\n",key,path);
	printf("%s:%s\n",key,path);
	fclose(LogFile);
}
void decrypt(char length){
	char max = DEC_LENGTH;
	char bottom = max-length;
	char i=0;
	if(key_dec(length,max-length,max)){
		{
		char k[length];
		dec(length,0,max-length);
		strncpy(k,SearchText,length+1);
		k[length] = '\0';
		Decrypted[bottom] = '\0';
		log_key(k,Decrypted);
		}
	}
}
void loop(char depth,char max_depth){
	char next_depth = depth+1;
	char i=0;
	char length = KEY_LENGTH;
	if(depth >= max_depth){
		decrypt(max_depth);
		return;
	}
	for(;i<length;i++){
		SearchText[depth] = KEY_CHAR[i];
		SearchTextIdx[depth] = i;
		loop(next_depth,max_depth);
	}
}
void log_depth(char depth){
	LogFile = fopen("dec.txt","a");
	fprintf(LogFile,"Now Searching... Length:%d\n",depth);
	printf("Now Searching... Length:%d\n",depth);
	fclose(LogFile);
}
void search(){
	char i=1;
	char length = ENC_LENGTH;
	for(;i<length;i++){
		log_depth(i);
		loop(0,i);
	}
}
int main(){
	KEY_LENGTH = strlen(KEY_CHAR);
	ENC_LENGTH = strlen(Encrypted);
	init_decrypter();
	search();
	return 0;
}
