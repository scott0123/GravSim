/*
testbench for FPU
*/


module testbench_FPU();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic CLK = 0;

// input

logic [31:0] A;
assign A = 32'hc1133333; // -9.2 decimal

logic [31:0] B;
assign B = 32'h40f00000; // 7.5 decimal

// output

logic [31:0] Sum;

// Instantiating the DUT
// Make sure the module and signal names match with those in your design
FPU fpu_add (
//	input             iCLK,
//	input      [26:0] iA,
//	input      [26:0] iB,
//	output     [26:0] oSum

	// inputs
	.iCLK(CLK),
	.iA(A),
	.iB(B),
	
	// outputs
	.oSum(Sum)
);

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 CLK = ~CLK;
end

initial begin: CLOCK_INITIALIZATION
	CLK = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS





end

endmodule
