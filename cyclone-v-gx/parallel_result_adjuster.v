module parallel_result_adjuster #(
    parameter ROWS = 12,
    parameter DATA_WIDTH = 64
)(
    input wire clk,                                   // Clock
    input wire reset,                                 // Reset
    input wire en,                                 // Start signal
	 input [DATA_WIDTH-1:0] inner_Res0,
	 input [DATA_WIDTH-1:0] inner_Res1,
	 input [DATA_WIDTH-1:0] inner_Res2,
	 input [DATA_WIDTH-1:0] inner_Res3,
	 input [DATA_WIDTH-1:0] inner_Res4,
	 input [DATA_WIDTH-1:0] inner_Res5,
	 input [DATA_WIDTH-1:0] inner_Res6,
	 input [DATA_WIDTH-1:0] inner_Res7,
	 input [DATA_WIDTH-1:0] inner_Res8,
	 input [DATA_WIDTH-1:0] inner_Res9,
	 input [DATA_WIDTH-1:0] inner_Res10,
	 input [DATA_WIDTH-1:0] inner_Res11,
	 input [DATA_WIDTH-1:0] last_diagonal,
	 output reg [DATA_WIDTH-1:0] inner_Res0_out,
	 output reg [DATA_WIDTH-1:0] inner_Res1_out,
	 output reg [DATA_WIDTH-1:0] inner_Res2_out,
	 output reg [DATA_WIDTH-1:0] inner_Res3_out,
	 output reg [DATA_WIDTH-1:0] inner_Res4_out,
	 output reg [DATA_WIDTH-1:0] inner_Res5_out,
	 output reg [DATA_WIDTH-1:0] inner_Res6_out,
	 output reg [DATA_WIDTH-1:0] inner_Res7_out,
	 output reg [DATA_WIDTH-1:0] inner_Res8_out,
	 output reg [DATA_WIDTH-1:0] inner_Res9_out,
	 output reg [DATA_WIDTH-1:0] inner_Res10_out,
	 output reg [DATA_WIDTH-1:0] inner_Res11_out,
    output reg condition1_triggered,
    output reg condition2_triggered,
    output reg done
);

    // State encoding
	 localparam IDLE             = 3'b000,
				  DO_CONDITION1    = 3'b001,
				  CHECK_CONDITION2 = 3'b010,
				  NEXT_INDEX       = 3'b011,
				  OPER_DONE        = 3'b100;

    //reg [2:0] current_state, next_state;
	 
	 reg [2:0] state;

    //reg [3:0] index;  // Input index (up to ROWS = 12, fits in 4 bits)
	 
	 reg [DATA_WIDTH-1:0] datab_zero = 0;
	 wire [11:0] aeb, alb;
	 //reg [11:0] active_aeb, active_alb;
	 integer i;
	 
	 
	 // inner_Resler parallel dividerdan cikan remainderlar
	 integer_comparator int_comparator0 (
		.dataa(inner_Res0),
		.datab(datab_zero),
		.aeb(aeb[0]),
		.alb(alb[0])
	 );
	 
	 integer_comparator int_comparator1 (
		.dataa(inner_Res1),
		.datab(datab_zero),
		.aeb(aeb[1]),
		.alb(alb[1])
	 );
	 
	 integer_comparator int_comparator2 (
		.dataa(inner_Res2),
		.datab(datab_zero),
		.aeb(aeb[2]),
		.alb(alb[2])
	 );
	 
	 integer_comparator int_comparator3 (
		.dataa(inner_Res3),
		.datab(datab_zero),
		.aeb(aeb[3]),
		.alb(alb[3])
	 );

	 integer_comparator int_comparator4 (
		.dataa(inner_Res4),
		.datab(datab_zero),
		.aeb(aeb[4]),
		.alb(alb[4])
	 );

	 integer_comparator int_comparator5 (
		.dataa(inner_Res5),
		.datab(datab_zero),
		.aeb(aeb[5]),
		.alb(alb[5])
	 );

	 integer_comparator int_comparator6 (
		.dataa(inner_Res6),
		.datab(datab_zero),
		.aeb(aeb[6]),
		.alb(alb[6])
	 );

	 integer_comparator int_comparator7 (
		.dataa(inner_Res7),
		.datab(datab_zero),
		.aeb(aeb[7]),
		.alb(alb[7])
	 );

	 integer_comparator int_comparator8 (
		.dataa(inner_Res8),
		.datab(datab_zero),
		.aeb(aeb[8]),
		.alb(alb[8])
	 );

	 integer_comparator int_comparator9 (
		.dataa(inner_Res9),
		.datab(datab_zero),
		.aeb(aeb[9]),
		.alb(alb[9])
	 );
	 
	 integer_comparator int_comparator10 (
		.dataa(inner_Res10),
		.datab(datab_zero),
		.aeb(aeb[10]),
		.alb(alb[10])
	 );
	 
	 
	 assign alb[11] = 1'b0;
	 
	 /*integer_comparator int_comparator11 (
		.dataa(inner_Res11),
		.datab(datab_zero),
		.aeb(aeb[11]),
		.alb(alb[11])
	 );*/
	 
	 always @(*) begin
			if (reset) begin
				condition1_triggered = 1'b0;
				condition2_triggered = 1'b0;
			end else begin	
				
				/*active_alb[0] = (ROWS > 1) ? alb[0] : 1'b0;
				active_alb[1] = (ROWS > 2) ? alb[1] : 1'b0;
				active_alb[2] = (ROWS > 3) ? alb[2] : 1'b0;
				active_alb[3] = (ROWS > 4) ? alb[3] : 1'b0;
				active_alb[4] = (ROWS > 5) ? alb[4] : 1'b0;
				active_alb[5] = (ROWS > 6) ? alb[5] : 1'b0;
				active_alb[6] = (ROWS > 7) ? alb[6] : 1'b0;
				active_alb[7] = (ROWS > 8) ? alb[7] : 1'b0;
				active_alb[8] = (ROWS > 9) ? alb[8] : 1'b0;
				active_alb[9] = (ROWS > 10) ? alb[9] : 1'b0;
				active_alb[10] = (ROWS > 11) ? alb[10] : 1'b0;
				//active_alb[11] = (ROWS < 13) ? alb[11] : 1'b0;
				active_alb[11] = 1'b0;*/
			
				condition1_triggered = |alb;	
				condition2_triggered = |aeb;
			end
	 end
	 
	 always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 0;
				state <= 3'b000;
				
				inner_Res0_out  <= {DATA_WIDTH{1'b0}};
				inner_Res1_out  <= {DATA_WIDTH{1'b0}};
				inner_Res2_out  <= {DATA_WIDTH{1'b0}};
				inner_Res3_out  <= {DATA_WIDTH{1'b0}};
				inner_Res4_out  <= {DATA_WIDTH{1'b0}};
				inner_Res5_out  <= {DATA_WIDTH{1'b0}};
				inner_Res6_out  <= {DATA_WIDTH{1'b0}};
				inner_Res7_out  <= {DATA_WIDTH{1'b0}};
				inner_Res8_out  <= {DATA_WIDTH{1'b0}};
				inner_Res9_out  <= {DATA_WIDTH{1'b0}};
				inner_Res10_out <= {DATA_WIDTH{1'b0}};
				inner_Res11_out <= {DATA_WIDTH{1'b0}};
				
			end else begin
					case (state) 
					
						IDLE: begin
							if (en) begin
							  done <= 0;
							  
							  inner_Res0_out  <= (alb[0])  ? (inner_Res0  + last_diagonal) : inner_Res0;
							  inner_Res1_out  <= (alb[1])  ? (inner_Res1  + last_diagonal) : inner_Res1;
							  inner_Res2_out  <= (alb[2])  ? (inner_Res2  + last_diagonal) : inner_Res2;
							  inner_Res3_out  <= (alb[3])  ? (inner_Res3  + last_diagonal) : inner_Res3;
							  inner_Res4_out  <= (alb[4])  ? (inner_Res4  + last_diagonal) : inner_Res4;
							  inner_Res5_out  <= (alb[5])  ? (inner_Res5  + last_diagonal) : inner_Res5;
							  inner_Res6_out  <= (alb[6])  ? (inner_Res6  + last_diagonal) : inner_Res6;
							  inner_Res7_out  <= (alb[7])  ? (inner_Res7  + last_diagonal) : inner_Res7;
							  inner_Res8_out  <= (alb[8])  ? (inner_Res8  + last_diagonal) : inner_Res8;
							  inner_Res9_out  <= (alb[9])  ? (inner_Res9  + last_diagonal) : inner_Res9;
							  inner_Res10_out <= (alb[10]) ? (inner_Res10 + last_diagonal) : inner_Res10;
							  inner_Res11_out <= (alb[11]) ? (inner_Res11 + last_diagonal) : inner_Res11;
							  
							  if (condition1_triggered)
									state <= DO_CONDITION1;
							end
						end
					
					endcase
					
			end
	 end

endmodule
