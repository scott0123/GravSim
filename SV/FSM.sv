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



// declare internal state counters here



// declare internal data here



// next state holders for module outputs



// 
enum logic [5:0] {
					WAIT,
					DONE,
					
					ClearAcc,
					GetForce,
					ApplyForce,
					ResolveForce
					
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
					next_state = ClearAcc;
			end
			
		
		
		// Calculation states
		
		ClearAcc:
			begin
			
				
			
			end
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		// Decryption SM states
		KExp:
			begin
//				next_state = DONE;
				if (KExp_counter > 7'd12) // might have to test other values
					next_state = ARK0;
			end
		
		// comment out here for debug purposes
		
		
		ARK0:
			next_state = ISR1;
		
		
		
		ISR1:
			next_state = ISB1;
		
		ISB1:
			next_state = ARK1;
			
		ARK1:
			next_state = IMC1;

		IMC1:
			begin
				if (IMC_counter > 3'd3)
					next_state = ISR2;
			end
		
		
		ISR2:
			next_state = ISB2;
		
		ISB2:
			next_state = ARK2;
			
		ARK2:
			next_state = IMC2;
		
		IMC2:
			begin
				if (IMC_counter > 3'd3)
					next_state = ISR3;
			end
		
		
		ISR3:
			next_state = ISB3;
		
		ISB3:
			next_state = ARK3;
			
		ARK3:
			next_state = IMC3;
		
		IMC3:
			begin
				if (IMC_counter > 3'd3)
					next_state = ISR4;
			end
		
		
		
		ISR4:
			next_state = ISB4;
		
		ISB4:
			next_state = ARK4;
			
		ARK4:
			next_state = IMC4;
		
		IMC4:
			begin
				if (IMC_counter > 3'd3)
					next_state = ISR5;
			end
		
		
		
		ISR5:
			next_state = ISB5;
		
		ISB5:
			next_state = ARK5;
			
		ARK5:
			next_state = IMC5;
		
		IMC5:
			begin
				if (IMC_counter > 3'd3)
					next_state = ISR6;
			end
		
		
		
		ISR6:
			next_state = ISB6;
		
		ISB6:
			next_state = ARK6;
			
		ARK6:
			next_state = IMC6;
		
		IMC6:
			begin
				if (IMC_counter > 3'd3)
					next_state = ISR7;
			end
		
		
		
		ISR7:
			next_state = ISB7;
		
		ISB7:
			next_state = ARK7;
			
		ARK7:
			next_state = IMC7;
		
		IMC7:
			begin
				if (IMC_counter > 3'd3)
					next_state = ISR8;
			end
		
		
		
		ISR8:
			next_state = ISB8;
		
		ISB8:
			next_state = ARK8;
			
		ARK8:
			next_state = IMC8;
		
		IMC8:
			begin
				if (IMC_counter > 3'd3)
					next_state = ISR9;
			end
		
		
		
		ISR9:
			next_state = ISB9;
		
		ISB9:
			next_state = ARK9;
			
		ARK9:
			next_state = IMC9;
		
		IMC9:
			begin
				if (IMC_counter > 3'd3)
					next_state = ISR10;
			end
			
		
		
		ISR10:
			next_state = ISB10;
		
		ISB10:
			next_state = ARK10;
		
		ARK10:
			next_state = DONE;
		
		
		
		default: ;
		
	
	endcase
	
	
	
	// ------------------------------------------------------------- //
	
	//									BEGIN OPERATION DEFS
	
	// ------------------------------------------------------------- //
	
	
	
	
	// define operations of each state
	case(state)
	
		DONE:
			begin
				AES_DONE = 1'b1;
			end
		
		WAIT:
			AES_DONE = 1'b0;
		
		// Decryption SM states
		KExp:
			begin
				if (KExp_counter < 7'd13) // might have to test other values
					KExp_counter_next = KExp_counter + 7'b1;
				if (KExp_counter == 7'b0)
					msg_next_state = AES_MSG_ENC;
			end
		
		//comment here for debug
		
		ARK0:
			begin
				KExp_counter_next = 7'b0;
				msg_next_state = msg_state ^ key_schedule[127:0];
			end
		
		
		ISR1:
			msg_next_state = msg_next_state_ISR;
		
		ISB1:
			msg_next_state = msg_next_state_ISB;
			
		ARK1:
			msg_next_state = msg_state ^ key_schedule[255:128];
		
		IMC1:
			begin
				if (IMC_counter < 3'd4) // might have to test other values
					IMC_counter_next = IMC_counter + 3'b1;
				else
					msg_next_state = msg_next_state_IMC;
			end
				
				
		ISR2:
			begin
				IMC_counter_next = 3'b0;
				msg_next_state = msg_next_state_ISR;
			end

		ISB2:
			msg_next_state = msg_next_state_ISB;

		ARK2:
			msg_next_state = msg_state ^ key_schedule[383:256];

		IMC2:
			begin
				if (IMC_counter < 3'd4) // might have to test other values
					IMC_counter_next = IMC_counter + 3'b1;
				else
					msg_next_state = msg_next_state_IMC;
			end

				
				
		ISR3:
			begin
				IMC_counter_next = 3'b0;
				msg_next_state = msg_next_state_ISR;
			end

		ISB3:
			msg_next_state = msg_next_state_ISB;

		ARK3:
			msg_next_state = msg_state ^ key_schedule[511:384];

		IMC3:
			begin
				if (IMC_counter < 3'd4) // might have to test other values
					IMC_counter_next = IMC_counter + 3'b1;
				else
					msg_next_state = msg_next_state_IMC;
			end

				
				
		ISR4:
			begin
				IMC_counter_next = 3'b0;
				msg_next_state = msg_next_state_ISR;
			end

		ISB4:
			msg_next_state = msg_next_state_ISB;

		ARK4:
			msg_next_state = msg_state ^ key_schedule[639:512];

		IMC4:
			begin
				if (IMC_counter < 3'd4) // might have to test other values
					IMC_counter_next = IMC_counter + 3'b1;
				else
					msg_next_state = msg_next_state_IMC;
			end

				
				
		ISR5:
			begin
				IMC_counter_next = 3'b0;
				msg_next_state = msg_next_state_ISR;
			end

		ISB5:
			msg_next_state = msg_next_state_ISB;

		ARK5:
			msg_next_state = msg_state ^ key_schedule[767:640];

		IMC5:
			begin
				if (IMC_counter < 3'd4) // might have to test other values
					IMC_counter_next = IMC_counter + 3'b1;
				else
					msg_next_state = msg_next_state_IMC;
			end

				
				
		ISR6:
			begin
				IMC_counter_next = 3'b0;
				msg_next_state = msg_next_state_ISR;
			end

		ISB6:
			msg_next_state = msg_next_state_ISB;

		ARK6:
			msg_next_state = msg_state ^ key_schedule[895:768];

		IMC6:
			begin
				if (IMC_counter < 3'd4) // might have to test other values
					IMC_counter_next = IMC_counter + 3'b1;
				else
					msg_next_state = msg_next_state_IMC;
			end

				
				
		ISR7:
			begin
				IMC_counter_next = 3'b0;
				msg_next_state = msg_next_state_ISR;
			end

		ISB7:
			msg_next_state = msg_next_state_ISB;

		ARK7:
			msg_next_state = msg_state ^ key_schedule[1023:896];

		IMC7:
			begin
				if (IMC_counter < 3'd4) // might have to test other values
					IMC_counter_next = IMC_counter + 3'b1;
				else
					msg_next_state = msg_next_state_IMC;
			end

				
				
		ISR8:
			begin
				IMC_counter_next = 3'b0;
				msg_next_state = msg_next_state_ISR;
			end

		ISB8:
			msg_next_state = msg_next_state_ISB;

		ARK8:
			msg_next_state = msg_state ^ key_schedule[1151:1024];

		IMC8:
			begin
				if (IMC_counter < 3'd4) // might have to test other values
					IMC_counter_next = IMC_counter + 3'b1;
				else
					msg_next_state = msg_next_state_IMC;
			end

				
				
		ISR9:
			begin
				IMC_counter_next = 3'b0;
				msg_next_state = msg_next_state_ISR;
			end

		ISB9:
			msg_next_state = msg_next_state_ISB;

		ARK9:
			msg_next_state = msg_state ^ key_schedule[1279:1152];

		IMC9:
			begin
				if (IMC_counter < 3'd4) // might have to test other values
					IMC_counter_next = IMC_counter + 3'b1;
				else
					msg_next_state = msg_next_state_IMC;
			end
			
		
		
		ISR10:
			begin
				IMC_counter_next = 3'b0;
				msg_next_state = msg_next_state_ISR;
			end
		
		ISB10:
			msg_next_state = msg_next_state_ISB;
		
		ARK10:
			msg_next_state = msg_state ^ key_schedule[1407:1280];
			
		
		default: ;
		
	endcase
	
	
	
end


// instantiate necessary modules
KeyExpansion KExp_module (
.clk(CLK),
.Cipherkey(AES_KEY),
.KeySchedule(key_schedule)
);

InvShiftRows ISR_module (
.data_in(msg_state),
.data_out(msg_next_state_ISR)
);

InvSubBytes128 ISB_module (
.clk(CLK),
.data_in(msg_state),
.data_out(msg_next_state_ISB)
);

InvMixColumns128 IMC_module (
.clk(CLK),
.data_in(msg_state),
.data_out(msg_next_state_IMC)
);


endmodule
