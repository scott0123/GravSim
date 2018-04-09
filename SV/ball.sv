//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Changed the purpose of this file. Now must return is_ball based on --
//        inputted position of ball.												 --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [7:0]   keycode,            // Keycode from the keyboard
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					
					input [9:0]	  posX, posY, posZ,
					
               output logic  is_ball             // Whether current pixel belongs to ball or background
              );
    
    parameter [9:0] Ball_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd4;        // Ball size

//    parameter [7:0] KEYCODE_UP = 8'd26;                  // Keycode for the key UP (in this case: W)
//    parameter [7:0] KEYCODE_DOWN = 8'd22;                  // Keycode for the key DOWN (in this case: S)
//    parameter [7:0] KEYCODE_LEFT = 8'd4;                  // Keycode for the key LEFT (in this case: A)
//    parameter [7:0] KEYCODE_RIGHT = 8'd7;                  // Keycode for the key RIGHT (in this case: D)
    
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
    
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
            if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max ) begin // Ball is at the bottom edge, BOUNCE!
                Ball_X_Motion_in = 10'b0;
                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.
				end
            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size ) begin // Ball is at the top edge, BOUNCE!
                Ball_X_Motion_in = 10'b0;
                Ball_Y_Motion_in = Ball_Y_Step;
				end
            else if ( Ball_X_Pos + Ball_Size >= Ball_X_Max ) begin // Ball is at the right edge, BOUNCE!
                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  // 2's complement.  
                Ball_Y_Motion_in = 10'b0;
				end
            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size ) begin // Ball is at the left edge, BOUNCE!
                Ball_X_Motion_in = Ball_X_Step;
                Ball_Y_Motion_in = 10'b0;
				end
            else begin
//                // key presses
//                if (keycode == KEYCODE_UP) begin
//                    Ball_X_Motion_in = 10'b0;
//                    Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
//					 end
//                else if (keycode == KEYCODE_DOWN) begin
//                    Ball_X_Motion_in = 10'b0;
//                    Ball_Y_Motion_in = Ball_Y_Step;
//					 end
//                else if (keycode == KEYCODE_LEFT) begin
//                    Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
//                    Ball_Y_Motion_in = 10'b0;
//					 end
//                else if (keycode == KEYCODE_RIGHT) begin
//                    Ball_X_Motion_in = Ball_X_Step;
//                    Ball_Y_Motion_in = 10'b0;
//					 end
            end
            // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
        end
        
        /**************************************************************************************
            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
            Hidden Question #2/2:
               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
              What is the difference between writing
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
              Give an answer in your Post-Lab.
        **************************************************************************************/
    end
    
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
    assign Size = Ball_Size;
    always_comb begin
        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
            is_ball = 1'b1;
        else
            is_ball = 1'b0;
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end
    
endmodule
