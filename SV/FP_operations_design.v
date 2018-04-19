// --------------------------------------------------------------------
// --------------------------------------------------------------------
//
// Major Functions: 
// Floating Point Arithmetic:
// add, negate, multiply, inverse, sqrt,
//  10-bit int to float, float to 10-bit int
// --------------------------------------------------------------------
//
// --------------------------------------------------------------------
// Bruce R Land, Cornell University, Dec  2009
// Improved top module written by Adam Shapiro Oct 2009
// --------------------------------------------------------------------
module DE2_Top (

    // Clock Input
    input         CLOCK_27,    // 27 MHz
    input         CLOCK_50,    // 50 MHz
    input         EXT_CLOCK,   // External Clock
    // Push Button
    input  [3:0]  KEY,         // Pushbutton[3:0]
    // DPDT Switch
    input  [17:0] SW,          // Toggle Switch[17:0]
    // 7-SEG Display
    output [6:0]  HEX0,        // Seven Segment Digit 0
    output [6:0]  HEX1,        // Seven Segment Digit 1
    output [6:0]  HEX2,        // Seven Segment Digit 2
    output [6:0]  HEX3,        // Seven Segment Digit 3
    output [6:0]  HEX4,        // Seven Segment Digit 4
    output [6:0]  HEX5,        // Seven Segment Digit 5
    output [6:0]  HEX6,        // Seven Segment Digit 6
    output [6:0]  HEX7,        // Seven Segment Digit 7
    // LED
    output [8:0]  LEDG,        // LED Green[8:0]
    output [17:0] LEDR,        // LED Red[17:0]
    // UART
    output        UART_TXD,    // UART Transmitter
    input         UART_RXD,    // UART Receiver
    // IRDA
    output        IRDA_TXD,    // IRDA Transmitter
    input         IRDA_RXD,    // IRDA Receiver
    // SDRAM Interface
    inout  [15:0] DRAM_DQ,     // SDRAM Data bus 16 Bits
    output [11:0] DRAM_ADDR,   // SDRAM Address bus 12 Bits
    output        DRAM_LDQM,   // SDRAM Low-byte Data Mask 
    output        DRAM_UDQM,   // SDRAM High-byte Data Mask
    output        DRAM_WE_N,   // SDRAM Write Enable
    output        DRAM_CAS_N,  // SDRAM Column Address Strobe
    output        DRAM_RAS_N,  // SDRAM Row Address Strobe
    output        DRAM_CS_N,   // SDRAM Chip Select
    output        DRAM_BA_0,   // SDRAM Bank Address 0
    output        DRAM_BA_1,   // SDRAM Bank Address 0
    output        DRAM_CLK,    // SDRAM Clock
    output        DRAM_CKE,    // SDRAM Clock Enable
    // Flash Interface
    inout  [7:0]  FL_DQ,       // FLASH Data bus 8 Bits
    output [21:0] FL_ADDR,     // FLASH Address bus 22 Bits
    output        FL_WE_N,     // FLASH Write Enable
    output        FL_RST_N,    // FLASH Reset
    output        FL_OE_N,     // FLASH Output Enable
    output        FL_CE_N,     // FLASH Chip Enable
    // SRAM Interface
    inout  [15:0] SRAM_DQ,     // SRAM Data bus 16 Bits
    output [17:0] SRAM_ADDR,   // SRAM Address bus 18 Bits
    output        SRAM_UB_N,   // SRAM High-byte Data Mask 
    output        SRAM_LB_N,   // SRAM Low-byte Data Mask 
    output        SRAM_WE_N,   // SRAM Write Enable
    output        SRAM_CE_N,   // SRAM Chip Enable
    output        SRAM_OE_N,   // SRAM Output Enable
    // ISP1362 Interface
    inout  [15:0] OTG_DATA,    // ISP1362 Data bus 16 Bits
    output [1:0]  OTG_ADDR,    // ISP1362 Address 2 Bits
    output        OTG_CS_N,    // ISP1362 Chip Select
    output        OTG_RD_N,    // ISP1362 Write
    output        OTG_WR_N,    // ISP1362 Read
    output        OTG_RST_N,   // ISP1362 Reset
    output        OTG_FSPEED,  // USB Full Speed, 0 = Enable, Z = Disable
    output        OTG_LSPEED,  // USB Low Speed,  0 = Enable, Z = Disable
    input         OTG_INT0,    // ISP1362 Interrupt 0
    input         OTG_INT1,    // ISP1362 Interrupt 1
    input         OTG_DREQ0,   // ISP1362 DMA Request 0
    input         OTG_DREQ1,   // ISP1362 DMA Request 1
    output        OTG_DACK0_N, // ISP1362 DMA Acknowledge 0
    output        OTG_DACK1_N, // ISP1362 DMA Acknowledge 1
    // LCD Module 16X2
    inout  [7:0]  LCD_DATA,    // LCD Data bus 8 bits
    output        LCD_ON,      // LCD Power ON/OFF
    output        LCD_BLON,    // LCD Back Light ON/OFF
    output        LCD_RW,      // LCD Read/Write Select, 0 = Write, 1 = Read
    output        LCD_EN,      // LCD Enable
    output        LCD_RS,      // LCD Command/Data Select, 0 = Command, 1 = Data
    // SD Card Interface
    inout         SD_DAT,      // SD Card Data
    inout         SD_DAT3,     // SD Card Data 3
    inout         SD_CMD,      // SD Card Command Signal
    output        SD_CLK,      // SD Card Clock
    // I2C
    inout         I2C_SDAT,    // I2C Data
    output        I2C_SCLK,    // I2C Clock
    // PS2
    input         PS2_DAT,     // PS2 Data
    input         PS2_CLK,     // PS2 Clock
    // USB JTAG link
    input         TDI,         // CPLD -> FPGA (data in)
    input         TCK,         // CPLD -> FPGA (clk)
    input         TCS,         // CPLD -> FPGA (CS)
    output        TDO,         // FPGA -> CPLD (data out)
    // VGA
    output        VGA_CLK,     // VGA Clock
    output        VGA_HS,      // VGA H_SYNC
    output        VGA_VS,      // VGA V_SYNC
    output        VGA_BLANK,   // VGA BLANK
    output        VGA_SYNC,    // VGA SYNC
    output [9:0]  VGA_R,       // VGA Red[9:0]
    output [9:0]  VGA_G,       // VGA Green[9:0]
    output [9:0]  VGA_B,       // VGA Blue[9:0]
    // Ethernet Interface
    inout  [15:0] ENET_DATA,   // DM9000A DATA bus 16Bits
    output        ENET_CMD,    // DM9000A Command/Data Select, 0 = Command, 1 = Data
    output        ENET_CS_N,   // DM9000A Chip Select
    output        ENET_WR_N,   // DM9000A Write
    output        ENET_RD_N,   // DM9000A Read
    output        ENET_RST_N,  // DM9000A Reset
    input         ENET_INT,    // DM9000A Interrupt
    output        ENET_CLK,    // DM9000A Clock 25 MHz
    // Audio CODEC
    inout         AUD_ADCLRCK, // Audio CODEC ADC LR Clock
    input         AUD_ADCDAT,  // Audio CODEC ADC Data
    inout         AUD_DACLRCK, // Audio CODEC DAC LR Clock
    output        AUD_DACDAT,  // Audio CODEC DAC Data
    inout         AUD_BCLK,    // Audio CODEC Bit-Stream Clock
    output        AUD_XCK,     // Audio CODEC Chip Clock
    // TV Decoder
    input  [7:0]  TD_DATA,     // TV Decoder Data bus 8 bits
    input         TD_HS,       // TV Decoder H_SYNC
    input         TD_VS,       // TV Decoder V_SYNC
    output        TD_RESET,    // TV Decoder Reset
    // GPIO
    inout  [35:0] GPIO_0,      // GPIO Connection 0
    inout  [35:0] GPIO_1       // GPIO Connection 1
);

   //Turn off all displays.
   //assign HEX0 = 7'h7F;
   //assign HEX1 = 7'h7F;
   //assign HEX2 = 7'h7F;
   assign HEX3 = 7'h7F;
   //assign HEX4 = 7'h7F;
   ///assign HEX5 = 7'h7F;
   assign HEX6 = 7'h7F;
   assign HEX7 = 7'h7F;
 
    //assign LEDR = 18'h0;
    //assign LEDG = 9'h0;

   //Set all GPIO to tri-state.
   assign GPIO_0 = 36'hzzzzzzzzz;
   assign GPIO_1 = 36'hzzzzzzzzz;

   //Disable audio codec.
   //assign AUD_DACDAT = 1'b0;
   //assign AUD_XCK    = 1'b0;

   //Disable DRAM.
   assign DRAM_ADDR  = 12'h0;
   assign DRAM_BA_0  = 1'b0;
   assign DRAM_BA_1  = 1'b0;
   assign DRAM_CAS_N = 1'b1;
   assign DRAM_CKE   = 1'b0;
   assign DRAM_CLK   = 1'b0;
   assign DRAM_CS_N  = 1'b1;
   assign DRAM_DQ    = 16'hzzzz;
   assign DRAM_LDQM  = 1'b0;
   assign DRAM_RAS_N = 1'b1;
   assign DRAM_UDQM  = 1'b0;
   assign DRAM_WE_N  = 1'b1;

   //Disable Ethernet.
   assign ENET_CLK   = 1'b0;
   assign ENET_CS_N  = 1'b1;
   assign ENET_CMD   = 1'b0;
   assign ENET_DATA  = 16'hzzzz;
   assign ENET_RD_N  = 1'b1;
   assign ENET_RST_N = 1'b1;
   assign ENET_WR_N  = 1'b1;

   //Disable flash.
   assign FL_ADDR  = 22'h0;
   assign FL_CE_N  = 1'b1;
   assign FL_DQ    = 8'hzz;
   assign FL_OE_N  = 1'b1;
   assign FL_RST_N = 1'b1;
   assign FL_WE_N  = 1'b1;

   //Disable LCD.
   assign LCD_BLON = 1'b0;
   assign LCD_DATA = 8'hzz;
   assign LCD_EN   = 1'b0;
   assign LCD_ON   = 1'b0;
   assign LCD_RS   = 1'b0;
   assign LCD_RW   = 1'b0;

   //Disable OTG.
   assign OTG_ADDR    = 2'h0;
   assign OTG_CS_N    = 1'b1;
   assign OTG_DACK0_N = 1'b1;
   assign OTG_DACK1_N = 1'b1;
   assign OTG_FSPEED  = 1'b1;
   assign OTG_DATA    = 16'hzzzz;
   assign OTG_LSPEED  = 1'b1;
   assign OTG_RD_N    = 1'b1;
   assign OTG_RST_N   = 1'b1;
   assign OTG_WR_N    = 1'b1;

   //Disable SDRAM.
   assign SD_DAT = 1'bz;
   assign SD_CLK = 1'b0;

   //Disable SRAM.
   assign SRAM_ADDR = 18'h0;
   assign SRAM_CE_N = 1'b1;
   assign SRAM_DQ   = 16'hzzzz;
   assign SRAM_LB_N = 1'b1;
   assign SRAM_OE_N = 1'b1;
   assign SRAM_UB_N = 1'b1;
   assign SRAM_WE_N = 1'b1;

   //Disable VGA.
   assign VGA_CLK   = 1'b0;
   assign VGA_BLANK = 1'b0;
   assign VGA_SYNC  = 1'b0;
   assign VGA_HS    = 1'b0;
   assign VGA_VS    = 1'b0;
   assign VGA_R     = 10'h0;
   assign VGA_G     = 10'h0;
   assign VGA_B     = 10'h0;
   

   //Disable all other peripherals.
   //assign I2C_SCLK = 1'b0;
   assign IRDA_TXD = 1'b0;
   //assign TD_RESET = 1'b0;
   assign TDO = 1'b0;
   assign UART_TXD = 1'b0;
	
	// input on switches
	// form inverse * input == 1
	// output 1 to LEDs 0 10000001 100000000
	//                  s   exp     mantissa
	//                  17  16:9    8:0
	wire [17:0] f1, invsqrtout, multout1, multout2	;
	assign f1 = SW ;
	fpinvsqrt test1(invsqrtout, f1);
	fpmult test2(multout1, invsqrtout, f1) ; // sqrt
	fpmult test3(multout2, multout1, multout1); // original number input
	assign LEDR = (KEY[3])? invsqrtout : invsqrtout ; //button up => multout2
	//assign LEDG = invsqrtout[16:9] ; // sqrt mantissa
	
	wire [17:0] disp ;
	assign disp = KEY[1]? invsqrtout : SW ;
	HexDigit d0(HEX0, disp[3:0]) ;
	HexDigit d1(HEX1, disp[7:4]);
	HexDigit d2(HEX2, disp[8]);
	HexDigit d4(HEX4, disp[12:9]);
	HexDigit d5(HEX5, disp[16:13]);
	
	
	
endmodule

//////////////////////////////////////////////////////////
// floating point negate 
// -- sign bit -- 8-bit exponent -- 9-bit mantissa
// Similar to fp_mult from altera
// NO denorms, no flags, no NAN, no infinity, no rounding!
//////////////////////////////////////////////////////////
// f1 = {s1, e1, m1}
// flip the sign bit
///////////////////////////////////////////////////////////	
module fpneg(fout, f1) ;
	input [17:0] f1 ;
	output [17:0] fout ;
	assign fout = {~f1[17], f1[16:0]} ;
endmodule

//////////////////////////////////////////////////////////
// floating point multiply 
// -- sign bit -- 8-bit exponent -- 9-bit mantissa
// Similar to fp_mult from altera
// NO denorms, no flags, no NAN, no infinity, no rounding!
//////////////////////////////////////////////////////////
// f1 = {s1, e1, m1), f2 = {s2, e2, m2)
// If either is zero (zero MSB of mantissa) then output is zero
// If e1+e2<129 the result is zero (underflow)
///////////////////////////////////////////////////////////	
module fpmult (fout, f1, f2);

	input [17:0] f1, f2 ;
	output [17:0] fout ;
	
	wire [17:0] fout ;
	reg sout ;
	reg [8:0] mout ;
	reg [8:0] eout ; // 9-bits for overflow
	
	wire s1, s2;
	wire [8:0] m1, m2 ;
	wire [8:0] e1, e2, sum_e1_e2 ; // extend to 9 bits to avoid overflow
	wire [17:0] mult_out ;	// raw multiplier output
	
	// parse f1
	assign s1 = f1[17]; 	// sign
	assign e1 = {1'b0, f1[16:9]};	// exponent
	assign m1 = f1[8:0] ;	// mantissa
	// parse f2
	assign s2 = f2[17];
	assign e2 = {1'b0, f2[16:9]};
	assign m2 = f2[8:0] ;
	
	// first step in mult is to add extended exponents
	assign sum_e1_e2 = e1 + e2 ;
	
	// build output
	// raw integer multiply
	unsigned_mult mm(mult_out, m1, m2);
	 
	// assemble output bits
	assign fout = {sout, eout[7:0], mout} ;
	
	always @(*)
	begin
		// if either is denormed or exponents are too small
		if ((m1[8]==1'd0) || (m2[8]==1'd0) || (sum_e1_e2 < 9'h82)) 
		begin 
			mout = 0;
			eout = 0;
			sout = 0; // output sign
		end
		else // both inputs are nonzero and no exponent underflow
		begin
			sout = s1 ^ s2 ; // output sign
			if (mult_out[17]==1)
			begin // MSB of product==1 implies normalized -- result >=0.5
				eout = sum_e1_e2 - 9'h80;
				mout = mult_out[17:9] ;
			end
			else // MSB of product==0 implies result <0.5, so shift ome left
			begin
				eout = sum_e1_e2 - 9'h81;
				mout = mult_out[16:8] ;
			end	
		end // nonzero mult logic
	end // always @(*)
	
endmodule

///////////////////////////////////////
// low level integer multiply
// From Altera HDL style manual
///////////////////////////////////////
module unsigned_mult (out, a, b);
	output [17:0] out;
	input [8:0] a;
	input [8:0] b;
	assign out = a * b;
endmodule


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

	input [17:0] f1, f2 ;
	output [17:0] fout ;
	
	wire  [17:0] fout ;
	wire sout ;
	reg [8:0] mout ;
	reg [7:0] eout ;
	reg [9:0] shift_small, denorm_mout ; //9th bit is overflow bit
	
	wire s1, s2 ; // input signs
	reg  sb, ss ; // signs of bigger and smaller
	wire [8:0] m1, m2 ; // input mantissas
	reg  [8:0] mb, ms ; // mantissas of bigger and smaller
	wire [7:0] e1, e2 ; // input exp
	wire [7:0] ediff ;  // exponent difference
	reg  [7:0] eb, es ; // exp of bigger and smaller
	reg  [7:0] num_zeros ; // high order zeros in the difference calc
	
	// parse f1
	assign s1 = f1[17]; 	// sign
	assign e1 = f1[16:9];	// exponent
	assign m1 = f1[8:0] ;	// mantissa
	// parse f2
	assign s2 = f2[17];
	assign e2 = f2[16:9];
	assign m2 = f2[8:0] ;
	
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
		if ((ms[8]==0) && (mb[8]==0))  // both inputs are zero
		begin
			mout = 9'b0 ;
			eout = 8'b0 ; 
		end
		else if ((ms[8]==0) || ediff>8)  // smaller is too small to matter
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
				if (denorm_mout[9]==1) // sum bigger than 1
				begin
					mout = denorm_mout[9:1] ; // take the top bits (shift-right)
					eout = eb + 1 ; // compensate for the shift-right
				end
				else //0.5<sum<1.0
				begin
					mout = denorm_mout[8:0] ; // drop the top bit (no-shift-right)
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
				if (denorm_mout[8:0]==9'd0)
				begin
					mout = 9'b0 ;
					eout = 8'b0 ;
				end
				else
				begin
					// detect leading zeros
					casex (denorm_mout[8:0])
						9'b1xxxxxxxx: num_zeros = 8'd0 ;
						9'b01xxxxxxx: num_zeros = 8'd1 ;
						9'b001xxxxxx: num_zeros = 8'd2 ;
						9'b0001xxxxx: num_zeros = 8'd3 ;
						9'b00001xxxx: num_zeros = 8'd4 ;
						9'b000001xxx: num_zeros = 8'd5 ;
						9'b0000001xx: num_zeros = 8'd6 ;
						9'b00000001x: num_zeros = 8'd7 ;
						9'b000000001: num_zeros = 8'd8 ;
						default:       num_zeros = 8'd9 ;
					endcase	
					// shift out leading zeros
					// and adjust exponent
					eout = eb - num_zeros ;
					mout = denorm_mout[8:0] << num_zeros ;
				end
			end // end subtract logic
			// format the output
			//fout = {sout, eout, mout} ;	
		end // end shift/add(sub)/normailize/
	end // always @(*) to compute sum/diff	
endmodule 

/////////////////////////////////////////////////////////////////////////////
// integer to floating point  
// input: 10-bit signed integer and scale factor (-100 to +100) powers of 2
// output: -- sign bit -- 8-bit exponent -- 9-bit mantissa 
// fp_out = {sign, exp, mantissa}
// NO denorms, no flags, no NAN, no infinity, no rounding!
/////////////////////////////////////////////////////////////////////////////
module int2fp(fp_out, int_in, scale_in) ;
	input signed  [9:0] int_in ;
	input signed  [7:0] scale_in ;
	output wire [17:0] fp_out ; 
	
	wire [9:0] abs_int ;
	reg sign ;
	reg [8:0] mout ; // mantissa
	reg [7:0] eout ; // exponent
	reg [7:0] num_zeros ; // count leading zeros in input integer
	
	// get absolute value of int_in
	assign abs_int = (int_in[9])? (~int_in)+10'd1 : int_in ;
	
	// build output
	assign fp_out = {sign, eout, mout} ;
	 
	// detect leading zeros of absolute value
	// detect leading zeros
	// normalize and form exponent including leading zero shift and scaling
	always @(*)
	begin
		if (abs_int[8:0] == 0)
		begin // zero value
			eout = 0 ;
			mout = 0 ;
			sign = 0 ;
			num_zeros = 8'd0 ;
		end 
		else // not zero
		begin
			casex (abs_int[8:0])
				9'b1xxxxxxxx: num_zeros = 8'd0 ;
				9'b01xxxxxxx: num_zeros = 8'd1 ;
				9'b001xxxxxx: num_zeros = 8'd2 ;
				9'b0001xxxxx: num_zeros = 8'd3 ;
				9'b00001xxxx: num_zeros = 8'd4 ;
				9'b000001xxx: num_zeros = 8'd5 ;
				9'b0000001xx: num_zeros = 8'd6 ;
				9'b00000001x: num_zeros = 8'd7 ;
				9'b000000001: num_zeros = 8'd8 ;
				default:       num_zeros = 8'd9 ;
			endcase 
			mout = abs_int[8:0] << num_zeros ; 
			eout = scale_in + (8'h89 - num_zeros) ; // h80 is offset, h09 normalizes
			sign = int_in[9] ;
		end // if int_in!=0
	end // always @
	
endmodule

/////////////////////////////////////////////////////////////////////////////
// floating point to integer 
// output: 10-bit signed integer 
// input: -- sign bit -- 8-bit exponent -- 9-bit mantissa 
// and scale factor (-100 to +100) powers of 2
// fp_out = {sign, exp, mantissa}
// NO denorms, no flags, no NAN, no infinity, no rounding!
/////////////////////////////////////////////////////////////////////////////
module fp2int(int_out, fp_in, scale_in) ;
	output signed  [9:0] int_out ;
	input signed  [7:0] scale_in ;
	input wire [17:0] fp_in ; 
	
	wire [9:0] abs_int ;
	wire sign ;
	wire [8:0] m_in ; // mantissa
	wire [7:0] e_in ; // exponent
	
	//reg [7:0] num_zeros ; // count leading zeros in input integer
	
	assign sign = (m_in[8])? fp_in[17] : 1'h0 ;
	assign m_in = fp_in[8:0] ;
	assign e_in = fp_in[16:9] ;
	//
	assign abs_int = (e_in>8'h80)? (m_in >> (8'h89 - e_in)) : 10'd0 ;
	//assign int_out = (m_in[8])? {sign, (sign? (~abs_int)+9'd1 : abs_int)} : 10'd0 ;
	
	assign int_out = (sign? (~abs_int)+10'd1 : abs_int)  ;
	//assign int_out = {sign, sign? (~abs_int)+9'd1 : abs_int}  ;
endmodule

//////////////////////////////////////////////////////////
// floating point reciprocal  (invert)
// -- sign bit -- 8-bit exponent -- 9-bit mantissa
//
// NO denorms, no flags, no NAN, no infinity, no rounding!
//////////////////////////////////////////////////////////
// f1 = {s1, e1, m1)
// If f1 is zero, set output to max number (about 1e38)
///////////////////////////////////////////////////////////	
module fpinv (fout, f1);

	input [17:0] f1 ;
	output [17:0] fout ;
	
	wire [17:0] fout ;
	reg sout ;
	reg [8:0] mout ;
	reg [8:0] eout ; // 9-bits for overflow
	
	wire s1;
	wire [8:0] m1 ;
	wire [8:0] e1 ; // extend to 9 bits to avoid overflow
	wire [17:0] inv_out ;	// 
	
	// parse f1
	assign s1 = f1[17]; 	// sign
	assign e1 = {1'b0, f1[16:9]};	// exponent
	assign m1 = f1[8:0] ;	// mantissa
	
	// assemble output bits from 'always @' below
	assign fout = {sout, eout[7:0], mout} ;
	
	// newton iteration: linear approx + 2 steps
	// x0 = T1 - 2*input (input 0.5<=input<=1.0
	// x1 = x0*(2-input*x0)
	// x2 = x1*(2-input*x1)
	// from http://en.wikipedia.org/wiki/Division_%28digital%29
	wire [17:0] x0, x1, x2, reduced_input, reduced_input_x_2 ;
	wire [17:0] input_x_x0, input_x_x1 ;
	wire [17:0] two_minus_input_x_x0, two_minus_input_x_x1 ;
	
	parameter T1 = 18'h10575 ; // T1=2.9142
	parameter two = {1'b0, 8'h82, 9'h100} ;
	
	// form (T1-2*input)
	// BUT limit input range on 0.5 to 1.0 (just the mantissa)
	// THEN mult by two by setting exp to 8'h81
	// AND make it negative by setting the sign bit
	assign reduced_input = {1'b1, 8'h80, m1} ;
	assign reduced_input_x_2 = {1'b1, 8'h81, m1} ;
	fpadd init_newton(x0, reduced_input_x_2, T1) ;
	
	// form x1 = x0*(2-input*x0)
	fpmult newton11(input_x_x0, reduced_input, x0) ;
	fpadd newton12(two_minus_input_x_x0, two, input_x_x0);
	fpmult newton13(x1, x0, two_minus_input_x_x0) ;
	
	// form x2 = x1*(2-input*x1)
	fpmult newton21(input_x_x1, reduced_input, x1) ;
	fpadd newton22(two_minus_input_x_x1, two, input_x_x1);
	fpmult newton23(x2, x1, two_minus_input_x_x1) ;
	
	// select between zero and nonzero input
	always @(*)
	begin
		// if input is zero
		if (m1[8]==1'd0) 
		begin 
			// make the biggest possible output
			mout = 9'h100 ; 
			eout = 9'h0ff ;
			sout = 0; // output sign
		end
		
		else // input is nonzero 
		begin 
			eout = (m1==9'b100000000)? 9'h102 - e1 : 9'h101 - e1 ; // h81+(h81-e1)
			sout = s1; // output sign
			mout = x2[8:0] ; // the newton result		
		end // input is nonzero
	end
endmodule

//////////////////////////////////////////////////////////
// floating point reciprocal sqrt (invsqrt)
// -- sign bit -- 8-bit exponent -- 9-bit mantissa
// returns 1/sqrt(f1)
// NO denorms, no flags, no NAN, no infinity, no rounding!
//////////////////////////////////////////////////////////
// f1 = {s1, e1, m1)
// If f1 is zero, set output to zero
// If f1 is negative, ignore sign
///////////////////////////////////////////////////////////	
module fpinvsqrt (fout, f1);

	input [17:0] f1 ;
	output [17:0] fout ;
	
	wire [17:0] fout ;
	reg sout ;
	reg [8:0] mout ;
	reg [8:0] eout ; // 9-bits for overflow
	
	wire s1;
	wire [8:0] m1 ;
	wire [8:0] e1 ; // extend to 9 bits to avoid overflow
	wire [17:0] inv_out ;	// 
	
	// parse f1
	assign s1 = f1[17]; 	// sign
	assign e1 = {1'b0, f1[16:9]};	// exponent
	assign m1 = f1[8:0] ;	// mantissa
	
	// assemble output bits from 'always @' below
	assign fout = {sout, eout[7:0], mout} ;
	
	// newton iteration: linear approx + 2 steps
	// x0 = 2.05 - input  with (input 0.25<=input<=1.0)
	// x1 = x0/2 * (3 - input*x0*x0)
	// x2 = x1/2 * (3 - input*x1*x1)
	// from http://en.wikipedia.org/wiki/Division_%28digital%29
	wire [17:0] x0, x1, x2, reduced_input  ;
	wire [17:0] input_x_x0, input_x_x1 ;
	wire [17:0] input_x_x0_x0, input_x_x1_x1 ;
	wire [17:0] three_minus_input_x_x0_x0, three_minus_input_x_x1_x1 ;
	wire [7:0] input_exp ;
	
	parameter T1 = 18'h10506 ; // T1=2.05
	parameter three = {1'b0, 8'h82, 9'h180} ;
	
	// form (T1-input)
	// BUT limit input range on 0.25 to 1.0 (just the mantissa)
	// to get a range from 1/4 to 1, we need to be able to set
	// the exponent to either 0h7f or 0h80 so that two powers of
	// 2 at the input map to one at the output
	assign input_exp = (e1[0]==1)? 8'h7f : 8'h80 ;
	assign reduced_input = {1'b0, input_exp, m1} ;
	fpadd init_newton(x0, {1'b1, reduced_input[16:0]} , T1) ;
	
	// form x1 = x0/2 * (3 - input*x0*x0)
	fpmult newton11(input_x_x0, reduced_input, x0) ;
	fpmult newton12(input_x_x0_x0, input_x_x0, x0) ;
	fpadd newton13(three_minus_input_x_x0_x0, 
			three, 
			{~input_x_x0_x0[17], input_x_x0_x0[16:0]});
	fpmult newton14(x1, 
			{x0[17], x0[16:9]-8'd1, x0[8:0]}, 
			three_minus_input_x_x0_x0) ;
	
	// form x2 = x1/2 * (3 - input*x1*x1)
	fpmult newton21(input_x_x1, reduced_input, x1) ;
	fpmult newton22(input_x_x1_x1, input_x_x1, x1) ;
	fpadd newton23(three_minus_input_x_x1_x1, 
			three, 
			{~input_x_x1_x1[17], input_x_x1_x1[16:0]});
	fpmult newton24(x2, 
			{x1[17], x1[16:9]-8'd1, x1[8:0]}, 
			three_minus_input_x_x1_x1) ;
	
	// select between zero and nonzero input
	always @(*)
	begin
		// if input is zero
		if (m1[8]==1'd0) 
		begin 
			// make the biggest possible output
			mout = 9'h000 ; 
			eout = 9'h000 ;
			sout = 0; // output sign
		end
		
		else if (m1==9'b100000000 && e1[0]==1)
		begin 
			eout = 9'h82 + ((9'h80 - e1)>>1) ; // 
			sout = 1'b0; // output sign is ALWAYS +
			mout = 9'b100000000 ; // exactly 2		
		end // 
		
		else // input is nonzero 
		begin 
			eout = 9'h81 + ((9'h80 - e1)>>1) ; // 
			sout = 1'b0; // output sign is ALWAYS +
			mout = x2[8:0] ; // the newton result		
		end // input is nonzero
	end
endmodule

/////////////////////////////////////////////////
// Decode one hex digit for LED 7-seg display
//////////////////////////////////////////////////
module HexDigit(segs, num);
	input [3:0] num	;		//the hex digit to be displayed
	output [6:0] segs ;		//actual LED segments
	reg [6:0] segs ;
	always @ (num)
	begin
		case (num)
				4'h0: segs = 7'b1000000;
				4'h1: segs = 7'b1111001;
				4'h2: segs = 7'b0100100;
				4'h3: segs = 7'b0110000;
				4'h4: segs = 7'b0011001;
				4'h5: segs = 7'b0010010;
				4'h6: segs = 7'b0000010;
				4'h7: segs = 7'b1111000;
				4'h8: segs = 7'b0000000;
				4'h9: segs = 7'b0010000;
				4'ha: segs = 7'b0001000;
				4'hb: segs = 7'b0000011;
				4'hc: segs = 7'b1000110;
				4'hd: segs = 7'b0100001;
				4'he: segs = 7'b0000110;
				4'hf: segs = 7'b0001110;
				default segs = 7'b1111111;
		endcase
	end
endmodule
///////////////////////////////////////////////

// end file ///////////////////////////////////