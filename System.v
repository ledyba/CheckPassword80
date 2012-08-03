`timescale 1ns / 1ps

module Counter(RESET, CLK, OUT);
	parameter integer len = 3;
	input RESET;
	input CLK;
	output [len*8-1:0] OUT;
	reg [len*8-1:0] cnt;
	
	assign OUT=cnt;
	
	wire [len*8-1:0] added;
	wire [len:0] carry;
	assign carry [0] = 1'b1;
	generate
		genvar i;
		for(i=0;i<len;i=i+1) begin: loop
			wire [7:0] total = carry[i]+cnt[i*8+7:i*8];
			wire overflow = total == 95;
			assign carry [i+1] = overflow ? 1'b1 : 1'b0;
			assign added [i*8+7:i*8] = overflow ? total-7'd95 : total;
		end
	endgenerate
	
	always @ (posedge CLK) begin
		if (RESET)
			cnt = 0;
		else
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

module Decoder(RESET, CLK, FOUND, PASSWD_OUT);
	parameter integer ENQLEN=10;
	parameter integer PASSLEN=5;
	parameter [8*ENQLEN-1:0] ENCRYPTED = 0;
	input RESET;
	input CLK;
    output FOUND;
    output [8*PASSLEN-1:0] PASSWD_OUT;
	
	wire [8*PASSLEN-1:0] passwd;
	Counter #(PASSLEN) counter(RESET, CLK, passwd);
	
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

module Serial(RESET, CLK, START, END, SIGNAL, BUFFER);
	parameter integer BUFFLEN=5;
	parameter integer CLOCK=650;
	input RESET;
	input CLK;
	input START;
	output reg END;
	output SIGNAL;
	input [8*BUFFLEN-1:0] BUFFER;
	
	reg [9:0] slckcount;
	wire slckp;
	wire [9:0] next_slckcount;
	
	assign slckp = slckcount == CLOCK;
	assign next_slckcount = slckp ? 0 : slckcount + 10'd1;
	
	reg [3:0] bitwidecount;
	wire bitwide;
	wire [3:0] next_bitwidecount;

	assign bitwide = bitwidecount == 15;
	assign next_bitwidecount =
		bitwide ? 4'd0 :
		slckp ? bitwidecount + 4'd1 :
		bitwidecount;
	
	reg [3:0] framecount;
	wire framelast;
	wire [3:0] next_framecount;

	assign next_framecount =
		framelast ? 0 :
		bitwide ? framecount + 1 :
		framecount;
	assign framelast = framecount == 4'd10;
	
	reg [7:0] charcount;
	wire [7:0] next_charcount;
	
	assign next_charcount =
		END ? 0 :
		framelast ? charcount + 1 :
		charcount;
	
	assign SIGNAL =
		!sending || END || framecount == 0 || framecount == 10 ? 1'b0 :
		framecount == 1 ? 1'b1 :
		BUFFER[8*charcount+framecount-2];
	
	reg sending;
	
	always @(posedge CLK) begin
		if (RESET) begin
			sending = 0;
			slckcount = 0;
			bitwidecount = 0;
			framecount = 0;
			charcount = 0;
			END = 0;
		end
		if (END && !START) begin
			END = 0;
			sending = 0;
		end else if (!END && START && !sending) begin
			sending = 1;
			slckcount = 0;
			bitwidecount = 0;
			framecount = 0;
			charcount = 0;
		end else if (sending) begin
			slckcount = next_slckcount;
			bitwidecount = next_bitwidecount;
			framecount = next_framecount;
			charcount = next_charcount;
			END = next_charcount == BUFFLEN;
			sending = next_charcount != BUFFLEN;
		end
	end
endmodule

module System(RESET, CLK, TXD);
	parameter integer ENQLEN=3;
	parameter integer PASSLEN=1;
	parameter [0:8*ENQLEN-1] ENCRYPTED = 24'h44444;
	input RESET;
	input CLK;
	output TXD;
	wire FOUND;
	wire [0:8*PASSLEN-1] PASSWD_OUT;
	wire SerEnd;
	
	wire DecoderCLK;
	assign DecoderCLK = FOUND  && !SerEND ? 1'b0 : CLK;
	
	Decoder #(ENQLEN, PASSLEN, ENCRYPTED) dec(RESET, DecoderCLK, FOUND, PASSWD_OUT);
	Serial #(PASSLEN) ser(RESET, CLK, FOUND, SerEND, TXD, PASSWD_OUT);
	
	always @(posedge CLK) begin
		
	end
endmodule
