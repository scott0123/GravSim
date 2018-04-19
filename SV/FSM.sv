/************************************************************************
FSM for GravSim
Final Project
Anish Bhattacharya | Scott Liu

//

This handles the entire FSM, calculating and applying all forces for a
timestep.

Data input is a large regfile (logic) of 32-bit words.

************************************************************************/

module FSM (

	input	 logic CLK,
	input  logic RESET,
	input  logic FSM_START,
	output logic FSM_DONE,
	input  logic [31:0] datafile [113],
	
	// added outputs
	output logic FSM_we,
	output logic [31:0] ADDR1, ADDR2, ADDR3,
	output logic [31:0] data1, data2, data3
	
	
	
);

// declare constants here
const int OFFSET_NUM = 0;

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

const int DT = 32'h3c888889; // 1/60 in single precision float

// declare internal state counters here



// declare internal data here
logic updateV;
logic updateP;
logic [31:0] FPaddX_opA;
logic [31:0] FPaddX_opB;
logic [31:0] FPaddY_opA;
logic [31:0] FPaddY_opB;
logic [31:0] FPaddZ_opA;
logic [31:0] FPaddZ_opB;
logic [31:0] FPmultX_opA;
logic [31:0] FPmultX_opB;
logic [31:0] FPmultY_opA;
logic [31:0] FPmultY_opB;
logic [31:0] FPmultZ_opA;
logic [31:0] FPmultZ_opB;

logic [31:0] FPaddX_out;
logic [31:0] FPaddY_out;
logic [31:0] FPaddZ_out;
logic [31:0] FPmultX_out;
logic [31:0] FPmultY_out;
logic [31:0] FPmultZ_out;

// next state holders for module outputs



// 
enum logic [5:0] {
					WAIT,
					DONE,
					
					ClearAcc,
					GetForce,
					ApplyForce,
					ResolveForce_CalcVel,
					ResolveForce_CalcPos
					
					// intermediate states here
					
					
					
					}   state, next_state;   // Internal state logic


always_ff @(posedge CLK) begin

	if (RESET) begin
		state <= WAIT;
		
	end
	
	else begin
	
		state <= next_state;
		
//		if (updateV) begin
//			datafile[OFFSET_VEL_X+1] <= FPaddX_out;
//			datafile[OFFSET_VEL_Y+1] <= FPaddY_out;
//			datafile[OFFSET_VEL_Z+1] <= FPaddZ_out;
			
//		end
		
//		if (updateP) begin
//			datafile[OFFSET_POS_X+1] <= FPaddX_out;
//			datafile[OFFSET_POS_Y+1] <= FPaddY_out;
//			datafile[OFFSET_POS_Z+1] <= FPaddZ_out;
//		end
		
	end

end



always_comb begin

	// defaults
	FSM_DONE = 0;
	FSM_we = 0;
	updateV = 0;
	updateP = 0;
	next_state = state;
	FPaddX_opA = 32'b0;
	FPaddX_opB = 32'b0;
	FPaddY_opA = 32'b0;
	FPaddY_opB = 32'b0;
	FPaddZ_opA = 32'b0;
	FPaddZ_opB = 32'b0;
	FPmultX_opA = 32'b0;
	FPmultX_opB = 32'b0;
	FPmultY_opA = 32'b0;
	FPmultY_opB = 32'b0;
	FPmultZ_opA = 32'b0;
	FPmultZ_opB = 32'b0;
	ADDR1 = 32'b0;
	ADDR2 = 32'b0;
	ADDR3 = 32'b0;
	data1 = 32'b0;
	data2 = 32'b0;
	data3 = 32'b0;

	// ------------------------------------------------------------- //
	
	//									BEGIN NEXT_STATE DEFS
	
	// ------------------------------------------------------------- //
	
	// determine next_state from state
	unique case(state)
	
		// 2 general SM states
		DONE:
			begin
				if (FSM_START == 0)
					next_state = WAIT;
			end
		
		WAIT:
			begin
				if (FSM_START == 1)
					next_state = ResolveForce_CalcVel;
			end
			
		
		
		// Calculation states
		
		ClearAcc:
			begin
				
			end
		
		GetForce:
			begin
				
			end
		
		ApplyForce:
			begin
				
			end
		
		ResolveForce_CalcVel:
			begin
				next_state = ResolveForce_CalcPos;
			end
		
		ResolveForce_CalcPos:
			begin
				next_state = DONE;
			end
		
		
		
		default: ;
		
	
	endcase
	
	
	
	// ------------------------------------------------------------- //
	
	//									BEGIN OPERATION DEFS
	
	// ------------------------------------------------------------- //
	
	
	// define operations of each state
	case(state)
	
		// General FSM states
	
		DONE:
			begin
				FSM_DONE = 1;
			end
		
		WAIT:
			begin
				FSM_DONE = 0;
			end
	
		// Calculation states
	
		ClearAcc:
			begin
				
			end
		
		GetForce:
			begin
				
			end
		
		ApplyForce:
			begin
				
			end
		
		ResolveForce_CalcVel:
			begin
			
				// multiply DT * new_ACC
				FPmultX_opA = datafile[OFFSET_ACC_X+1];
				FPmultX_opB = DT;
				
				FPmultY_opA = datafile[OFFSET_ACC_Y+1];
				FPmultY_opB = DT;
				
				FPmultZ_opA = datafile[OFFSET_ACC_Z+1];
				FPmultZ_opB = DT;
				
				// add new_VEL = old_VEL + DVEL
				FPaddX_opA = FPmultX_out;
				FPaddX_opB = datafile[OFFSET_VEL_X+1];
				
				FPaddY_opA = FPmultY_out;
				FPaddY_opB = datafile[OFFSET_VEL_Y+1];
				
				FPaddZ_opA = FPmultZ_out;
				FPaddZ_opB = datafile[OFFSET_VEL_Z+1];
				
				ADDR1 = OFFSET_VEL_X+1;
				ADDR2 = OFFSET_VEL_Y+1;
				ADDR3 = OFFSET_VEL_Z+1;
				
				data1 = FPaddX_out;
				data2 = FPaddY_out;
				data3 = FPaddZ_out;
				
				FSM_we = 1;
				
			end
			
			
		
		ResolveForce_CalcPos:
			begin
			
				// multiply DT * new_VEL
				FPmultX_opA = datafile[OFFSET_VEL_X+1];
				FPmultX_opB = DT;
				
				FPmultY_opA = datafile[OFFSET_VEL_Y+1];
				FPmultY_opB = DT;
				
				FPmultZ_opA = datafile[OFFSET_VEL_Z+1];
				FPmultZ_opB = DT;
				
				// add new_POS = old_POS + DPOS
				FPaddX_opA = FPmultX_out;
				FPaddX_opB = datafile[OFFSET_POS_X+1];
				
				FPaddY_opA = FPmultY_out;
				FPaddY_opB = datafile[OFFSET_POS_Y+1];
				
				FPaddZ_opA = FPmultZ_out;
				FPaddZ_opB = datafile[OFFSET_POS_Z+1];

				ADDR1 = OFFSET_POS_X+1;
				ADDR2 = OFFSET_POS_Y+1;
				ADDR3 = OFFSET_POS_Z+1;
				
				data1 = FPaddX_out;
				data2 = FPaddY_out;
				data3 = FPaddZ_out;
				
				FSM_we = 1;
				
			end
		

		
		default: ;
		
	endcase
	
	
	
end


// instantiate necessary modules

FPmult FPmultX (
	// inputs
	.iA(FPmultX_opA),
	.iB(FPmultX_opB),
	// outputs
	.oProd(FPmultX_out)
);

FPmult FPmultY (
	// inputs
	.iA(FPmultY_opA),
	.iB(FPmultY_opB),
	// outputs
	.oProd(FPmultY_out)
);

FPmult FPmultZ (
	// inputs
	.iA(FPmultZ_opA),
	.iB(FPmultZ_opB),
	// outputs
	.oProd(FPmultZ_out)
);

FPadd FPaddX (
	// inputs
	.iCLK(CLK),
	.iA(FPaddX_opA),
	.iB(FPaddX_opB),
	// outputs
	.oSum(FPaddX_out)
);

FPadd FPaddY (
	// inputs
	.iCLK(CLK),
	.iA(FPaddY_opA),
	.iB(FPaddY_opB),
	// outputs
	.oSum(FPaddY_out)
);

FPadd FPaddZ (
	// inputs
	.iCLK(CLK),
	.iA(FPaddZ_opA),
	.iB(FPaddZ_opB),
	// outputs
	.oSum(FPaddZ_out)
);

endmodule
