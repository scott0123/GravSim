/************************************************************************
Avalon-MM Interface

Register Map:

0: P1 scaled radius
1: P1 scaled x position
2: P1 scaled y position
3: P1 scaled z position

4: P2 scaled radius
5: P2 scaled x position
6: P2 scaled y position
7: P2 scaled z position

************************************************************************/

module avalon_interface (
	// Avalon Clock Input
	input logic CLK, // 50 MHz
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [7:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA,		// Exported Conduit Signal to HEX
	
	// Added inputs used by ball.sv
	input logic			  Reset_h,
	input logic			  VGA_VS,
	input logic [9:0]	  DrawX,
	input logic [9:0]	  DrawY,

    input logic [7:0]   keycode,
	
	// Added outputs that must go to top-level entity
	output logic        is_ball_out,
	output logic [1:0]  ballID

);

parameter [6:0] OFFSET_G = 7'd0;
parameter [6:0] OFFSET_NUM = 7'd1;
parameter [6:0] OFFSET_START = 7'd2;
parameter [6:0] OFFSET_DONE = 7'd3;
parameter [6:0] OFFSET_MASS = 7'd3;
parameter [6:0] OFFSET_RAD = 7'd13;
parameter [6:0] OFFSET_POS_X = 7'd23;
parameter [6:0] OFFSET_POS_Y = 7'd33;
parameter [6:0] OFFSET_POS_Z = 7'd43;
parameter [6:0] OFFSET_VEL_X = 7'd53;
parameter [6:0] OFFSET_VEL_Y = 7'd63;
parameter [6:0] OFFSET_VEL_Z = 7'd73;
parameter [6:0] OFFSET_ACC_X = 7'd83;
parameter [6:0] OFFSET_ACC_Y = 7'd93;
parameter [6:0] OFFSET_ACC_Z = 7'd103;

parameter [7:0] KEYCODE_SPACE = 8'd4;                  // Keycode for the key SPACE (in this case: ' ')
parameter [7:0] KEYCODE_UP = 8'd26;                  // Keycode for the key UP (in this case: W)
parameter [7:0] KEYCODE_DOWN = 8'd22;                  // Keycode for the key DOWN (in this case: S)
parameter [7:0] KEYCODE_LEFT = 8'd4;                  // Keycode for the key LEFT (in this case: A)
parameter [7:0] KEYCODE_RIGHT = 8'd7;                  // Keycode for the key RIGHT (in this case: D)
// added internal logic for FSM
logic FSM_clear_accs;
logic [1:0] FSM_re, FSM_we;
logic [31:0] FSM_ADDR1, FSM_ADDR2, FSM_ADDR3, FSM_ADDR4, FSM_ADDR5, FSM_ADDR6;
logic [31:0] FSM_DATA1, FSM_DATA2, FSM_DATA3, FSM_DATA4, FSM_DATA5, FSM_DATA6;
logic [31:0] FSM_DATA1in, FSM_DATA2in, FSM_DATA3in, FSM_DATA4in, FSM_DATA5in, FSM_DATA6in;

logic FSM_START;
logic PAUSED;
logic SPACE_PRESSED;
logic SPACE_PRESSED_ALREADY;
logic UP_PRESSED;
logic DOWN_PRESSED;
logic LEFT_PRESSED;
logic RIGHT_PRESSED;

logic [31:0] relative_shift_x, relative_shift_y, relative_shift_z;

// SIZE = 114
// 3 "Misc" data:
//						Number of balls being used
// 					FSM_START bit
//						FSM_DONE bit
// Body data (x10 size per var):
//						Mass
//						 ...
//						Radius
//						 ...
//						X_pos
//						 ...
//						Y_pos
//						 ...
//						Z_pos
//						 ...
//						X_vel
//						 ...
//						Y_vel
//						 ...
//						Z_vel
//						 ...
//						X_acc
//						 ...
//						Y_acc
//						 ...
//						Z_acc
//						 ...

logic [31:0] regfile [114];
logic FSM_DONE_temp;

always_comb begin

	AVL_READDATA = 32'b0;
	if (AVL_CS && AVL_READ) begin
		AVL_READDATA = regfile[AVL_ADDR];
	end
	
	// pos x, y, z (scaled)
	EXPORT_DATA[31:22] = regfile[1][9:0];
	EXPORT_DATA[21:12] = regfile[2][9:0];
	EXPORT_DATA[11:2] = regfile[3][9:0];

    if (keycode == KEYCODE_SPACE) SPACE_PRESSED = 1'b1;
    else SPACE_PRESSED = 1'b0;

    if (keycode == KEYCODE_UP) UP_PRESSED = 1'b1;
    else UP_PRESSED = 1'b0;

    if (keycode == KEYCODE_DOWN) DOWN_PRESSED = 1'b1;
    else DOWN_PRESSED = 1'b0;

    if (keycode == KEYCODE_LEFT) LEFT_PRESSED = 1'b1;
    else LEFT_PRESSED = 1'b0;

    if (keycode == KEYCODE_RIGHT) RIGHT_PRESSED = 1'b1;
    else RIGHT_PRESSED = 1'b0;

    if (AVL_VS == 1'b1 && ~PAUSED) begin
        FSM_START = 1'b1;
    end
    else begin
        FSM_START = 1'b0
    end
end


always_ff @(posedge CLK) begin
	
	if (RESET) begin
		for (integer i = 0; i < 114; i += 1) begin
			regfile[i] <= 32'b0;
		end
        relative_shift_x <= 32'b0;
        relative_shift_y <= 32'b0;
        relative_shift_z <= 32'b0;
	end
	
	else begin
	
		if (AVL_CS && AVL_WRITE) begin
						
			case(AVL_BYTE_EN)
			
				4'b1111: begin
					regfile[AVL_ADDR] <= AVL_WRITEDATA;
				end
				
				4'b1100: begin
					regfile[AVL_ADDR][31:16] <= AVL_WRITEDATA[31:16];
				end
				
				4'b0011: begin
					regfile[AVL_ADDR][15:0] <= AVL_WRITEDATA[15:0];
				end
			
				4'b1000: begin
					regfile[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
				end
				
				4'b0100: begin
					regfile[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
				end
				
				4'b0010: begin
					regfile[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8];
				end
				
				4'b0001: begin
					regfile[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0];
				end
			
			endcase
			
			
		end
		
		/*
		* FSM_we CONVENTION: FSM_we = 2'b0 : no write
		* 										2'b1 : write ADDR 1, 2, 3
		* 										2'b2 : write ADDR 4, 5, 6
		* 										2'b3 : write ADDR 1, 2, 3, 4, 5, 6
		*/
		else begin
		
			if (FSM_clear_accs) begin
			
				for (int i = 0; i < 10; i += 1) begin
					regfile[OFFSET_ACC_X + i + 7'd1] <= 32'b0;
					regfile[OFFSET_ACC_Y + i + 7'd1] <= 32'b0;
					regfile[OFFSET_ACC_Z + i + 7'd1] <= 32'b0;
				end
				
			end
			
			// FSM write enable
			if (FSM_we == 2'd1) begin
		
				regfile[FSM_ADDR1] <= FSM_DATA1;
				regfile[FSM_ADDR2] <= FSM_DATA2;
				regfile[FSM_ADDR3] <= FSM_DATA3;
		
			end
			else if (FSM_we == 2'd3) begin
		
				regfile[FSM_ADDR1] <= FSM_DATA1;
				regfile[FSM_ADDR2] <= FSM_DATA2;
				regfile[FSM_ADDR3] <= FSM_DATA3;
	
				regfile[FSM_ADDR4] <= FSM_DATA4;
				regfile[FSM_ADDR5] <= FSM_DATA5;
				regfile[FSM_ADDR6] <= FSM_DATA6;
		
			end
			
			// FSM read enable
			if (FSM_re == 2'd1) begin
		
				FSM_DATA1in <= regfile[FSM_ADDR1];
				FSM_DATA2in <= regfile[FSM_ADDR2];
				FSM_DATA3in <= regfile[FSM_ADDR3];
		
			end
			else if (FSM_re == 2'd3) begin
		
				FSM_DATA1in <= regfile[FSM_ADDR1];
				FSM_DATA2in <= regfile[FSM_ADDR2];
				FSM_DATA3in <= regfile[FSM_ADDR3];
	
				FSM_DATA4in <= regfile[FSM_ADDR4];
				FSM_DATA5in <= regfile[FSM_ADDR5];
				FSM_DATA6in <= regfile[FSM_ADDR6];
		
			end
			
			regfile[OFFSET_DONE][0] <= FSM_DONE_temp;
			
		end
			
        if (SPACE_READY == 1'b1 && SPACE_PRESSED == 1'b1) begin
            SPACE_READY <= 1'b0;
            PAUSED <= ~PAUSED;
        end
        else if (SPACE_PRESSED == 1'b0) begin
            SPACE_READY <= 1'b1;
        end

        if(SPACE_UP == 1'b1 && VGA_VS == 1'b1) begin
            relative_shift_y <= relative_shift_y + 32'b1;
        end
        if(SPACE_DOWN == 1'b1 && VGA_VS == 1'b1) begin
            relative_shift_x <= relative_shift_y - 32'b1;
        end
        if(SPACE_LEFT == 1'b1 && VGA_VS == 1'b1) begin
            relative_shift_x <= relative_shift_x - 32'b1;
        end
        if(SPACE_RIGHT == 1'b1 && VGA_VS == 1'b1) begin
            relative_shift_x <= relative_shift_x + 32'b1;
        end
	end

end


// -----------------------------------------------------------------

//	   Modules are instantiated here so they have access to regfile

// -----------------------------------------------------------------

FSM FSM_instance (

	// inputs
	.CLK,
	.RESET,
	.FSM_START(FSM_START),
//	.datafile(regfile),
	
	// outputs
	.FSM_DONE(FSM_DONE_temp),
	
	// added outputs
	.clear_accs(FSM_clear_accs),
	
	.FSM_re,
	.FSM_we,
	
	.PLANET_NUM(regfile[OFFSET_NUM]),
	.G(regfile[OFFSET_G]),
	
	.ADDR1(FSM_ADDR1),
	.ADDR2(FSM_ADDR2),
	.ADDR3(FSM_ADDR3),
	.ADDR4(FSM_ADDR4),
	.ADDR5(FSM_ADDR5),
	.ADDR6(FSM_ADDR6),
	
	.DATA1(FSM_DATA1),
	.DATA2(FSM_DATA2),
	.DATA3(FSM_DATA3),
	.DATA4(FSM_DATA4),
	.DATA5(FSM_DATA5),
	.DATA6(FSM_DATA6),
	
	.DATA1in(FSM_DATA1in),
	.DATA2in(FSM_DATA2in),
	.DATA3in(FSM_DATA3in),
	.DATA4in(FSM_DATA4in),
	.DATA5in(FSM_DATA5in),
	.DATA6in(FSM_DATA6in)

	
);




logic is_ball_1, is_ball_2, is_ball_3, is_ball_4;

assign is_ball_out = is_ball_1 | is_ball_2 | is_ball_3 | is_ball_4;

always_comb begin

	ballID = 2'bx;

	if (is_ball_1 == 1)
		ballID = 2'd0;
	else if (is_ball_2 == 1)
		ballID = 2'd1;
	else if (is_ball_3 == 1)
		ballID = 2'd2;
	else if (is_ball_4 == 1)
		ballID = 2'd3;
end

ball ball_1 (
// inputs
.Reset(Reset_h),		// not sure how to deal with this
.Clk(CLK),				// 50 MHz clock from top_level
.frame_clk(VGA_VS),
//.keycode,
.DrawX,
.DrawY,
.relative_shift_x,
.relative_shift_y,
.relative_shift_z,
.radius(regfile[OFFSET_RAD+7'd1]),
.posX(regfile[OFFSET_POS_X+7'd1]),
.posY(regfile[OFFSET_POS_Y+7'd1]),
.posZ(regfile[OFFSET_POS_Z+7'd1]),
//outputs
.is_ball(is_ball_1)
);

ball ball_2 (
// inputs
.Reset(Reset_h),		// not sure how to deal with this
.Clk(CLK),				// 50 MHz clock from top_level
.frame_clk(VGA_VS),
//.keycode,
.DrawX,
.DrawY,
.relative_shift_x,
.relative_shift_y,
.relative_shift_z,
.radius(regfile[OFFSET_RAD+7'd2]),
.posX(regfile[OFFSET_POS_X+7'd2]),
.posY(regfile[OFFSET_POS_Y+7'd2]),
.posZ(regfile[OFFSET_POS_Z+7'd2]),
//outputs
.is_ball(is_ball_2)
);

ball ball_3 (
// inputs
.Reset(Reset_h),		// not sure how to deal with this
.Clk(CLK),				// 50 MHz clock from top_level
.frame_clk(VGA_VS),
//.keycode,
.DrawX,
.DrawY,
.relative_shift_x,
.relative_shift_y,
.relative_shift_z,
.radius(regfile[OFFSET_RAD+7'd3]),
.posX(regfile[OFFSET_POS_X+7'd3]),
.posY(regfile[OFFSET_POS_Y+7'd3]),
.posZ(regfile[OFFSET_POS_Z+7'd3]),
//outputs
.is_ball(is_ball_3)
);

ball ball_4 (
// inputs
.Reset(Reset_h),		// not sure how to deal with this
.Clk(CLK),				// 50 MHz clock from top_level
.frame_clk(VGA_VS),
//.keycode,
.DrawX,
.DrawY,
.relative_shift_x,
.relative_shift_y,
.relative_shift_z,
.radius(regfile[OFFSET_RAD+7'd4]),
.posX(regfile[OFFSET_POS_X+7'd4]),
.posY(regfile[OFFSET_POS_Y+7'd4]),
.posZ(regfile[OFFSET_POS_Z+7'd4]),
//outputs
.is_ball(is_ball_4)
);

endmodule
