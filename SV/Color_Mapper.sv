//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_ball,            // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
							  input			[1:0]		ballID,
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    
	// Output colors to VGA
	assign VGA_R = Red;
	assign VGA_G = Green;
	assign VGA_B = Blue;

	// Assign color based on is_ball signal
	always_comb begin
	
		if (is_ball == 1'b1) begin
		
				// (Default) White ball
				Red = 8'hff;
				Green = 8'hff;
				Blue = 8'hff;
		
			if (ballID == 2'd0) begin
				// Red ball
				Red = 8'hff;
				Green = 8'h99;
				Blue = 8'h99;
			end
			
			else if (ballID == 2'd1) begin
				// Green ball
				Red = 8'h99;
				Green = 8'hff;
				Blue = 8'h99;
			end
			
			else if (ballID == 2'd2) begin
				// Blue ball
				Red = 8'hcc;
				Green = 8'hff;
				Blue = 8'hff;
			end
			
			else if (ballID == 2'd3) begin
				// Yellow ball
				Red = 8'hff;
				Green = 8'hff;
				Blue = 8'h99;
			end
		
	 end
	 
	 else begin
	 
		  // Black background
		  Red = 8'h00; 
		  Green = 8'h00;
		  Blue = 8'h00;
		  
		end
		
	end 
 
endmodule
