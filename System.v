`timescale 1ns / 1ps

module Counter(CLK, OUT);
	parameter integer len = 3;
	input CLK;
	output [len*4-1:0] OUT;
	reg [len*4-1:0] cnt;
	
	assign OUT=cnt;
	
	initial begin
		cnt=0;
	end
	wire [len*4-1:0] added;
	wire [len*4+3:0] carry;
	assign carry [3:0] = 4'b0001;
	generate
		genvar i;
		for(i=len-1;i>=0;i=i-1) begin: loop
			Adder a ({4'b0000, cnt[i*4+3:i*4]}, {4'b0000, carry[i*4+3:i*4]} , {carry[i*4+7:i*4+4], added[i*4+3:i*4] });
		end
	endgenerate
	
	always @ (posedge CLK) begin
		cnt = added;
	end
endmodule

// z = x+y;
module Adder(x, y, z);
	parameter larger_z = 0;
	input [7:0] x;
	input [7:0] y;
	output [7+larger_z:0] z;

	wire [4:0] one_add = x[3:0]+y[3:0];
	wire carry = one_add >= 10;
	
	assign z[7+larger_z:4] = x[7:4] + y[7:4] + carry;
	assign z[3:0] = carry ? one_add-10 : one_add;
endmodule

//z = x-y;
module Subtracter(x,y,z);
	parameter larger_x = 0;
	parameter larger_z = 0;
	input [7+larger_x:0] x;
	input [7:0] y;
	output [7+larger_z:0] z;

	wire minus = x[3:0] < y[3:0];

	assign z[3:0] = (minus ? 10 : 0 ) + x[3:0] - y[3:0];
	assign z[7+larger_z:4] = x[7+larger_x:4] - y[7:4] - minus;
endmodule

module CharDec(chr1, chr2, decoded);
	parameter [7:0] j=0;
	input [7:0] chr1;
	input [7:0] chr2;
	output [7:0] decoded;

	//if (chr2 < (chr1 + j)) {
	wire [7:0] total;
	Adder addForTotal(chr1, j, total);
	wire flag = chr2 < total;
	//nbase = (chr1 + j - chr2) / 0x5f;
	//k += (0x5f * Math.ceil(nbase));
	wire [7:0] base;
	Subtracter subForBase ( total, chr2, base);
	wire [7:0] nbase;
	assign nbase[7:4] = (base[3:0] > 5 ? 1 : 0)+base[7:4];
	assign nbase[3:0] = (base[3:0] > 5 | base[3:0] == 0 ? 0 : 5);
	//}
	//k += (chr2 - chr1 - j);
	wire [7:0] baseK = flag ? nbase : 0;
	wire [8:0] k1; /* 桁溢れ考慮 */
	Adder #(.larger_z(1)) addForK1(baseK, chr2, k1);
	wire [8:0] k2;
	Subtracter #(.larger_z(1),.larger_x(1)) subForK2(k1, chr1, k2);

	Subtracter #(.larger_x(1)) subForDecoded(k2, j, decoded);

endmodule

module Decoder(CLK, FOUND, PASSWD_OUT);
	parameter integer ENQLEN=10;
	parameter integer PASSLEN=5;
	parameter [8*ENQLEN-1:0] ENCRYPTED = 0;
	input CLK;
    output FOUND;
    output [8*PASSLEN-1:0] PASSWD_OUT;
	
	wire [8*PASSLEN-1:0] passwd;
	Counter #(PASSLEN*2) counter(CLK, passwd);
	
	wire [8*PASSLEN-1:0] decoded;

	generate
		genvar i;
		for(i=0;i<PASSLEN;i=i+1) begin: len
			CharDec #(.j(PASSLEN-((ENQLEN-PASSLEN + i)%PASSLEN)))
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
