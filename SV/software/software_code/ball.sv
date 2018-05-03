//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Changed the purpose of this file. Now must return is_ball based on --
//        inputted position of ball.												 --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
//               input [7:0]   keycode,            // Keycode from the keyboard
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					
                    input [31:0]  relative_shift_x, relative_shift_y, relative_shift_z,
					input [31:0]  radius, posX, posY, posZ, // floats
					
               output logic  is_ball             // Whether current pixel belongs to ball or background
              );
    
	 // consts needed to scale radius, posX, posY, posZ
	 const int FLOAT2 = 32'h40000000;
	 const int FLOAT10 = 32'h41200000;
	 const int FLOAT100 = 32'h42c80000;
	 
	logic [31:0] FPmultRad_out;
	logic [31:0] FPmultX_out;
	logic [31:0] FPmultY_out;
	logic [31:0] FPmultZ_out;
	// integer (pixel) versions of radius, posX, posY, posZ
	logic [31:0] intRad, intPosX, intPosY, intPosZ;

    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
    

    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - (intPosX + 32'd320 + relative_shift_x);
    assign DistY = DrawY - (intPosY + 32'd240 + relative_shift_y);
	 
	 // absolute value of Dists
	 int absDistX, absDistY;
	 
	 logic [31:0] temp_posZadd;
	 logic [31:0] adjRadius;

	 // perform absolute value operations and calculate Z size adjust limit
	 always_comb begin
		
		// radius adjust
		
		temp_posZadd = intPosZ + 32'd20 + relative_shift_z;
		
		// added to ensure that negative temp_posZadd < positive 1
		if ( temp_posZadd[31] == 1 ) begin
			adjRadius = 32'd1;
		end

		else if ( temp_posZadd < 32'd1 ) begin
			adjRadius = 32'd1;
		end
		else if ( temp_posZadd > 32'd80 ) begin
			adjRadius = 32'd80;
		end
		else begin
			adjRadius = temp_posZadd;
		end
		
	 end
	 
	 // currently depends ONLY on Z
    assign Size = adjRadius;
	 
    always_comb begin
        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) )
//			if ( ( absDistX + absDistY) <= (Size) )
            is_ball = 1'b1;
        else
            is_ball = 1'b0;
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end



// -----------------------------------------------------------------

//	   Modules are instantiated here so they have access to regfile

// -----------------------------------------------------------------

FPmult FPmultRad (
	// inputs
	.iA(radius),
	.iB(FLOAT10),
	// outputs
	.oProd(FPmultRad_out)
);

FPmult FPmultX (
	// inputs
	.iA(posX),
	.iB(FLOAT100),
	// outputs
	.oProd(FPmultX_out)
);

FPmult FPmultY (
	// inputs
	.iA(posY),
	.iB(FLOAT100),
	// outputs
	.oProd(FPmultY_out)
);

FPmult FPmultZ (
	// inputs
	.iA(posZ),
	.iB(FLOAT2),
	// outputs
	.oProd(FPmultZ_out)
);

fp2int fp2intRad (
	// inputs
	.fp_in(FPmultRad_out),
	//outputs
	.int_out(intRad)
);

fp2int fp2intX (
	// inputs
	.fp_in(FPmultX_out),
	//outputs
	.int_out(intPosX)
);

fp2int fp2intY (
	// inputs
	.fp_in(FPmultY_out),
	//outputs
	.int_out(intPosY)
);

fp2int fp2intZ (
	// inputs
	.fp_in(FPmultZ_out),
	//outputs
	.int_out(intPosZ)
);

endmodule