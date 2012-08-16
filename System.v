`timescale 1ns / 1ps

module Counter(RESET, CLK, COUNTUP, END, OUT);
	parameter integer len = 3;
	input RESET;
	input CLK;
	input COUNTUP;
	output END;
	output [len*8-1:0] OUT;
	reg [len*8-1:0] cnt;
	
	assign OUT=cnt;
	
	wire [len*8-1:0] added;
	wire [len:0] carry;
	assign carry [0] = COUNTUP;
	assign END = carry[len];
	generate
		genvar i;
		for(i=0;i<len;i=i+1) begin: loop
			wire [7:0] total = carry[i]+cnt[i*8+7:i*8];
			wire overflow = total == 95;
			assign carry [i+1] = overflow ? 1'b1 : 1'b0;
			assign added [i*8+7:i*8] = overflow ? 8'b0 : total;
		end
	endgenerate
	
	always @ (posedge CLK) begin
		cnt <=
			RESET ? {(len*8){1'b0}} :
			END ? cnt :
			added;
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

module Decoder(RESET, CLK, FOUND, END, PASSWD_OUT);
	parameter integer ENQLEN=10;
	parameter integer PASSLEN=5;
	parameter [0:8*ENQLEN-1] ENCRYPTED = 0;
	input RESET;
	input CLK;
    output FOUND;
	output END;
    output [0:8*PASSLEN-1] PASSWD_OUT;
	
	wire [0:8*PASSLEN-1] passwd;
	Counter #(PASSLEN) counter(RESET, CLK, !FOUND, END, passwd);
	
	wire [0:8*PASSLEN-1] decoded;

	generate
		/* 最後のN文字だけ復号し比較する */
		genvar i;
		for(i=0;i<PASSLEN;i=i+1) begin: len
			parameter j = PASSLEN-1-((ENQLEN-PASSLEN + i)%PASSLEN);
			CharDec #(.j(j))
				dev(passwd[j*8:j*8+7], ENCRYPTED[(ENQLEN-PASSLEN+i)*8:(ENQLEN-PASSLEN+i)*8+7], decoded[i*8:i*8+7]);
		end
	endgenerate
	
	assign FOUND = decoded == passwd;
	assign PASSWD_OUT = passwd;
endmodule

module Serial(RESET, CLK, START, END, SIGNAL, BUFFER);
	parameter integer BUFFLEN=5;
	parameter integer CLOCK=26;//389;//433;//650;
	input RESET;
	input CLK;
	input START;
	output reg END;
	output SIGNAL;
	input [0:8*BUFFLEN-1] BUFFER;
	
	reg [9:0] slckcount;
	wire slckp;
	wire [9:0] next_slckcount;
	
	assign slckp = slckcount == CLOCK;
	assign next_slckcount = slckp ? 10'd0 : slckcount + 10'd1;
	
	reg [3:0] bitwidecount;
	wire bitwide;
	wire [3:0] next_bitwidecount;

	assign bitwide = bitwidecount == 15;
	assign next_bitwidecount =
		slckp ? ( bitwide ? 4'd0 : bitwidecount + 4'd1 ) :
		bitwidecount;
	
	reg [3:0] framecount;
	wire framelast;
	wire [3:0] next_framecount;

	assign next_framecount =
		slckp && bitwide ? (framelast ? 4'd0 : framecount + 4'd1 ):
		framecount;
	assign framelast = framecount == 4'd10;
	assign framefirst = framecount == 4'd0;
	assign framestart = framecount == 4'd1;
	
	reg [7:0] charcount;
	wire [7:0] next_charcount;
	
	assign next_charcount =
		(slckp && bitwide && framelast) ? (END ? 8'd0 : charcount + 8'd1) :
		charcount;
	
	assign SIGNAL =
		((!sending) || END || framefirst || framelast) ? 1'b1 : //stopbit
		framestart ? 1'b0 : //startbit
		charcount == 0 ? 1'b1 :
		BUFFER[8*(charcount-1)+9-framecount];
	
	reg sending;
	
	wire SendStart = END && !START;
	wire SendInit;
	always @(posedge CLK) begin
		if (RESET) begin
			sending <= 0;
			slckcount <= 0;
			bitwidecount <= 0;
			framecount <= 0;
			charcount <= 0;
			END <= 0;
		end else if (END && !START) begin
			END <= 0;
			sending <= 0;
		end else if (!END && START && !sending) begin
			sending <= 1;
			slckcount <= 0;
			bitwidecount <= 0;
			framecount <= 0;
			charcount <= 0;
		end else if (sending) begin
			slckcount <= next_slckcount;
			bitwidecount <= next_bitwidecount;
			framecount <= next_framecount;
			charcount <= next_charcount;
			END <= next_charcount ==  (BUFFLEN+1);
			sending <= next_charcount != (BUFFLEN+1);
		end
	end
endmodule

module System(RESET, CLK, FLAG, FOUND, TXD);
	parameter integer ENQLEN=17;
	parameter integer PASSLEN=5;
	parameter [0:8*ENQLEN-1] ENCRYPTED = 136'd22896249489735015330163909889542712410175;
	input RESET;
	input CLK;
	output FLAG;
	output FOUND;
	output TXD;
	wire [0:8*PASSLEN-1] PASSWD_OUT;
	wire SerEnd;
	wire DecoderEND;
	wire SerSEND = FOUND | DecoderEND;
	
	wire DecoderCLK;
	assign DecoderCLK = FOUND  && !SerEND ? 1'b0 : CLK;
	
	reg [24:0] DecoderCount;
	
	assign FLAG=DecoderEND ? 1'b1 : DecoderCount[24];
	
	Decoder #(ENQLEN, PASSLEN, ENCRYPTED) dec(RESET, CLK, FOUND, DecoderEND, PASSWD_OUT);
	Serial #(PASSLEN) ser(RESET, CLK, SerSEND, SerEND, TXD, PASSWD_OUT);
	
	always @(posedge CLK) begin
		DecoderCount <= RESET ? 25'd0 : DecoderCount+25'd1;
	end
endmodule
