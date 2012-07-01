`timescale 1ns / 1ps

module Counter(CLK, OUT);
	parameter integer len = 3;
	input CLK;
	output [len*8-1:0] OUT;
	reg [len*8-1:0] cnt;
	
	assign OUT=cnt;
	
	initial begin
		cnt=0;
	end
	wire [len*8-1:0] added;
	wire [len*8+7:0] carry;
	assign carry [7:0] = 8'b0001;
	generate
		genvar i;
		for(i=0;i<len;i=i+1) begin: loop
			wire [7:0] total = carry[i*8+7:i*8]+cnt[i*8+7:i*8];
			wire overflow = total >= 95;
			assign carry [i*8+15:i*8+8] = overflow ? 8'b1 : 8'b0;
			assign added [i*8+7:i*8] = overflow ? total-95 : total;
		end
	endgenerate
	
	always @ (posedge CLK) begin
		cnt = added;
	end
endmodule

module CharDec(chr1, chr2, decoded);
	parameter [7:0] j=0;
	input [7:0] chr1;
	input [7:0] chr2;
	output [7:0] decoded;

	//if (chr2 < (chr1 + j)) {
	wire [7:0] total = chr1+j;
	wire flag = chr2 < total;
	//nbase = (chr1 + j - chr2) / 0x5f;
	//k += (0x5f * Math.ceil(nbase));
	wire [7:0] base = total - chr2;
	wire [7:0] nbase =
		base <= (95*1) ? 95 :
		base <= (95*2) ? (95*2) : 95*3;
	//}
	//k += (chr2 - chr1 - j);
	wire [7:0] baseK = flag ? nbase : 0;
	assign decoded = baseK + chr2 - total;

endmodule

module Decoder(CLK, FOUND, PASSWD_OUT);
	parameter integer ENQLEN=10;
	parameter integer PASSLEN=5;
	parameter [8*ENQLEN-1:0] ENCRYPTED = 0;
	input CLK;
    output FOUND;
    output [8*PASSLEN-1:0] PASSWD_OUT;
	
	wire [8*PASSLEN-1:0] passwd;
	Counter #(PASSLEN) counter(CLK, passwd);
	
	wire [8*PASSLEN-1:0] decoded;

	generate
		/* 最後のN文字だけ復号し比較する */
		genvar i;
		for(i=0;i<PASSLEN;i=i+1) begin: len
			CharDec #(.j(PASSLEN-1-((ENQLEN-PASSLEN + i)%PASSLEN)))
				dev(passwd[(PASSLEN-1-i)*8+7:(PASSLEN-1-i)*8], ENCRYPTED[(ENQLEN-1-i)*8+7:(ENQLEN-1-i)*8], decoded[(PASSLEN-1-i)*8+7:(PASSLEN-1-i)*8]);
		end
	endgenerate
	
	assign FOUND = decoded == passwd;
	assign PASSWD_OUT = passwd;
endmodule

module System(input CLK, output FOUND, output [0:39] PASSWD_OUT);
	parameter integer ENQLEN=10;
	parameter integer PASSLEN=5;
	parameter [0:8*ENQLEN-1] ENCRYPTED = 0;
	
	Decoder #(ENQLEN, PASSLEN, ENCRYPTED) dec(CLK, FOUND, PASSWD_OUT);
endmodule
