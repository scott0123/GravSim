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


const int OFFSET_NUM = 0;
const int OFFSET_START = 1;
const int OFFSET_DONE = 2;
const int OFFSET_MASS = 3-1;
const int OFFSET_RAD = 13-1;
const int OFFSET_POS_X = 23-1;
const int OFFSET_POS_Y = 33-1;
const int OFFSET_POS_Z = 43-1;
const int OFFSET_VEL_X = 53-1;
const int OFFSET_VEL_Y = 63-1;
const int OFFSET_VEL_Z = 73-1;
const int OFFSET_ACC_X = 83-1;
const int OFFSET_ACC_Y = 93-1;
const int OFFSET_ACC_Z = 103-1;


// inputs
//input	 logic CLK;
logic RESET;
logic FSM_START;
logic [31:0] regfile [113];

// outputs
logic FSM_DONE;
logic FSM_we;
logic [31:0] ADDR1, ADDR2, ADDR3;
logic [31:0] data1, data2, data3;




// Instantiating the DUT
// Make sure the module and signal names match with those in your design
FSM FSM_instance (

	// inputs
	.CLK(CLK),
	.RESET(RESET),
	.FSM_START(regfile[OFFSET_START][0]),
	.datafile(regfile),
	
	// outputs
	.FSM_DONE,
	
	// added outputs
	.FSM_we,
	.ADDR1,
	.ADDR2,
	.ADDR3,
	.data1,
	.data2,
	.data3

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
RESET = 1;

//for (integer i = 0; i < 113; i += 1) begin
//	datafile[i] = 32'b0;
//end

#10
RESET = 0;

regfile[OFFSET_RAD + 1] = 32'h3f800000; // 1 
regfile[OFFSET_POS_X + 1] = 32'h0; // 0 
regfile[OFFSET_POS_Y + 1] = 32'h0; // 0 
regfile[OFFSET_POS_Z + 1] = 32'h0; // 0
regfile[OFFSET_VEL_X + 1] = 32'h3f800000; // 1 
regfile[OFFSET_VEL_Y + 1] = 32'h0; // 0
regfile[OFFSET_VEL_Z + 1] = 32'h0; // 0 
regfile[OFFSET_ACC_X + 1] = 32'h0; // 0
regfile[OFFSET_ACC_Y + 1] = 32'h0; // 0 
regfile[OFFSET_ACC_Z + 1] = 32'h0; // 0 

regfile[OFFSET_START] = 32'b1; // 1



end

endmodule
