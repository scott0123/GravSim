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

const int OFFSET_G = 0;
const int OFFSET_NUM = 1;
const int OFFSET_START = 2;
const int OFFSET_DONE = 3;
const int OFFSET_MASS = 4-1;
const int OFFSET_RAD = 14-1;
const int OFFSET_POS_X = 24-1;
const int OFFSET_POS_Y = 34-1;
const int OFFSET_POS_Z = 44-1;
const int OFFSET_VEL_X = 54-1;
const int OFFSET_VEL_Y = 64-1;
const int OFFSET_VEL_Z = 74-1;
const int OFFSET_ACC_X = 84-1;
const int OFFSET_ACC_Y = 94-1;
const int OFFSET_ACC_Z = 104-1;

// data storage
logic [31:0] regfile [113];

// inputs
//input	 logic CLK;
logic RESET;
logic FSM_START;
logic [31:0] DATA1in, DATA2in, DATA3in, DATA4in, DATA5in, DATA6in;
logic [31:0] PLANET_NUM, G;

// outputs
logic clear_accs;
logic FSM_DONE;
logic [1:0] FSM_re, FSM_we;
logic [31:0] ADDR1, ADDR2, ADDR3, ADDR4, ADDR5, ADDR6;
logic [31:0] DATA1, DATA2, DATA3, DATA4, DATA5, DATA6;

// other internal signals to monitor

logic[31:0] D1, D2, D3, D4, D5, D6, D1in, D2in, D3in, D4in, D5in, D6in, A1, A2, A3, A4, A5, A6;

assign D1 = FSM_instance.DATA1;
assign D2 = FSM_instance.DATA2;
assign D3 = FSM_instance.DATA3;
assign D4 = FSM_instance.DATA4;
assign D5 = FSM_instance.DATA5;
assign D6 = FSM_instance.DATA6;

assign D1in = FSM_instance.DATA1in;
assign D2in = FSM_instance.DATA2in;
assign D3in = FSM_instance.DATA3in;
assign D4in = FSM_instance.DATA4in;
assign D5in = FSM_instance.DATA5in;
assign D6in = FSM_instance.DATA6in;

assign A1 = FSM_instance.ADDR1;
assign A2 = FSM_instance.ADDR2;
assign A3 = FSM_instance.ADDR3;
assign A4 = FSM_instance.ADDR4;
assign A5 = FSM_instance.ADDR5;
assign A6 = FSM_instance.ADDR6;

//logic [5:0] state, next_state;					
//assign state = FSM_instance.state;
//assign next_state = FSM_instance.next_state;

//logic [31:0] FPadd_opA_int, FPadd_opB_int, FPadd_outAB_int;
//assign FPadd_opA_int = FSM_instance.FPadd_AB.iA;
//assign FPadd_opB_int = FSM_instance.FPadd_AB.iB;
//assign FPadd_outAB_int = FSM_instance.FPadd_AB.oSum;
//
//logic [31:0] FPmult_opA_int, FPmult_opB_int, FPmult_outAB_int;
//assign FPmult_opA_int = FSM_instance.FPmult_AB.iA;
//assign FPmult_opB_int = FSM_instance.FPmult_AB.iB;
//assign FPmult_outAB_int = FSM_instance.FPmult_AB.oProd;
//
//logic [31:0] FPadd_outAB_cached, FPmult_outEF_cached, FPinv_out; //FP_invsqrt_out;
//assign FPadd_outAB_cached = FSM_instance.FPadd_outAB_cached;
//assign FPmult_outEF_cached = FSM_instance.FPmult_outEF_cached;
//assign FPinv_out = FSM_instance.FPinv_out;
//assign FP_invsqrt_out = FSM_instance.FP_invsqrt_out;

// Instantiating the DUT
// Make sure the module and signal names match with those in your design
FSM FSM_instance (

	// inputs
	.CLK(CLK),
	.RESET(RESET),
	.FSM_START,
//	.datafile(regfile),
	.DATA1in,
	.DATA2in,
	.DATA3in,
	.DATA4in,
	.DATA5in,
	.DATA6in,
	.PLANET_NUM,
	.G,
	
	// outputs
	.clear_accs,
	.FSM_DONE,
	.FSM_re,
	.FSM_we,
	.ADDR1,
	.ADDR2,
	.ADDR3,
	.ADDR4,
	.ADDR5,
	.ADDR6,
	.DATA1,
	.DATA2,
	.DATA3,
	.DATA4,
	.DATA5,
	.DATA6
	
);

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 CLK = ~CLK;
end

initial begin: CLOCK_INITIALIZATION
	CLK = 0;
end 


always_comb begin

	DATA1in

	// FSM read enable
	if (FSM_re == 2'd1) begin

		DATA1in <= regfile[ADDR1];
		DATA2in <= regfile[ADDR2];
		DATA3in <= regfile[ADDR3];

	end
	else if (FSM_re == 2'd2) begin

		DATA4in <= regfile[ADDR4];
		DATA5in <= regfile[ADDR5];
		DATA6in <= regfile[ADDR6];
		
	end
	else if (FSM_re == 2'd3) begin

		DATA1in <= regfile[ADDR1];
		DATA2in <= regfile[ADDR2];
		DATA3in <= regfile[ADDR3];

		DATA4in <= regfile[ADDR4];
		DATA5in <= regfile[ADDR5];
		DATA6in <= regfile[ADDR6];

	end


end




// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
RESET = 1;
FSM_START = 0;

//for (integer i = 0; i < 113; i += 1) begin
//	datafile[i] = 32'b0;
//end

#10
RESET = 0;

// G constant
regfile[OFFSET_G] = 32'h40800000; // float(4)
G = 32'h40800000; // float(4)

// number of planets
regfile[OFFSET_NUM] = 32'd2; // int(2)
PLANET_NUM = 32'd2; // int(2)

// Planet 1
regfile[OFFSET_RAD + 1] = 32'h3f800000; // 1
regfile[OFFSET_MASS + 1] = 32'h3f800000; // 1
regfile[OFFSET_POS_X + 1] = 32'h3f800000; // 1
regfile[OFFSET_POS_Y + 1] = 32'h0; // 0 
regfile[OFFSET_POS_Z + 1] = 32'h0; // 0
regfile[OFFSET_VEL_X + 1] = 32'h0; // 0
regfile[OFFSET_VEL_Y + 1] = 32'h3f800000; // 1 
regfile[OFFSET_VEL_Z + 1] = 32'h0; // 0 
regfile[OFFSET_ACC_X + 1] = 32'h0; // 0
regfile[OFFSET_ACC_Y + 1] = 32'h0; // 0 
regfile[OFFSET_ACC_Z + 1] = 32'h3f800000; // 1

// Planet 2
regfile[OFFSET_RAD + 2] = 32'h3f800000; // 1 
regfile[OFFSET_MASS + 2] = 32'h3f800000; // 1
regfile[OFFSET_POS_X + 2] = 32'hbf800000; // -1
regfile[OFFSET_POS_Y + 2] = 32'h0; // 0 
regfile[OFFSET_POS_Z + 2] = 32'h0; // 0
regfile[OFFSET_VEL_X + 2] = 32'h0; // 0
regfile[OFFSET_VEL_Y + 2] = 32'hbf800000; // -1 
regfile[OFFSET_VEL_Z + 2] = 32'h0; // 0 
regfile[OFFSET_ACC_X + 2] = 32'h0; // 0
regfile[OFFSET_ACC_Y + 2] = 32'h0; // 0 
regfile[OFFSET_ACC_Z + 2] = 32'hbf800000; // -1 

#10
// start
FSM_START = 1;
















end

endmodule
