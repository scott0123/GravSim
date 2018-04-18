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
module FpInvSqrt (
    input             iCLK,
    input      [26:0] iA,
    output     [26:0] oInvSqrt
);

    // Extract fields of A and B.
    wire        A_s;
    wire [7:0]  A_e;
    wire [17:0] A_f;
    assign A_s = iA[26];
    assign A_e = iA[25:18];
    assign A_f = iA[17:0];

    //Stage 1
    wire [26:0] y_1, y_1_out, half_iA_1;
    assign y_1 = 27'd49920718 - (iA>>1);
    assign half_iA_1 = {A_s, A_e-8'd1,A_f};
    FpMul s1_mult ( .iA(y_1), .iB(y_1), .oProd(y_1_out) );
    //Stage 2
    reg [26:0] y_2, mult_2_in, half_iA_2;
    wire [26:0] y_2_out;
    FpMul s2_mult ( .iA(half_iA_2), .iB(mult_2_in), .oProd(y_2_out) );
    //Stage 3
    reg [26:0] y_3, add_3_in;
    wire [26:0] y_3_out;
    FpAdd s3_add ( .iCLK(iCLK), .iA({~add_3_in[26],add_3_in[25:0]}), .iB(27'd33423360), .oSum(y_3_out) );
    //Stage 4
    reg [26:0] y_4;
    //Stage 5
    reg [26:0] y_5, mult_5_in;
    FpMul s5_mult ( .iA(y_5), .iB(mult_5_in), .oProd(oInvSqrt) );

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
module FpMult (
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


/**************************************************************************
 * Floating Point Adder                                                   *
 * 2-stage pipeline                                                       *
 *************************************************************************/
module FPU (
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

    // Detect underflow
    wire underflow;
    assign underflow = ~oSum_e[7] && buf_larger_exp[7] && (shft_amt != 8'b0);

    assign oSum = (buf_A_e_zero && buf_B_e_zero)   ? 32'b0 :
                  buf_A_e_zero                     ? buf_B :
                  buf_B_e_zero                     ? buf_A :
                  underflow                        ? 32'b0 :
                  (pre_frac == 0)                  ? 32'b0 :
                  {buf_oSum_s, oSum_e, oSum_f};
						// sign bit + exponent + fraction
						//    1     +   8      +    23

endmodule
