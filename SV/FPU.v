/**************************************************************************
 * Anish Bhattacharya abhttch4														  *
 * Scott Liu sliu125																		  *
 * ADAPTED FROM																			  *
 * Mark Eiding mje56                                                      *
 * ADAPTED FROM																			  *
 * Skyler Schneider ss868																  *
 * Modified IEEE single precision FP                                      *
 * bit 31:      Sign     (0: pos, 1: neg)                                 *
 * bits[30:23]: Exponent (unsigned)                                       *
 * bits[22:0]:  Fraction (unsigned)                                       *
 * (http://en.wikipedia.org/wiki/Single-precision_floating-point_format)  *
 *************************************************************************/



/**************************************************************************
 * Floating Point Fast Inverse Square Root                                *
 * 5-stage pipeline                                                       *
 * http://en.wikipedia.org/wiki/Fast_inverse_square_root                  *
 * Magic Quake number 32'h5f3759df                                        *
 * 1.5 = 32'h3fc00000                                                     *
 *************************************************************************/
 // already changed to 32bit
module FPinvsqrt (
    input             iCLK,
    input      [31:0] iA,
    output     [31:0] oInvSqrt
);

    // Extract fields of A and B.
    wire        A_s;
    wire [7:0]  A_e;
    wire [22:0] A_f;
    assign A_s = iA[31];
    assign A_e = iA[30:23];
    assign A_f = iA[22:0];

    //Stage 1
    wire [31:0] y_1, y_1_out, half_iA_1;
    assign y_1 = 32'h5f3759df - (iA>>1);
    assign half_iA_1 = {A_s, A_e-8'd1,A_f};
    FPmult s1_mult ( .iA(y_1), .iB(y_1), .oProd(y_1_out) );
	 
    //Stage 2
    reg [31:0] y_2, mult_2_in, half_iA_2;
    wire [31:0] y_2_out;
    FPmult s2_mult ( .iA(half_iA_2), .iB(mult_2_in), .oProd(y_2_out) );
	 
    //Stage 3
    reg [31:0] y_3, add_3_in;
    wire [31:0] y_3_out;
    FPadd s3_add ( .iCLK(iCLK), .iA({~add_3_in[31],add_3_in[30:0]}), .iB(32'h3fc00000), .oSum(y_3_out) );
	 
    //Stage 4
    reg [31:0] y_4;
	 
    //Stage 5
    reg [31:0] y_5, mult_5_in;
    FPmult s5_mult ( .iA(y_5), .iB(mult_5_in), .oProd(oInvSqrt) );

    always @(posedge iCLK) begin
		 //Stage 1 to 2
		 y_2 <= y_1;
		 mult_2_in <= y_1_out;
		 half_iA_2 <= half_iA_1;
		 
		 //Stage 2 to 3
		 y_3 <= y_2;
		 add_3_in <= y_2_out;
		 
		 //Stage 3 to 4
		 y_4 <= y_3;
		 
		 //Stage 4 to 5
		 y_5 <= y_4;
		 mult_5_in <= y_3_out;
    end


endmodule

/**************************************************************************
 * Floating Point Multiplier                                              *
 * Combinational                                                          *
 *************************************************************************/
module FPmult (
    input      [31:0] iA,    // First input
    input      [31:0] iB,    // Second input
    output     [31:0] oProd  // Product
);

    // Extract fields of A and B.
    wire        A_s;
    wire [7:0]  A_e;
    wire [22:0] A_f;
    wire        B_s;
    wire [7:0]  B_e;
    wire [22:0] B_f;
    assign A_s = iA[31];
    assign A_e = iA[30:23];
    assign A_f = {1'b1, iA[22:1]};
    assign B_s = iB[31];
    assign B_e = iB[30:23];
    assign B_f = {1'b1, iB[22:1]};

    // XOR sign bits to determine product sign.
    wire        oProd_s;
    assign oProd_s = A_s ^ B_s;

    // Multiply the fractions of A and B
    wire [45:0] pre_prod_frac;
    assign pre_prod_frac = A_f * B_f;

    // Add exponents of A and B
    wire [8:0]  pre_prod_exp;
    assign pre_prod_exp = A_e + B_e;

    // If top bit of product frac is 0, shift left one
    wire [7:0]  oProd_e;
    wire [22:0] oProd_f;
    assign oProd_e = pre_prod_frac[45] ? (pre_prod_exp-9'd126) : (pre_prod_exp - 9'd127);
    assign oProd_f = pre_prod_frac[45] ? pre_prod_frac[44:22] : pre_prod_frac[43:21];

    // Detect underflow
    wire        underflow;
    assign underflow = pre_prod_exp < 9'h80;

    // Detect zero conditions (either product frac doesn't start with 1, or underflow)
    assign oProd = underflow        ? 32'b0 :
                   (B_e == 8'd0)    ? 32'b0 :
                   (A_e == 8'd0)    ? 32'b0 :
                   {oProd_s, oProd_e, oProd_f};

endmodule


module FPU (
	
	input iCLK,
	input [31:0] in,
	output [31:0] out

);

wire [31:0] Out_invsqrt;

FPinvsqrt fpinvsqrt (

	.iCLK(iCLK),
	.iA(in),
	.oInvSqrt(Out_invsqrt)
	
);

FPmult fpmult (

	.iA(Out_invsqrt),
	.iB(Out_invsqrt),
	.oProd(out)
	
);

endmodule

























/**************************************************************************
 * Floating Point Adder                                                   *
 * 2-stage pipeline                                                       *
 *************************************************************************/
module FPadd (
    input             iCLK,
    input      [31:0] iA,
    input      [31:0] iB,
    output     [31:0] oSum
);

    // Extract fields of A and B.
    wire        A_s;
    wire [7:0]  A_e;
    wire [22:0] A_f;
    wire        B_s;
    wire [7:0]  B_e;
    wire [22:0] B_f;
    assign A_s = iA[31];
    assign A_e = iA[30:23];
    assign A_f = {1'b1, iA[22:1]};
    assign B_s = iB[31];
    assign B_e = iB[30:23];
    assign B_f = {1'b1, iB[22:1]};
    wire A_larger;

    // Shift fractions of A and B so that they align.
    wire [7:0]  exp_diff_A;
    wire [7:0]  exp_diff_B;
    wire [7:0]  larger_exp;
    wire [46:0] A_f_shifted;
    wire [46:0] B_f_shifted;

    assign exp_diff_A = B_e - A_e; // if B bigger
    assign exp_diff_B = A_e - B_e; // if A bigger

    assign larger_exp = (B_e > A_e) ? B_e : A_e;

    assign A_f_shifted = A_larger             ? {1'b0,  A_f, 23'b0} :
                         (exp_diff_A > 9'd35) ? 47'b0 :
                         ({1'b0, A_f, 23'b0} >> exp_diff_A);
    assign B_f_shifted = ~A_larger            ? {1'b0,  B_f, 23'b0} :
                         (exp_diff_B > 9'd35) ? 47'b0 :
                         ({1'b0, B_f, 23'b0} >> exp_diff_B);

    // Determine which of A, B is larger
    assign A_larger =    (A_e > B_e)                   ? 1'b1  :
                         ((A_e == B_e) && (A_f > B_f)) ? 1'b1  :
                         1'b0;

    // Calculate sum or difference of shifted fractions.
    wire [46:0] pre_sum;
    assign pre_sum = ((A_s^B_s) &  A_larger) ? A_f_shifted - B_f_shifted :
                     ((A_s^B_s) & ~A_larger) ? B_f_shifted - A_f_shifted :
                     A_f_shifted + B_f_shifted;

    // buffer midway results
    reg  [46:0] buf_pre_sum;
    reg  [7:0]  buf_larger_exp;
    reg         buf_A_e_zero;
    reg         buf_B_e_zero;
    reg  [31:0] buf_A;
    reg  [31:0] buf_B;
    reg         buf_oSum_s;
    always @(posedge iCLK) begin
        buf_pre_sum    <= pre_sum;
        buf_larger_exp <= larger_exp;
        buf_A_e_zero   <= (A_e == 8'b0);
        buf_B_e_zero   <= (B_e == 8'b0);
        buf_A          <= iA;
        buf_B          <= iB;
        buf_oSum_s     <= A_larger ? A_s : B_s;
    end

    // Convert to positive fraction and a sign bit.
    wire [46:0] pre_frac;
    assign pre_frac = buf_pre_sum;

    // Determine output fraction and exponent change with position of first 1.
    wire [22:0] oSum_f;
    wire [7:0]  shft_amt;
    assign shft_amt = pre_frac[46] ? 8'd0  : pre_frac[45] ? 8'd1  :
                      pre_frac[44] ? 8'd2  : pre_frac[43] ? 8'd3  :
                      pre_frac[42] ? 8'd4  : pre_frac[41] ? 8'd5  :
                      pre_frac[40] ? 8'd6  : pre_frac[39] ? 8'd7  :
                      pre_frac[38] ? 8'd8  : pre_frac[37] ? 8'd9  :
                      pre_frac[36] ? 8'd10 : pre_frac[35] ? 8'd11 :
                      pre_frac[34] ? 8'd12 : pre_frac[33] ? 8'd13 :
                      pre_frac[32] ? 8'd14 : pre_frac[31] ? 8'd15 :
                      pre_frac[30] ? 8'd16 : pre_frac[29] ? 8'd17 :
                      pre_frac[28] ? 8'd18 : pre_frac[27] ? 8'd19 :
                      pre_frac[26] ? 8'd20 : pre_frac[25] ? 8'd21 :
                      pre_frac[24] ? 8'd22 : pre_frac[23] ? 8'd23 :
                      pre_frac[22] ? 8'd24 : pre_frac[21] ? 8'd25 :
                      pre_frac[20] ? 8'd26 : pre_frac[19] ? 8'd27 :
                      pre_frac[18] ? 8'd28 : pre_frac[17] ? 8'd29 :
                      pre_frac[16] ? 8'd30 : pre_frac[15] ? 8'd31 :
                      pre_frac[14] ? 8'd32 : pre_frac[13] ? 8'd33 :
                      pre_frac[12] ? 8'd34 : pre_frac[11] ? 8'd35 :
                      pre_frac[10] ? 8'd36 : pre_frac[9]  ? 8'd37 :
                      pre_frac[8]  ? 8'd38 : pre_frac[7]  ? 8'd39 :
                      pre_frac[6]  ? 8'd40 : pre_frac[5]  ? 8'd41 :
                      pre_frac[4]  ? 8'd42 : pre_frac[3]  ? 8'd43 :
                      pre_frac[2]  ? 8'd44 : pre_frac[1]  ? 8'd45 :
                      pre_frac[0]  ? 8'd46 : 8'd47;

    wire [68:0] pre_frac_shft;
    assign pre_frac_shft = {pre_frac, 22'b0} << (shft_amt+1);
    assign oSum_f = pre_frac_shft[68:46];

    wire [7:0] oSum_e;
    assign oSum_e = buf_larger_exp - shft_amt + 8'b1;

	 // this is broken until further notice
    // Detect underflow
//    wire underflow;
//    assign underflow = ~oSum_e[7] && buf_larger_exp[7] && (shft_amt != 8'b0);

    assign oSum = (buf_A_e_zero && buf_B_e_zero)   ? 32'b0 :
                  buf_A_e_zero                     ? buf_B :
                  buf_B_e_zero                     ? buf_A :
//                  underflow                        ? 32'b0 :
                  (pre_frac == 0)                  ? 32'b0 :
                  {buf_oSum_s, oSum_e, oSum_f};
						// sign bit + exponent + fraction
						//    1     +   8      +    23

endmodule

/****************************************************************************
 * floating point to integer															    *
 * output: 32-bit signed integer 													    *
 * input: -- sign bit -- 8-bit exponent -- 23-bit mantissa 					    *
 * NO denorms, no flags, no NAN, no infinity, no rounding!						 *
 * Truncates floating point to integer													 *
 * 																								 *
 * ADAPTED FROM															  					 *
 * Bruce R Land, Cornell University														 *
 * WITH REFERENCE TO																			 *
 * StackOverflow (see references)														 *
 * *************************************************************************/
module fp2int(
	input wire [31:0] fp_in,
	output signed [31:0] int_out
);

//	input wire [31:0] fp_in;
//	output signed  [31:0] int_out ;
	
	wire [31:0] abs_int;
	wire sign;
	wire [23:0] m_in; // mantissa (length + 1)
	wire [7:0] e_in; // exponent
	
	
	//assign sign = (m_in[22])? fp_in[31] : 1'h0;
	assign sign = fp_in[31];
	assign m_in = {1'b1, fp_in[22:0]};
	assign e_in = fp_in[30:23] ;

	assign abs_int = (e_in>8'h80)? (m_in >> (8'd150 - e_in)) : 32'd0;
	assign int_out = (sign? (~abs_int)+32'd1 : abs_int);
endmodule


// TAKEN FROM DIFFERENT SOURCE (FP_operations_design.v local)
//////////////////////////////////////////////////////////
// floating point reciprocal  (invert)
// -- sign bit -- 8-bit exponent -- 9-bit mantissa
//
// NO denorms, no flags, no NAN, no infinity, no rounding!
//////////////////////////////////////////////////////////
// f1 = {s1, e1, m1)
// If f1 is zero, set output to max number (about 1e38)
///////////////////////////////////////////////////////////	
module FPinv (f1, fout);

	input [31:0] f1 ;
	output [31:0] fout ;
	
	wire [31:0] fout ;
	reg sout ;
	reg [22:0] mout ;
	reg [8:0] eout ; // 9-bits for overflow
	
	wire s1;
	wire [22:0] m1 ;
	wire [8:0] e1 ; // extend to 9 bits to avoid overflow
	wire [31:0] inv_out ;	// 
	
	// parse f1
	assign s1 = f1[31]; 	// sign
	assign e1 = {1'b0, f1[30:23]};	// exponent
	assign m1 = f1[22:0] ;	// mantissa
	
	// assemble output bits from 'always @' below
	assign fout = {sout, eout[7:0], mout} ;
	
	// newton iteration: linear approx + 2 steps
	// x0 = T1 - 2*input (input 0.5<=input<=1.0
	// x1 = x0*(2-input*x0)
	// x2 = x1*(2-input*x1)
	// from http://en.wikipedia.org/wiki/Division_%28digital%29
	wire [31:0] x0, x1, x2, reduced_input, reduced_input_x_2 ;
	wire [31:0] input_x_x0, input_x_x1 ;
	wire [31:0] two_minus_input_x_x0, two_minus_input_x_x1 ;
	
//	parameter T1 = 18'h10575 ; // T1=2.9142 							// NEEDS TO CHANGE
	parameter T1 = 32'h3ff0f0f1 ; // T1=2.9142
//	parameter T2 = {1'b0, 8'h82, 9'h100} ;							// NEEDS TO CHANGE
	parameter T2 = 32'h4034b4b5 ;
		
	// form (T1-2*input)
	// BUT limit input range on 0.5 to 1.0 (just the mantissa)
	// THEN mult by two by setting exp to 8'h81
	// AND make it negative by setting the sign bit
	assign reduced_input = {1'b1, 8'h80, m1} ;
	assign reduced_input_x_2 = {1'b1, 8'h81, m1} ;
	FPadd init_newton(reduced_input_x_2, T1, x0) ;
	
	// form x1 = x0*(2-input*x0)
	FPmult newton11(reduced_input, x0, input_x_x0) ;
	FPadd newton12(T2, input_x_x0, two_minus_input_x_x0);
	FPmult newton13(x0, two_minus_input_x_x0, x1) ;
	
	// form x2 = x1*(2-input*x1)
	FPmult newton21(reduced_input, x1, input_x_x1) ;
	FPadd newton22(T2, input_x_x1, two_minus_input_x_x1);
	FPmult newton23(x1, two_minus_input_x_x1, x2) ;
	
	// select between zero and nonzero input
	always @(*)
	begin
		// if input is zero
		if (m1[22]==1'd0) 
		begin 
			// make the biggest possible output
			mout = 23'b10000000000000000000000 ; 
			eout = 9'h0ff ;
			sout = 0; // output sign
		end
		
		else // input is nonzero 
		begin 
			eout = (m1==23'b10000000000000000000000)? 9'h102 - e1 : 9'h101 - e1 ; // h81+(h81-e1)
			sout = s1; // output sign
			mout = x2[22:0] ; // the newton result		
		end // input is nonzero
	end
endmodule

// TAKEN FROM DIFFERENT SOURCE (FP_operations_design.v local)
/////////////////////////////////////////////////////////////////////////////
// floating point Add 
// -- sign bit -- 8-bit exponent -- 9-bit mantissa
// NO denorms, no flags, no NAN, no infinity, no rounding!
/////////////////////////////////////////////////////////////////////////////
// f1 = {s1, e1, m1), f2 = {s2, e2, m2)
// If either input is zero (zero MSB of mantissa) then output is the remaining input.
// If either input is <(other input)/2**9 then output is the remaining input.
// Sign of the output is the sign of the greater magnitude input
// Add the two inputs if their signs are the same. 
// Subtract the two inputs (bigger-smaller) if their signs are different
//////////////////////////////////////////////////////////////////////////////	
module fpadd (fout, f1, f2);

	input [31:0] f1, f2 ;
	output [31:0] fout ;
	
	wire  [31:0] fout ;
	wire sout ;
	reg [22:0] mout ;
	reg [7:0] eout ;
	reg [23:0] shift_small, denorm_mout ; //9th bit is overflow bit
	
	wire s1, s2 ; // input signs
	reg  sb, ss ; // signs of bigger and smaller
	wire [22:0] m1, m2 ; // input mantissas
	reg  [22:0] mb, ms ; // mantissas of bigger and smaller
	wire [7:0] e1, e2 ; // input exp
	wire [7:0] ediff ;  // exponent difference
	reg  [7:0] eb, es ; // exp of bigger and smaller
	reg  [7:0] num_zeros ; // high order zeros in the difference calc
	
	// parse f1
	assign s1 = f1[31]; 	// sign
	assign e1 = f1[30:23];	// exponent
	assign m1 = {1'b1, f1[22:1]} ;	// mantissa
	// parse f2
	assign s2 = f2[31];
	assign e2 = f2[30:23];
	assign m2 = {1'b1, f2[22:1]} ;
	
	// find biggest magnitude
	always @(*)
	begin
		if (e1>e2) // f1 is bigger
		begin
			sb = s1 ; // the bigger number (absolute value)
			eb = e1 ;
			mb = m1 ;
			ss = s2 ; // the smaller number
			es = e2 ;
			ms = m2 ;
		end
		else if (e2>e1) //f2 is bigger
		begin
			sb = s2 ; // the bigger number (absolute value)
			eb = e2 ;
			mb = m2 ;
			ss = s1 ; // the smaller number
			es = e1 ;
			ms = m1 ;
		end
		else // e1==e2, so need to look at mantissa to determine bigger/smaller
		begin
			if (m1>m2) // f1 is bigger
			begin
				sb = s1 ; // the bigger number (absolute value)
				eb = e1 ;
				mb = m1 ;
				ss = s2 ; // the smaller number
				es = e2 ;
				ms = m2 ;
			end
			else // f2 is bigger or same size
			begin
				sb = s2 ; // the bigger number (absolute value)
				eb = e2 ;
				mb = m2 ;
				ss = s1 ; // the smaller number
				es = e1 ;
				ms = m1 ;
			end
		end
	end //found the bigger number
	
	// sign of output is the sign of the bigger (magnitude) input
	assign sout = sb ;
	// form the output
	assign fout = {sout, eout, mout} ;	
	
	// do the actual add:
	// -- equalize exponents
	// -- add/sub
	// -- normalize
	assign ediff = eb - es ; // the actual difference in exponents
	always @(*)
	begin
		if ((ms[22]==0) && (mb[22]==0))  // both inputs are zero
		begin
			mout = 23'b0 ;
			eout = 8'b0 ; 
		end
		else if ((ms[22]==0) || ediff>8)  // smaller is too small to matter
		begin
			mout = mb ;
			eout = eb ;
		end
		else  // shift/add/normalize
		begin
			// now shift but save the low order bits by extending the registers
			// need a high order bit for 1.0<sum<2.0
			shift_small = {1'b0, ms} >> ediff ;
			// same signs means add -- different means subtract
			if (sb==ss) //do the add
			begin
				denorm_mout = {1'b0, mb} + shift_small ;
				// normalize --
				// when adding result has to be 0.5<sum<2.0
				if (denorm_mout[23]==1) // sum bigger than 1
				begin
					mout = denorm_mout[23:1] ; // take the top bits (shift-right)
					eout = eb + 8'b1 ; // compensate for the shift-right
				end
				else //0.5<sum<1.0
				begin
					mout = denorm_mout[22:0] ; // drop the top bit (no-shift-right)
					eout = eb ; // 
				end
			end // end add logic
			else // otherwise sb!=ss, so subtract
			begin
				denorm_mout = {1'b0, mb} - shift_small ;
				// the denorm_mout is always smaller then the bigger input
				// (and never an overflow, so bit 9 is always zero)
				// and can be as low as zero! Thus up to 8 shifts may be necessary
				// to normalize denorm_mout
				if (denorm_mout[22:0]==23'd0)
				begin
					mout = 23'b0 ;
					eout = 8'b0 ;
				end
				else
				begin
					// detect leading zeros
					casex (denorm_mout[22:0])
						23'b1xxxxxxxxxxxxxxxxxxxxxx: num_zeros = 8'd0 ;
						23'b01xxxxxxxxxxxxxxxxxxxxx: num_zeros = 8'd1 ;
						23'b001xxxxxxxxxxxxxxxxxxxx: num_zeros = 8'd2 ;
						23'b0001xxxxxxxxxxxxxxxxxxx: num_zeros = 8'd3 ;
						23'b00001xxxxxxxxxxxxxxxxxx: num_zeros = 8'd4 ;
						23'b000001xxxxxxxxxxxxxxxxx: num_zeros = 8'd5 ;
						23'b0000001xxxxxxxxxxxxxxxx: num_zeros = 8'd6 ;
						23'b00000001xxxxxxxxxxxxxxx: num_zeros = 8'd7 ;
						23'b000000001xxxxxxxxxxxxxx: num_zeros = 8'd8 ;
						23'b0000000001xxxxxxxxxxxxx: num_zeros = 8'd9 ;
						23'b00000000001xxxxxxxxxxxx: num_zeros = 8'd10 ;
						23'b000000000001xxxxxxxxxxx: num_zeros = 8'd11 ;
						23'b0000000000001xxxxxxxxxx: num_zeros = 8'd12 ;
						23'b00000000000001xxxxxxxxx: num_zeros = 8'd13 ;
						23'b000000000000001xxxxxxxx: num_zeros = 8'd14 ;
						23'b0000000000000001xxxxxxx: num_zeros = 8'd15 ;
						23'b00000000000000001xxxxxx: num_zeros = 8'd16 ;
						23'b000000000000000001xxxxx: num_zeros = 8'd17 ;
						23'b0000000000000000001xxxx: num_zeros = 8'd18 ;
						23'b00000000000000000001xxx: num_zeros = 8'd19 ;
						23'b000000000000000000001xx: num_zeros = 8'd20 ;
						23'b0000000000000000000001x: num_zeros = 8'd21 ;
						23'b00000000000000000000001: num_zeros = 8'd22 ;

						
						default:       num_zeros = 8'd23 ;
					endcase	
					// shift out leading zeros
					// and adjust exponent
					eout = eb - num_zeros ;
					mout = denorm_mout[22:0] << num_zeros ;
				end
			end // end subtract logic
			// format the output
			//fout = {sout, eout, mout} ;	
		end // end shift/add(sub)/normailize/
	end // always @(*) to compute sum/diff	
endmodule 
