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

// declare internal state counters here



// declare internal data here



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
		// set internal state counters to next_state counters here
		
		regfile[OFFSET_ACC_X] <= FPmult_AccX_out;
		regfile[OFFSET_ACC_Y] <= FPmult_AccY_out;
		regfile[OFFSET_ACC_Z] <= FPmult_AccZ_out;
		
	end

end

always_comb begin

	// defaults
	next_state = state;
	msg_next_state = msg_state;
	AES_DONE = 1'b0;
	
	
	
	// determine next_state from state
	unique case(state)
	
		// 2 general SM states
		DONE:
			begin
				if (FSM_START == 1'b0)
					next_state = WAIT;
			end
		
		WAIT:
			begin
				if (FSM_START == 1'b1)
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
				AES_DONE = 1'b1;
			end
		
		WAIT:
			AES_DONE = 1'b0;
	
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
				FPmult_AccX_opA = regfile[OFFSET_ACC_X]
				FPmult_AccX_opB = regfile[OFFSET_ACC_X]
				
				FPmult_AccY_opA = regfile[OFFSET_ACC_Y]
				FPmult_AccY_opB = regfile[OFFSET_ACC_Y]
				
				FPmult_AccZ_opA = regfile[OFFSET_ACC_Z]
				FPmult_AccZ_opB = regfile[OFFSET_ACC_Z]
			end
		
		ResolveForce_CalcPos:
			begin
				
			end
		
		
		default: ;
		
	endcase
	
	
	
end


// instantiate necessary modules

FPmult FPmult_AccX (
	// inputs
	.iA(FPmult_AccX_opA),
	.iB(FPmult_AccX_opB),
	// outputs
	.oProd(FPmult_AccX_out)
);

FPmult FPmult_AccY (
	// inputs
	.iA(FPmult_AccY_opA),
	.iB(FPmult_AccY_opB),
	// outputs
	.oProd(FPmult_AccY_out)
);

FPmult FPmult_AccZ (
	// inputs
	.iA(FPmult_AccZ_opA),
	.iB(FPmult_AccZ_opB),
	// outputs
	.oProd(FPmult_AccZ_out)
);


endmodule
