/////////////////////////////////////////////////////////////////////////////
// floating point to integer 
// output: 10-bit signed integer 
// input: -- sign bit -- 8-bit exponent -- 9-bit mantissa 
// and scale factor (-100 to +100) powers of 2
// fp_out = {sign, exp, mantissa}
// NO denorms, no flags, no NAN, no infinity, no rounding!
/////////////////////////////////////////////////////////////////////////////
module fp2int(int_out, fp_in) ;
	output signed  [9:0] int_out ;
	input wire [31:0] fp_in ; 
	
	wire [9:0] abs_int ;
	wire sign ;
	wire [8:0] m_in ; // mantissa
	wire [7:0] e_in ; // exponent
	
	//reg [7:0] num_zeros ; // count leading zeros in input integer
	
	assign sign = (m_in[8])? fp_in[31] : 1'h0 ;
	assign m_in = fp_in[22:14] ;
	assign e_in = fp_in[30:23] ;
	//
	assign abs_int = (e_in>8'h80)? (m_in >> (8'h89 - e_in)) : 10'd0 ;
	//assign int_out = (m_in[8])? {sign, (sign? (~abs_int)+9'd1 : abs_int)} : 10'd0 ;
	
	assign int_out = (sign? (~abs_int)+10'd1 : abs_int)  ;
	//assign int_out = {sign, sign? (~abs_int)+9'd1 : abs_int}  ;
endmodule





/****************************************************************************
 * floating point to integer															    *
 * 															  									 *
 * ADAPTED FROM															  					 * 
 * https://electronics.stackexchange.com/questions/157185/						 *
 * convert-ieee-double-to-integer-verilog												 *
 * *************************************************************************/

module fp2int_pos(
    input clk,
    input rst,
    input [31:0] vin,
    output reg [31:0] vout,
    output reg done,
    output reg error
    );

    wire sign = vin[31];
    wire [7:0] exponent = vin[30:23];
    wire [22:0] binaryfraction = vin[22:0];
    wire [53:0] mantissa = {1'b1,binaryfraction};

    reg [5:0] cnt;
    reg start = 1'b0;
    reg round;
    always @(posedge clk) begin
        if (rst) begin
            if (sign==1'b0 && exponent >= 8'd127 && exponent <= 8'd158) begin
            // only convert positive numbers between 0 and 2^31
                cnt <= 23 - (exponent - 8'd127); // how many bits to discard from mantissa
                {vout,round} <= {mantissa,1'b0};
                start <= 1'b1;
                done <= 1'b0;
                error <= 1'b0;
            end
            else begin
                start <= 1'b0;
                error <= 1'b1;
            end
        end
        else if (start) begin
            if (cnt != 0) begin  // not finished yet?
                cnt <= cnt - 1;  // count one bit to discard
                {vout,round} <= {1'b0, vout[31:0]}; // and discard it (bit just discarded goes into "round")
            end
            else begin  // finished discarding bits then?
                if (round)  // if last bit discarded was high, increment vout
                    vout <= vout + 1;
                start <= 1'b0;
                done <= 1'b1; // signal we're done
            end
        end
    end
endmodule
