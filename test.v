`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:19:01 07/01/2012
// Design Name:   System
// Module Name:   /home/psi/Dropbox/src/CheckPassword80/test.v
// Project Name:  CheckPassword80
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: System
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;

	// Inputs
	reg CLK;
	reg RESET;

	// Outputs
	wire FLAG;
	wire FOUND;
	wire TXD;

	integer count;
	
	// Instantiate the Unit Under Test (UUT)
	System uut (
		.RESET(RESET), 
		.CLK(CLK), 
		.FLAG(FLAG),
		.FOUND(FOUND),
		.TXD(TXD)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		RESET=1;
		#1;
		CLK = 1;
		#1;
		RESET=0;
		CLK = 0;
		// Add stimulus here
		for (count = 0; count < 200000000; count = count + 1) begin
			#1;
			CLK=1;
			#1;
			CLK=0;
		end
	end
      
endmodule

