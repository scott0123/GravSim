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
	output logic [1:0] FSM_we,
	output logic [31:0] ADDR1, ADDR2, ADDR3,
	output logic [31:0] DATA1, DATA2, DATA3
	
);

// declare constants here
const int OFFSET_G = 0;

const int OFFSET_NUM = 1;

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

const int DT = 32'h3c888889; // 1/60 in single precision float

// declare internal state counters here
logic [2:0] state_counter;

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

// planet counters
logic [3:0] iterator_i;
logic [3:0] iterator_j;

// adders for generating R2
logic [31:0] FPadd_opA;
logic [31:0] FPadd_opB;
logic [31:0] FPadd_outAB;
logic [31:0] FPadd_opC;
logic [31:0] FPadd_opD;
logic [31:0] FPadd_outCD;
logic [31:0] FPadd_opE;
logic [31:0] FPadd_opF;
logic [31:0] FPadd_outEF;

// next state holders for module outputs


// cache objects containing delta_x, delta_y, delta_z & the fractional components
logic [31:0] dir_x;
logic [31:0] dir_y;
logic [31:0] dir_z;

logic [31:0] acc_mag_i;
logic [31:0] acc_mag_j;

// 
enum logic [5:0] {
					WAIT,
					DONE,
					
					ClearAcc,
					GetForce,
					ApplyForce,
					ResolveForce_CalcVel_1,
					ResolveForce_CalcVel_2,
					ResolveForce_CalcPos_1,
					ResolveForce_CalcPos_2
					
					// intermediate states here
					
					
					
					}   state, next_state;   // Internal state logic


always_ff @(posedge CLK) begin

	if (RESET) begin
	
		state <= WAIT;
		state_counter <= 3'b0;
		
	end
	
	else begin
	
		state <= next_state;
		
		state_counter <= state_counter_next;
		
		if (state == GetAcc_2) begin
			dir_x <= FPadd_outAB;
			dir_y <= FPadd_outCD;
			dir_z <= FPadd_outEF;
		end
		
		if (state == GetAcc_4) begin
			acc_mag_i <= FPmult_outCD;
			acc_mag_j <= FPmult_outGH;
		end
		
		if (state == GetAcc_5) begin
			dir_x <= FPmult_outAB;
			dir_y <= FPmult_outCD;
			dir_z <= FPmult_outEF;
		end
		
		
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
	DATA1 = 32'b0;
	DATA2 = 32'b0;
	DATA3 = 32'b0;

	clear_accs = 0;
	state_counter_next = 0;
	
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
					next_state = RETRIEVE_PLANET_DATA;
			end
			
		
		
		// Calculation states
		
		
		// getting acceleration instead of force so that we don't have to divide by mass afterwards
		GetAcc:
			begin
				
			end
		
		
		
		
		
		
		
		
		
		ClearAcc:
			begin
				
			end
		
		GetForce:
			begin
				
			end
		
		ApplyForce:
			begin
				
			end
		
		ResolveForce_CalcVel_1:
			begin
				next_state = ResolveForce_CalcVel_2;
			end
			
		ResolveForce_CalcVel_2:
			begin
				next_state = ResolveForce_CalcPos_1;
			end

		
		ResolveForce_CalcPos_1:
			begin
				next_state = ResolveForce_CalcPos_2;
			end
		
		ResolveForce_CalcPos_2:
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
				clear_accs = 1;
			end
		

		
		GetAcc_1:
			begin
				
				// generates delta_x, delta_y, delta_z (Planet_B - Planet_A)
				FPadd_opA = datafile[OFFSET_POS_X + iterator_i] ^ 32'h80000000; // flips sign bit
				FPadd_opB = datafile[OFFSET_POS_X + iterator_j];
				FPadd_opC = datafile[OFFSET_POS_Y + iterator_i] ^ 32'h80000000; // flips sign bit
				FPadd_opD = datafile[OFFSET_POS_Y + iterator_j];
				FPadd_opE = datafile[OFFSET_POS_Z + iterator_i] ^ 32'h80000000; // flips sign bit
				FPadd_opF = datafile[OFFSET_POS_Z + iterator_j];
				
			end
	
		GetAcc_2:
			begin
				
				// multiply to square the delta values
				FPmult_opA = FPadd_outAB;
				FPmult_opB = FPadd_outAB;
				FPmult_opC = FPadd_outCD;
				FPmult_opD = FPadd_outCD;
				FPmult_opE = FPadd_outEF;
				FPmult_opF = FPadd_outEF;
				
				// add previous three addition results (Part 1)
				FPadd_opA = FPmult_outAB;
				FPadd_opB = FPmult_outCD;
				
			end
	
		GetAcc_3:
			begin
				
				// add previous three addition results (Part 2)
				FPadd_opA = FPadd_outAB;
				FPadd_opB = FPmult_outEF;
				
			end
		
		// now we have R2
		GetAcc_4:
			begin
							
				if (state_counter < 3'd5)
					state_counter_next = state_counter + 1;
				
				// generate 1/sqrt(R2)
				FPinvsqrt_op = FPadd_outAB;
				
				// generate 1/R2
				FPinv_op = FPadd_outAB;
				
				// G * m_j * result
				
				// G*m_j
				FPmult_opA = datafile[OFFSET_G];
				FPmult_opB = datafile[OFFSET_MASS + iterator_j];
				
				// (G*m_j) * result
				FPmult_opC = FPmult_outAB;
				FBmult_opD = FPinv_out;
				
				// G * m_i * result
				
				// G*m_i
				FPmult_opE = datafile[OFFSET_G];
				FPmult_opF = datafile[OFFSET_MASS + iterator_i];
				
				// (G*m_i) * result
				FPmult_opG = FPmult_outEF;
				FBmult_opH = FPinv_out;
				
			end
	
		// Now we have computed the acceleration magnitudes for Planets i and j
		GetAcc_5:
			begin
				
				// direction component calculations
				
				// delta_x,y,z * 1/r
				FPmult_opA = dir_x;
				FPmult_opB = FPinvsqrt_out;
				FPmult_opC = dir_y;
				FPmult_opD = FPinvsqrt_out;
				FPmult_opE = dir_z;
				FPmult_opF = FPinvsqrt_out;
								
			end
	
		ApplyAcc_1:
			begin
				
				// Planet i scale acc mag
				FPmult_opA = dir_x;
				FPmult_opB = acc_mag_i;
				FPmult_opC = dir_y;
				FPmult_opD = acc_mag_i;
				FPmult_opE = dir_z;
				FPmult_opF = acc_mag_i;
				
				// Planet j scale acc mag
				FPmult_opG = dir_x;
				FPmult_opH = acc_mag_j ^ 32'h80000000; // negative for Planet j
				FPmult_opI = dir_y;
				FPmult_opJ = acc_mag_j ^ 32'h80000000; // negative for Planet j
				FPmult_opK = dir_z;
				FPmult_opL = acc_mag_j ^ 32'h80000000; // negative for Planet j
				
				// compute data to output this acceleration value for Planet i
				FPadd_opA = datafile[OFFSET_ACC_X + iterator_i];
				FPadd_opB = FPmult_outAB;
				FPadd_opC = datafile[OFFSET_ACC_Y + iterator_i];
				FPadd_opD = FPmult_outCD;
				FPadd_opE = datafile[OFFSET_ACC_Z + iterator_i];
				FPadd_opF = FPmult_outEF;
				
				// compute data to output this acceleration value for Planet i
				FPadd_opG = datafile[OFFSET_ACC_X + iterator_j];
				FPadd_opH = FPmult_outGH;
				FPadd_opI = datafile[OFFSET_ACC_Y + iterator_j];
				FPadd_opJ = FPmult_outIJ;
				FPadd_opK = datafile[OFFSET_ACC_Z + iterator_j];
				FPadd_opL = FPmult_outKL;
				
			end
				
		ApplyAcc_2:
			begin
				
				// set ADDR for Planet i acceleration updates
				ADDR1 = OFFSET_ACC_X + iterator_i;
				ADDR2 = OFFSET_ACC_Y + iterator_i;
				ADDR3 = OFFSET_ACC_Z + iterator_i;
				
				// set DATA output for Planet i acceleration updates
				DATA1 = FPadd_outAB;
				DATA2 = FPadd_outCD;
				DATA3 = FPadd_outEF;
				
				// set ADDR for Planet j acceleration updates
				ADDR4 = OFFSET_ACC_X + iterator_j;
				ADDR5 = OFFSET_ACC_Y + iterator_j;
				ADDR6 = OFFSET_ACC_Z + iterator_j;
				
				// set DATA output for Planet j acceleration updates
				DATA4 = FPadd_outGH;
				DATA5 = FPadd_outIJ;
				DATA6 = FPadd_outKL;
				
				FSM_we = 2'd3; // write to all 6 ADDRs
				
			end
	
	
	
	
		ClearAcc:
			begin
				
			end
		
		GetForce:
			begin
				
			end
		
		ApplyForce:
			begin
				
			end
		
		ResolveForce_CalcVel_1:
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
								
			end
			
		ResolveForce_CalcVel_2:
			begin
				
				ADDR1 = OFFSET_VEL_X+1;
				ADDR2 = OFFSET_VEL_Y+1;
				ADDR3 = OFFSET_VEL_Z+1;
				
				DATA1 = FPaddX_out;
				DATA2 = FPaddY_out;
				DATA3 = FPaddZ_out;
				
				FSM_we = 1;
				
			end
		
		ResolveForce_CalcPos_1:
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
				
			end
		
		ResolveForce_CalcPos_2:
			begin
			
				ADDR1 = OFFSET_POS_X+1;
				ADDR2 = OFFSET_POS_Y+1;
				ADDR3 = OFFSET_POS_Z+1;
				
				DATA1 = FPaddX_out;
				DATA2 = FPaddY_out;
				DATA3 = FPaddZ_out;
				
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
