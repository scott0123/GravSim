/*
testbench for FSM
*/


module testbench_FSM();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic CLK = 0;

// input

logic [31:0] A;
assign A = 32'h41133333; // +9.2 decimal

logic [31:0] B;
assign B = 32'h40f00000; // +7.5 decimal

logic [31:0] C;
assign C = 32'h4216cccd; // +37.7 decimal

logic [31:0] D;
assign D = 32'hc2f1cccd; // -120.9 decimal

logic RESET;

// output

logic [31:0] Out;
logic Done, Error;

// Instantiating the DUT
// Make sure the module and signal names match with those in your design
FPU fp2int (

//		input clk,
//    input rst,
//    input [31:0] vin,
//    output reg [31:0] vout,
//    output reg done,
//    output reg error

//	// inputs
//	.clk(CLK),
//	.rst(RESET),
//	.vin(A),
//	// outputs
//	.vout(Out),
//	.done(Done),
//	.error(Error)

	.fp_in(D),
	.int_out(Out)


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

//RESET = 1;

//#5 RESET = 0;

end

endmodule
