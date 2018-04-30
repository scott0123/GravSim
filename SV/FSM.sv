/************************************************************************
FSM for GravSim
Final Project
Anish Bhattacharya | Scott Liu

//

This handles the entire FSM, calculating and applying all forces for a
timestep.


************************************************************************/

module FSM (

	input	 logic CLK,
	input  logic RESET,
	input  logic FSM_START,
	output logic FSM_DONE,
//	input  logic [31:0] datafile [113],
	
	input logic [3:0] PLANET_NUM,
	input logic [31:0] G,
	output logic clear_accs,
	output logic [1:0] FSM_re,
	output logic [1:0] FSM_we,
	output logic [31:0] ADDR1, ADDR2, ADDR3, ADDR4, ADDR5, ADDR6,
	output logic [31:0] DATA1, DATA2, DATA3, DATA4, DATA5, DATA6,
	input logic [31:0] DATA1in, DATA2in, DATA3in, DATA4in, DATA5in, DATA6in
	
);

//assign FSM_DONE = 1'b1;
//assign clear_accs = 1'b0;
//assign FSM_we = 2'b0;
//
//assign ADDR1 = 32'b0;
//assign ADDR2 = 32'b0;
//assign ADDR3 = 32'b0;
//assign ADDR4 = 32'b0;
//assign ADDR5 = 32'b0;
//assign ADDR6 = 32'b0;
//
//assign DATA1 = 32'b0;
//assign DATA2 = 32'b0;
//assign DATA3 = 32'b0;
//assign DATA4 = 32'b0;
//assign DATA5 = 32'b0;
//assign DATA6 = 32'b0;

// declare constants here
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

const int DT = 32'h3c888889; // 1/60 in single precision float

// declare internal state counters here
logic [2:0] state_counter;
logic [2:0] state_counter_next;

// declare internal data here
//logic updateV;
//logic updateP;
logic [31:0] FPadd_opA;
logic [31:0] FPadd_opB;
logic [31:0] FPadd_opC;
logic [31:0] FPadd_opD;
logic [31:0] FPadd_opE;
logic [31:0] FPadd_opF;
logic [31:0] FPadd_opG;
logic [31:0] FPadd_opH;
logic [31:0] FPadd_opI;
logic [31:0] FPadd_opJ;
logic [31:0] FPadd_opK;
logic [31:0] FPadd_opL;
logic [31:0] FPadd_outAB;
logic [31:0] FPadd_outCD;
logic [31:0] FPadd_outEF;
logic [31:0] FPadd_outGH;
logic [31:0] FPadd_outIJ;
logic [31:0] FPadd_outKL;

logic [31:0] FPmult_opA;
logic [31:0] FPmult_opB;
logic [31:0] FPmult_opC;
logic [31:0] FPmult_opD;
logic [31:0] FPmult_opE;
logic [31:0] FPmult_opF;
logic [31:0] FPmult_opG;
logic [31:0] FPmult_opH;
logic [31:0] FPmult_opI;
logic [31:0] FPmult_opJ;
logic [31:0] FPmult_opK;
logic [31:0] FPmult_opL;
logic [31:0] FPmult_outAB;
logic [31:0] FPmult_outCD;
logic [31:0] FPmult_outEF;
logic [31:0] FPmult_outGH;
logic [31:0] FPmult_outIJ;
logic [31:0] FPmult_outKL;

logic [31:0] FPinv_op;
logic [31:0] FPinv_out;

logic [31:0] FPinvsqrt_op;
logic [31:0] FPinvsqrt_out;

// planet counters
logic [31:0] iterator_i;
logic [31:0] iterator_j;
logic [31:0] iterator_i_next;
logic [31:0] iterator_j_next;

// next state holders for module outputs


// cache objects

//containing delta_x, delta_y, delta_z & the fractional components
logic [31:0] dir_x;
logic [31:0] dir_y;
logic [31:0] dir_z;

logic [31:0] acc_mag_i;
logic [31:0] acc_mag_j;

// misc cache objects
logic [31:0] FPadd_outAB_cached;
logic [31:0] FPmult_outEF_cached;

// 
enum logic [5:0] {
					WAIT,
					DONE,
					
					ClearAcc,
					
					GetAcc_1,
					GetAcc_2,
					GetAcc_3,
					GetAcc_4,
					GetAcc_5,
					
					ApplyAcc_1,
					ApplyAcc_2,					
					
					ResolveForce_CalcVel_1_getdata,
					ResolveForce_CalcVel_1,
					ResolveForce_CalcVel_2,
					ResolveForce_CalcPos_1_getdata,
					ResolveForce_CalcPos_1,
					ResolveForce_CalcPos_2
					
					}   state, next_state;   // Internal state logic


always_ff @(posedge CLK) begin

	if (RESET) begin
	
		state <= WAIT;
		state_counter <= 3'b0;
		
	end
	
	else begin
	
		state <= next_state;
		
		state_counter <= state_counter_next;
		
		iterator_i <= iterator_i_next;
		iterator_j <= iterator_j_next;
		
		if (state == GetAcc_2) begin
			dir_x <= FPadd_outAB; //delta_x
			dir_y <= FPadd_outCD; //delta_y
			dir_z <= FPadd_outEF; //delta_z
			
			FPmult_outEF_cached <= FPmult_outEF;
		end
		
		if (state == GetAcc_3) begin
			FPadd_outAB_cached <= FPadd_outAB;
		end
		
		if (state == GetAcc_4) begin
			acc_mag_i <= FPmult_outCD;
			acc_mag_j <= FPmult_outGH;
		end
		
		if (state == GetAcc_5) begin
			dir_x <= FPmult_outAB; //fraction of acc_mag
			dir_y <= FPmult_outCD; //fraction of acc_mag
			dir_z <= FPmult_outEF; //fraction of acc_mag
		end
		
	end

end



always_comb begin

	// defaults
	FSM_DONE = 0;
	FSM_we = 2'b0;
	FSM_re = 2'b0;
	
	next_state = state;
	iterator_i_next = iterator_i;
	iterator_j_next = iterator_j;

	FPadd_opA = 32'b0;
	FPadd_opB = 32'b0;
	FPadd_opC = 32'b0;
	FPadd_opD = 32'b0;
	FPadd_opE = 32'b0;
	FPadd_opF = 32'b0;
	FPadd_opG = 32'b0;
	FPadd_opH = 32'b0;
	FPadd_opI = 32'b0;
	FPadd_opJ = 32'b0;
	FPadd_opK = 32'b0;
	FPadd_opL = 32'b0;

	FPmult_opA = 32'b0;
	FPmult_opB = 32'b0;
	FPmult_opC = 32'b0;
	FPmult_opD = 32'b0;
	FPmult_opE = 32'b0;
	FPmult_opF = 32'b0;
	FPmult_opG = 32'b0;
	FPmult_opH = 32'b0;
	FPmult_opI = 32'b0;
	FPmult_opJ = 32'b0;
	FPmult_opK = 32'b0;
	FPmult_opL = 32'b0;
	
	FPinv_op = 32'b0;
	
	FPinvsqrt_op = 32'b0;
	
	ADDR1 = 32'b0;
	ADDR2 = 32'b0;
	ADDR3 = 32'b0;
	ADDR4 = 32'b0;
	ADDR5 = 32'b0;
	ADDR6 = 32'b0;
	
	DATA1 = 32'b0;
	DATA2 = 32'b0;
	DATA3 = 32'b0;
	DATA4 = 32'b0;
	DATA5 = 32'b0;
	DATA6 = 32'b0;

	clear_accs = 0;
	state_counter_next = 3'b0;
	
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
				if (FSM_START == 1) begin
					next_state = ClearAcc;
					iterator_i_next = 32'b0;
					iterator_j_next = 32'b1;
				end
			end
		
		ClearAcc:
			begin
				next_state = GetAcc_1;
			end
		
		// Calculation states
		
		// getting acceleration instead of force so that we don't have to divide by mass afterwards
		GetAcc_1:
			begin
				next_state = GetAcc_2;
			end
		
		GetAcc_2:
			begin
				next_state = GetAcc_3;
			end
		
		GetAcc_3:
			begin
				next_state = GetAcc_4;
			end
		
		GetAcc_4:
			begin
				if (state_counter > 3'd4)
					next_state = GetAcc_5;
			end
		
		GetAcc_5:
			begin
				next_state = ApplyAcc_1;
			end
		
		ApplyAcc_1:
			begin
				next_state = ApplyAcc_2;
			end
		
		ApplyAcc_2:
			begin
				
				if (iterator_i == PLANET_NUM - 32'd2 && iterator_j == PLANET_NUM - 32'd1) begin
					iterator_i_next = 32'b0;
					next_state = ResolveForce_CalcVel_1;
				end
				else begin
					if (iterator_j == PLANET_NUM - 32'd1) begin
						iterator_i_next = iterator_i + 32'd1;
						iterator_j_next = iterator_i + 32'd2;
					end
					else begin
						iterator_j_next = iterator_j + 32'd1;
					end
					next_state = GetAcc_1;
				end
			end
		
		ResolveForce_CalcVel_1_getdata:
			begin
				next_state = ResolveForce_CalcVel_1;
			end
		
		ResolveForce_CalcVel_1:
			begin
				next_state = ResolveForce_CalcVel_2;
			end
			
		ResolveForce_CalcVel_2:
			begin
				next_state = ResolveForce_CalcPos_1;
			end
		
		ResolveForce_CalcPos_1_getdata:
			begin
				next_state = ResolveForce_CalcPos_1;
			end
		
		ResolveForce_CalcPos_1:
			begin
				next_state = ResolveForce_CalcPos_2;
			end
		
		ResolveForce_CalcPos_2:
			begin
			
				if (iterator_i == PLANET_NUM - 32'd1) begin
					next_state = DONE;
				end
				else begin
					iterator_i_next = iterator_i + 32'b1;
					next_state = ResolveForce_CalcVel_1;
				end
			
			end
		
		
		
		default: ;
		
	
	endcase
	
	
	
	// ------------------------------------------------------------- //
	
	//								BEGIN OPERATION DEFS
	
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
				
				// prepare for next state
				ADDR1 = OFFSET_POS_X + iterator_i + 32'b1;
				ADDR2 = OFFSET_POS_X + iterator_j + 32'b1;
				ADDR3 = OFFSET_POS_Y + iterator_i + 32'b1;
				ADDR4 = OFFSET_POS_Y + iterator_j + 32'b1;
				ADDR5 = OFFSET_POS_Z + iterator_i + 32'b1;
				ADDR6 = OFFSET_POS_Z + iterator_j + 32'b1;
				
				FSM_re = 2'd3;
				
			end
		
		// Get Acceleration
		
		GetAcc_1:
			begin
				
				// generates delta_x, delta_y, delta_z (Planet_B - Planet_A)
				FPadd_opA = DATA1in ^ 32'h80000000; // flips sign bit
				FPadd_opB = DATA2in;
				FPadd_opC = DATA3in ^ 32'h80000000; // flips sign bit
				FPadd_opD = DATA4in;
				FPadd_opE = DATA5in ^ 32'h80000000; // flips sign bit
				FPadd_opF = DATA6in;
				
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
				FPadd_opB = FPmult_outEF_cached;
				
				// prepare for next state
				ADDR1 = OFFSET_MASS + iterator_j + 32'b1;
				ADDR2 = OFFSET_MASS + iterator_i + 32'b1;
				
				FSM_re = 2'b1;
				
			end
		
		// now we have R2
		GetAcc_4:
			begin
							
				if (state_counter < 3'd5)
					state_counter_next = state_counter + 3'b1;
				
				// generate 1/sqrt(R2)
				FPinvsqrt_op = FPadd_outAB_cached;
				
				// generate 1/R2
				FPinv_op = FPadd_outAB_cached;
				
				// G * m_j * result
				
				// G*m_j
				FPmult_opA = G;
				FPmult_opB = DATA1in;
				
				// (G*m_j) * result
				FPmult_opC = FPmult_outAB;
				FPmult_opD = FPinv_out;
				
				// G * m_i * result
				
				// G*m_i
				FPmult_opE = G;
				FPmult_opF = DATA2in;
				
				// (G*m_i) * result
				FPmult_opG = FPmult_outEF;
				FPmult_opH = FPinv_out;
				
			end
	
		// Now we have computed the acceleration magnitudes for Planets i and j
		GetAcc_5:
			begin
				
				state_counter_next = 3'b0;
				
				// direction component calculations
				
				// delta_x,y,z * 1/r
				FPmult_opA = dir_x;
				FPmult_opB = FPinvsqrt_out;
				FPmult_opC = dir_y;
				FPmult_opD = FPinvsqrt_out;
				FPmult_opE = dir_z;
				FPmult_opF = FPinvsqrt_out;
				
				// prepare for next state
				ADDR1 = OFFSET_ACC_X + iterator_i + 32'b1;
				ADDR2 = OFFSET_ACC_Y + iterator_i + 32'b1;
				ADDR3 = OFFSET_ACC_Z + iterator_i + 32'b1;
				ADDR4 = OFFSET_ACC_X + iterator_j + 32'b1;
				ADDR5 = OFFSET_ACC_Y + iterator_j + 32'b1;
				ADDR6 = OFFSET_ACC_Z + iterator_j + 32'b1;
				
				FSM_re = 2'd3;
				
			end
		
		// Apply Acceleration
		
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
				FPadd_opA = DATA1in;
				FPadd_opB = FPmult_outAB;
				FPadd_opC = DATA2in;
				FPadd_opD = FPmult_outCD;
				FPadd_opE = DATA3in;
				FPadd_opF = FPmult_outEF;
				
				// compute data to output this acceleration value for Planet j
				FPadd_opG = DATA4in;
				FPadd_opH = FPmult_outGH;
				FPadd_opI = DATA5in;
				FPadd_opJ = FPmult_outIJ;
				FPadd_opK = DATA6in;
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
				ADDR4 = OFFSET_ACC_X + iterator_j + 32'b1;
				ADDR5 = OFFSET_ACC_Y + iterator_j + 32'b1;
				ADDR6 = OFFSET_ACC_Z + iterator_j + 32'b1;
				
				// set DATA output for Planet j acceleration updates
				DATA4 = FPadd_outGH;
				DATA5 = FPadd_outIJ;
				DATA6 = FPadd_outKL;
				
				FSM_we = 2'd3; // write to all 6 ADDRs
				
			end
		
		// Resolve Force
		
		ResolveForce_CalcVel_1_getdata:
			begin
				
				ADDR1 = OFFSET_ACC_X + iterator_i + 32'b1;
				ADDR2 = OFFSET_ACC_Y + iterator_i + 32'b1;
				ADDR3 = OFFSET_ACC_Z + iterator_i + 32'b1;
				ADDR4 = OFFSET_VEL_X + iterator_i + 32'b1;
				ADDR5 = OFFSET_VEL_Y + iterator_i + 32'b1;
				ADDR6 = OFFSET_VEL_Z + iterator_i + 32'b1;
				
				FSM_re = 2'd3;
				
			end
		
		ResolveForce_CalcVel_1:
			begin
			
				// multiply DT * new_ACC
				FPmult_opA = DATA1in;
				FPmult_opB = DT;
				
				FPmult_opC = DATA2in;
				FPmult_opD = DT;
				
				FPmult_opE = DATA3in;
				FPmult_opF = DT;
				
				// add new_VEL = old_VEL + DVEL
				FPadd_opA = FPmult_outAB;
				FPadd_opB = DATA4in;
				
				FPadd_opC = FPmult_outCD;
				FPadd_opD = DATA5in;
				
				FPadd_opE = FPmult_outEF;
				FPadd_opF = DATA6in;
				
			end
			
		ResolveForce_CalcVel_2:
			begin
				
				ADDR1 = OFFSET_VEL_X + iterator_i + 32'b1;
				ADDR2 = OFFSET_VEL_Y + iterator_i + 32'b1;
				ADDR3 = OFFSET_VEL_Z + iterator_i + 32'b1;
				
				DATA1 = FPadd_outAB;
				DATA2 = FPadd_outCD;
				DATA3 = FPadd_outEF;
				
				FSM_we = 2'd1;
				
			end
		
		ResolveForce_CalcPos_1_getdata:
			begin
				
				ADDR1 = OFFSET_VEL_X + iterator_i + 32'b1;
				ADDR2 = OFFSET_VEL_Y + iterator_i + 32'b1;
				ADDR3 = OFFSET_VEL_Z + iterator_i + 32'b1;
				ADDR4 = OFFSET_POS_X + iterator_i + 32'b1;
				ADDR5 = OFFSET_POS_Y + iterator_i + 32'b1;
				ADDR6 = OFFSET_POS_Z + iterator_i + 32'b1;
				
				FSM_re = 2'd3;
				
			end
		
		ResolveForce_CalcPos_1:
			begin
				
				// multiply DT * new_VEL
				FPmult_opA = DATA1in;
				FPmult_opB = DT;
				
				FPmult_opC = DATA2in;
				FPmult_opD = DT;
				
				FPmult_opE = DATA3in;
				FPmult_opF = DT;
				
				// add new_POS = old_POS + DVEL
				FPadd_opA = FPmult_outAB;
				FPadd_opB = DATA4in;
				
				FPadd_opC = FPmult_outCD;
				FPadd_opD = DATA5in;
				
				FPadd_opE = FPmult_outEF;
				FPadd_opF = DATA6in;

			end
		
		ResolveForce_CalcPos_2:
			begin
			
				ADDR1 = OFFSET_POS_X + iterator_i + 32'b1;
				ADDR2 = OFFSET_POS_Y + iterator_i + 32'b1;
				ADDR3 = OFFSET_POS_Z + iterator_i + 32'b1;
				
				DATA1 = FPadd_outAB;
				DATA2 = FPadd_outCD;
				DATA3 = FPadd_outEF;
				
				FSM_we = 2'd1;
				
			end

		
		
		default: ;
		
	endcase
	
	
	
end


	// ------------------------------------------------------------- //
	
	//							INSTANTIATE NECESSARY MODULES
	
	// ------------------------------------------------------------- //

// FP Multipliers

FPmult FPmult_AB (
	// inputs
	.iA(FPmult_opA),
	.iB(FPmult_opB),
	// outputs
	.oProd(FPmult_outAB)
);

FPmult FPmult_CD (
	// inputs
	.iA(FPmult_opC),
	.iB(FPmult_opD),
	// outputs
	.oProd(FPmult_outCD)
);

FPmult FPmult_EF (
	// inputs
	.iA(FPmult_opE),
	.iB(FPmult_opF),
	// outputs
	.oProd(FPmult_outEF)
);

FPmult FPmult_GH (
	// inputs
	.iA(FPmult_opG),
	.iB(FPmult_opH),
	// outputs
	.oProd(FPmult_outGH)
);

FPmult FPmult_IJ (
	// inputs
	.iA(FPmult_opI),
	.iB(FPmult_opJ),
	// outputs
	.oProd(FPmult_outIJ)
);

FPmult FPmult_KL (
	// inputs
	.iA(FPmult_opK),
	.iB(FPmult_opL),
	// outputs
	.oProd(FPmult_outKL)
);


// FP Adders
FPadd FPadd_AB (
	// inputs
	.iCLK(CLK),
	.iA(FPadd_opA),
	.iB(FPadd_opB),
	// outputs
	.oSum(FPadd_outAB)
);

// FP Adders
FPadd FPadd_CD (
	// inputs
	.iCLK(CLK),
	.iA(FPadd_opC),
	.iB(FPadd_opD),
	// outputs
	.oSum(FPadd_outCD)
);

// FP Adders
FPadd FPadd_EF (
	// inputs
	.iCLK(CLK),
	.iA(FPadd_opE),
	.iB(FPadd_opF),
	// outputs
	.oSum(FPadd_outEF)
);

// FP Adders
FPadd FPadd_GH (
	// inputs
	.iCLK(CLK),
	.iA(FPadd_opG),
	.iB(FPadd_opH),
	// outputs
	.oSum(FPadd_outGH)
);

// FP Adders
FPadd FPadd_IJ (
	// inputs
	.iCLK(CLK),
	.iA(FPadd_opI),
	.iB(FPadd_opJ),
	// outputs
	.oSum(FPadd_outIJ)
);

// FP Adders
FPadd FPadd_KL (
	// inputs
	.iCLK(CLK),
	.iA(FPadd_opK),
	.iB(FPadd_opL),
	// outputs
	.oSum(FPadd_outKL)
);


FPinv FPinv_A (
	// inputs
	.iCLK(CLK),
	.in(FPinv_op),
	// outputs
	.out(FPinv_out)
);

FPinvsqrt FPinvsqrt_A (
	// inputs
	.iCLK(CLK),
	.iA(FPinvsqrt_op),
	// outputs
	.oInvsqrt(FPinvsqrt_out)
);

endmodule
