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

	// Outputs
	wire FOUND;
	wire [0:39] PASSWD_OUT;


	integer count;
	
	// Instantiate the Unit Under Test (UUT)
	System uut (
		.CLK(CLK), 
		.FOUND(FOUND), 
		.PASSWD_OUT(PASSWD_OUT)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;

		// Add stimulus here

		#10 $finish;
		for (count = 0; count < 200; count = count + 1) begin
			#1;
			CLK=1;
			#1;
			CLK=0;
		end
		#10 $finish;
	end
      
endmodule

