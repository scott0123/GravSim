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
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA,		// Exported Conduit Signal to HEX
	
	// Added inputs used by ball.sv
	input logic			  Reset_h,
	input logic			  VGA_VS,
	input logic 		  DrawX,
	input logic 		  DrawY,
	
	// Added outputs that must go to top-level entity
	output logic        is_ball

);


logic [31:0] regfile [16];

always_comb begin

	AVL_READDATA = 32'b0;
	if (AVL_CS && AVL_READ) begin
		AVL_READDATA = regfile[AVL_ADDR];
	end
	
	// pos x, y, z (scaled)
	EXPORT_DATA[31:22] = regfile[1][9:0];
	EXPORT_DATA[21:12] = regfile[2][9:0];
	EXPORT_DATA[11:2] = regfile[3][9:0];
	
end


always_ff @(posedge CLK) begin
	
	if (RESET) begin
		regfile[0] <= 32'h00000000;
		regfile[1] <= 32'h00000000;
		regfile[2] <= 32'h00000000;
		regfile[3] <= 32'h00000000;
		regfile[4] <= 32'h00000000;
		regfile[5] <= 32'h00000000;
		regfile[6] <= 32'h00000000;
		regfile[7] <= 32'h00000000;
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
		
//		else if (!(AVL_CS && AVL_READ)) begin
		else begin

//			regfile[15][0] <= AVL_done_temp;
//			{regfile[8], regfile[9], regfile[10], regfile[11]} <= AVL_decrypt_temp;
		end
		
	
	end

end


// -----------------------------------------------------------------

//	   Modules are instantiated here so they have access to regfile

// -----------------------------------------------------------------

ball ball_instance(
// inputs
.Reset(Reset_h),		// not sure how to deal with this
.Clk(CLK),				// 50 MHz clock from top_level
.frame_clk(VGA_VS)
//.keycode,
.DrawX,
.DrawY,
.posX(regfile[1]),
.posY(regfile[2]),
.posZ(regfile[3]),
//outputs
.is_ball
);

endmodule
