`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:26:11 08/03/2012
// Design Name:   Serial
// Module Name:   /home/psi/Dropbox/src/CheckPassword80/serial_test.v
// Project Name:  CheckPassword80
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Serial
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module serial_test;

	// Inputs
	reg RESET;
	reg CLK;
	reg START;
	reg [39:0] BUFFER;

	// Outputs
	wire END;
	wire SIGNAL;

	// Instantiate the Unit Under Test (UUT)
	Serial uut (
		.RESET(RESET), 
		.CLK(CLK), 
		.START(START), 
		.END(END), 
		.SIGNAL(SIGNAL), 
		.BUFFER(BUFFER)
	);

	integer count;
	initial begin
		// Initialize Inputs
		RESET = 0;
		CLK = 0;
		START = 0;
		BUFFER = 40'h0102030405;

		// Wait 10 ns for global reset to finish
		#10;
		CLK=1;
		RESET=1;
		#1;
		CLK=0;
		#1;
		CLK=1;
		RESET=0;
		#1;
		CLK=0;
		#1;
		CLK=1;
		START=1;
		#1;
		CLK=0;
		for (count = 0; count < 3000; count = count + 1) begin
			#1;
			CLK=1;
			#1;
			CLK=0;
		end
		#1;
		CLK=1;
		START=0;
		#1;
		CLK=0;
		#1;
		CLK=1;
		START=1;
		#1;
		CLK=0;
		for (count = 0; count < 3000; count = count + 1) begin
			#1;
			CLK=1;
			#1;
			CLK=0;
		end
	end
      
endmodule

