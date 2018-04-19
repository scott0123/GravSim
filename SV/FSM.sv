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
	input  logic [31:0] datafile [93]
	
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


// next state holders for module outputs



// 
enum logic [5:0] {
					WAIT,
					DONE,
					
//					ClearAcc,
//					GetForce,
//					ApplyForce,
					ResolveForce_CalcVel
					ResolveForce_CalcPos
					
					// intermediate states here
					
					
					
					}   state, next_state;   // Internal state logic


always_ff @(posedge CLK) begin

	if (RESET) begin
		state <= WAIT;
		// reset internal state counters here
		
		
		
	end
	else begin
	
		state <= next_state;
		
		if (updateV) begin
			datafile[OFFSET_VEL_X+1] <= FPaddX_out;
			datafile[OFFSET_VEL_Y+1] <= FPaddY_out;
			datafile[OFFSET_VEL_Z+1] <= FPaddZ_out;
		end
		
		if (updateP) begin
			datafile[OFFSET_POS_X+1] <= FPaddX_out;
			datafile[OFFSET_POS_Y+1] <= FPaddY_out;
			datafile[OFFSET_POS_Z+1] <= FPaddZ_out;
		end
		
	end

end

always_comb begin

	// defaults
	FSM_DONE = 0;
	updateV = 0;
	updateP = 0;
	
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
		
		ResolveForce_CalcVel_mult:
			begin
			
				// multiply DT * new_ACC
				FPmultX_opA = datafile[OFFSET_ACC_X+1];
				FPmultX_opB = DT;
				
				FPmultY_opA = datafile[OFFSET_ACC_Y+1];
				FPmultY_opB = DT;
				
				FPmultZ_opA = datafile[OFFSET_ACC_Z+1];
				FPmultZ_opB = DT;
				
				// add new_VEL = old_VEL + DVEL
				FPadd_opA = FPmultX_out;
				FPadd_opB = datafile[OFFSET_VEL_X+1];
				
				FPadd_opA = FPmultY_out;
				FPadd_opB = datafile[OFFSET_VEL_Y+1];
				
				FPadd_opA = FPmultZ_out;
				FPadd_opB = datafile[OFFSET_VEL_Z+1];

				updateV = 1;
				
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
				FPadd_opA = FPmultX_out;
				FPadd_opB = datafile[OFFSET_POS_X+1];
				
				FPadd_opA = FPmultY_out;
				FPadd_opB = datafile[OFFSET_POS_Y+1];
				
				FPadd_opA = FPmultZ_out;
				FPadd_opB = datafile[OFFSET_POS_Z+1];

				updateP = 1;
				
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
