module datapath #(
	 parameter DATA_WIDTH = 64,  // Width of the data
    parameter ADDR_WIDTH = 9,    // Address width (512 words => 9-bit address)
	 parameter ARRAY_LENGTH = 11, // max input boyutu 12
	 parameter ROWS = 12
)(
	input clk,
	input reset,
	input go_i,
	
	input [3:0] NUMBER_OF_CONES,
	
	// register operations
	input ld_int_add_sub_res_reg,
	input ld_int_mult_res_reg,
	
	input ld_rows_minus_one,
	input ld_each_cone_size,
	input ld_each_cone,
	input ld_V_index,
	input ld_temp_V_index,
	input ld_init_temp_V_index,
	input ld_Uinv_index,
	input ld_temp_Uinv_index,
	input ld_Winv_index,
	input ld_temp_Winv_index,
	input ld_init_temp_Winv_index,
	input ld_q_index,
	input ld_s_index,
	input ld_o_index,
	input ld_last_diagonal,
	input ld_prime_diagonals,
	input ld_q_summand,
	input ld_q_hat,
	input ld_q_trans,
	input ld_inner_Res,
	input ld_v_inner,
	input ld_int_comparator_aeb_reg,
	input ld_total_point_count,
	input ld_outer,
	input ld_result_point,
	input ld_point_count,
	input ld_i,
	input ld_j,
	input ld_divider_counter,
	
	// clear
	input clear_i,
	input clear_j,
	input clear_divider_counter,
	
	// array operations
	input clear_point_count,
	input clear_outer,
	input clear_inner_Res,
	input clear_arrays,
	
	// mux
	input [1:0] int_mult_dataa_sel,
	input [1:0] int_mult_datab_sel,
	input [3:0] int_add_sub_dataa_sel,
	input [3:0] int_add_sub_datab_sel,
	input int_add_sub_add_sub_sel,
	input [2:0] int_comparator_dataa_sel,
	input [2:0] int_comparator_datab_sel,
	input int_comparator_dataa_i0_sel,
	input int_comparator_dataa_i1_sel,
	input int_comparator_datab_i0_sel,
	input int_comparator_datab_i1_sel,
	input int_comparator_datab_i3_sel,
	input [1:0] int_divider_numer_sel,
	input [1:0] int_divider_denom_sel,
	input int_divider_clken,
	input [2:0] inner_Res_sel,
	input i_sel,
	input v_inner_sel,
	
	// input_array operations
	input [1:0] input_array_address_a_sel,
	input [1:0] input_array_address_b_sel,
	input input_array_wren_a,
	input input_array_wren_b,
	
	input do_parallel_multiplication,
	input clear_parallel_multiplication_results,
	//input increment_temp_Winv_index,
	input parallel_multiplication_second_operand_sel,
	input [1:0] q_array_address_sel,
	input int_parallel_add_first_operand_sel,
	
	input ram_module_input_array_rst,
	input ram_module_input_array_en,
	
	input clear_numerators,
	input assign_numerators,
	input numerator_sel,
	input seq_loader_rst,
	input ld_remain_to_inner_Res,
	input ld_result_adjuster_to_inner_Res,
	input parallel_res_adj_rst,
	input parallel_res_adj_en,
	
	input [1:0] rows_mult_dataa_sel,
	input rows_mult_datab_sel,
	input ld_rows_mult_res_reg,
	
	output condition1_triggered,
	output condition2_triggered,
	
	// comparator signals
	output reg int_comparator_aeb,
	output reg int_comparator_alb,
	output reg int_comparator_not_alb,
	output j_index_comparator_alb,
	output reg inner_Res_and_input_array,
	
	output [31:0] fpga_total_point_count,
	
	output reg [95:0] to_hps
);



// REGISTERS
reg [3:0] ROWS_MINUS_ONE;
reg [63:0] prime_diagonals [0:ARRAY_LENGTH]; // 64-bit
reg [63:0] q_summand [0:ARRAY_LENGTH]; // 64-bit
reg [63:0] q_hat [0:ARRAY_LENGTH]; // 64-bit
reg [63:0] q_trans [0:ARRAY_LENGTH]; // 64-bit
reg [63:0] inner_Res [0:ARRAY_LENGTH]; // 64-bit
reg [63:0] outer [0:ARRAY_LENGTH]; // 64-bit

// her cone için sifirlanmali
reg [63:0] v_inner [0:ARRAY_LENGTH];
reg [63:0] q_int [0:ARRAY_LENGTH];

                  
// initialize zero at the beggining (sadece program basinda 0 yapiliyor)
reg [63:0] cone_start_index, point_count, total_point_count, each_cone;
assign fpga_total_point_count = total_point_count[31:0];

reg [63:0] each_cone_size;
reg [63:0] V_index, Uinv_index, Winv_index, q_index, s_index, o_index, last_diagonal;
reg [63:0] temp_V_index, temp_Uinv_index, temp_Winv_index;
reg [63:0] inner_Res_mux_out;

// registers required for 'for' loops
reg [63:0] i, j;

// divider counter
reg [63:0] divider_counter;

// 2 PORT RAM FOR input_array
reg [8:0] input_array_address_a, input_array_address_b;
reg [63:0] input_array_data_a, input_array_data_b;
wire [63:0] input_array_q_a, input_array_q_b;
reg [8:0] input_array_test_addr;

wire [767:0] input_array_q_array_out;

wire [63:0] data_out_0, data_out_1, data_out_2, data_out_3, data_out_4, data_out_5, data_out_6, data_out_7, data_out_8, data_out_9, data_out_10, data_out_11;
reg [ADDR_WIDTH-1:0] q_array_address;

reg[7:0] point_coord0, point_coord1, point_coord2, point_coord3;

reg [DATA_WIDTH-1:0] parallel_multiplication_results [0:ARRAY_LENGTH];

dual_port_ram input_array (
	.address_a(input_array_address_a),
	.address_b(input_array_address_b),
	.clk(clk),
	.data_a(input_array_data_a),
	.data_b(input_array_data_b),
	.wren_a(input_array_wren_a),
	.wren_b(input_array_wren_b),
	.q_a(input_array_q_a),
	.q_b(input_array_q_b),
	.ROWS(ROWS)
	//.q_array_address(q_array_address)
	//.input_array_q_array_out(input_array_q_array_out)
);

wire ram_module_input_array_ready;

ram_module ram_module_input_array(
    .clk(clk),
    .rst(ram_module_input_array_rst),               
    .addr_in(q_array_address),     // Başlangıç adresi, q_array_address ve input_array_address_a
    .en(ram_module_input_array_en),                // RAM okuma başlatma sinyali, cu dan gelecek
	 .wren(input_array_wren_a),
	 .data_in(input_array_data_a),
	 // 64-bit veri çıkışı
    .data_out_0(data_out_0),  
    .data_out_1(data_out_1),  
    .data_out_2(data_out_2),  
    .data_out_3(data_out_3),  
    .data_out_4(data_out_4),  
    .data_out_5(data_out_5),  
    .data_out_6(data_out_6),  
    .data_out_7(data_out_7),  
    .data_out_8(data_out_8),  
    .data_out_9(data_out_9),  
    .data_out_10(data_out_10),  
    .data_out_11(data_out_11),
    .ready(ram_module_input_array_ready)               // Verinin hazır olduğunu gösteren sinyal
);

// INTEGER MULTIPLIER
reg [63:0] int_mult_dataa, int_mult_datab;
reg [63:0] int_mult_res_reg; // 64-bit
wire [63:0] int_mult_res; // 64-bit

integer_multiplier int_mult(
	.dataa(int_mult_dataa),
	.datab(int_mult_datab),
	.result(int_mult_res)
	//.clock(clk)
);



//assign int_mult_res = int_mult_dataa * int_mult_datab;

// INTEGER ADDER SUBSTRACTOR
reg [63:0] int_add_sub_dataa, int_add_sub_datab, int_add_sub_res_reg;
wire [63:0] int_add_sub_res;
reg int_add_sub_add_sub; // :SSS
wire int_add_sub_overflow;

signed_adder_subtractor int_add_sub (
	.dataa(int_add_sub_dataa),
	.datab(int_add_sub_datab),
	.add_sub(int_add_sub_add_sub), // if this is 1, add; else subtract
	.result(int_add_sub_res)
);

// INTEGER ROWS MULTIPLIER
reg [8:0] rows_mult_dataa, rows_mult_datab, rows_mult_res_reg;
wire [8:0] rows_mult_res;

assign rows_mult_res = rows_mult_dataa * rows_mult_datab;

// INTEGER COMPARATOR == , < 
reg [63:0] int_comparator_dataa, int_comparator_datab, int_comparator_aeb_reg;
wire int_comparator_aeb_wire, int_comparator_alb_wire;

integer_comparator int_comparator (
	.dataa(int_comparator_dataa),
	.datab(int_comparator_datab),
	.aeb(int_comparator_aeb_wire),
	.alb(int_comparator_alb_wire)
);


index_comparator j_index_comparator(
	.dataa(j[3:0]),
	.datab(ROWS),
	.alb(j_index_comparator_alb)
);


// INTEGER DIVIDER

reg [39:0] int_divider_denom, int_divider_numer;
wire [39:0] int_divider_quotient, int_divider_remain;

integer_divider int_divider(
	.clken(int_divider_clken),
	.clock(clk),
	.denom(int_divider_denom),
	.numer(int_divider_numer),
	.quotient(int_divider_quotient),
	.remain(int_divider_remain)
	// asc clear gerekli mi?
);

wire [63:0] int_parallel_add_res;
//reg [63:0] int_parallel_add_first_operand;

integer_parallel_adder int_parallel_add(
	.data0x(parallel_multiplication_results[0]),
	.data1x(parallel_multiplication_results[1]),
	.data2x(parallel_multiplication_results[2]),
	.data3x(parallel_multiplication_results[3]),
	.data4x(parallel_multiplication_results[4]),
	.data5x(parallel_multiplication_results[5]),
	.data6x(parallel_multiplication_results[6]),
	.data7x(parallel_multiplication_results[7]),
	.data8x(parallel_multiplication_results[8]),
	.data9x(parallel_multiplication_results[9]),
	.data10x(parallel_multiplication_results[10]),
	.data11x(parallel_multiplication_results[11]),
	//.data12x(int_parallel_add_first_operand),
	//.data12x(64'b0),
	.result(int_parallel_add_res) // 68 bit
);

wire [39:0] quot0, quot1, quot2, quot3, quot4, quot5, quot6, quot7, quot8, quot9, quot10;
wire [39:0] remain0, remain1, remain2, remain3, remain4, remain5, remain6, remain7, remain8, remain9, remain10;
reg [39:0] num0, num1, num2, num3, num4, num5, num6, num7, num8, num9, num10;

parallel_divider pd(
    .clk(clk),
	 .clken(int_divider_clken),
    //input reset,
    .num0(num0), 
	 .num1(num1), 
	 .num2(num2), 
	 .num3(num3), 
	 .num4(num4), 
	 .num5(num5), 
	 .num6(num6), 
	 .num7(num7), 
	 .num8(num8), 
	 .num9(num9), 
	 .num10(num10),
	 .den(last_diagonal),
    .quot0(quot0),
    .quot1(quot1),
    .quot2(quot2),
    .quot3(quot3),
    .quot4(quot4),
    .quot5(quot5),
    .quot6(quot6),
    .quot7(quot7),
    .quot8(quot8),
    .quot9(quot9),
    .quot10(quot10),
	 .remain0(remain0),
	 .remain1(remain1),
	 .remain2(remain2),
	 .remain3(remain3),
	 .remain4(remain4),
	 .remain5(remain5),
	 .remain6(remain6),
	 .remain7(remain7),
	 .remain8(remain8),
	 .remain9(remain9),
	 .remain10(remain10)

	 /*output [39:0] remain0,
	 output [39:0] remain1,
	 output [39:0] remain2,
	 output [39:0] remain3*/
);

wire [DATA_WIDTH-1:0] inner_Res0_out, inner_Res1_out, inner_Res2_out, inner_Res3_out, inner_Res4_out, inner_Res5_out, 
		inner_Res6_out, inner_Res7_out, inner_Res8_out, inner_Res9_out, inner_Res10_out;
	
parallel_result_adjuster #(
    .ROWS(ROWS),
    .DATA_WIDTH(DATA_WIDTH)
) parallel_res_adj (
    .clk(clk),
    .reset(parallel_res_adj_rst),
    .en(parallel_res_adj_en),
	 
	 // birinci if için remainler gitmeli ikinci if içinse inner_Res duzelt
	 .inner_Res0({{24{remain0[39]}},  remain0}),
	 .inner_Res1({{24{remain1[39]}},  remain1}),
	 .inner_Res2({{24{remain2[39]}},  remain2}),
	 .inner_Res3({{24{remain3[39]}},  remain3}),
	 .inner_Res4({{24{remain4[39]}},  remain4}),
	 .inner_Res5({{24{remain5[39]}},  remain5}),
	 .inner_Res6({{24{remain6[39]}},  remain6}),
	 .inner_Res7({{24{remain7[39]}},  remain7}),
	 .inner_Res8({{24{remain8[39]}},  remain8}),
	 .inner_Res9({{24{remain9[39]}},  remain9}),
	 .inner_Res10({{24{remain10[39]}},  remain10}),
	 
	 .last_diagonal(last_diagonal),
	 
	 .inner_Res0_out(inner_Res0_out),
	 .inner_Res1_out(inner_Res1_out),
	 .inner_Res2_out(inner_Res2_out),
	 .inner_Res3_out(inner_Res3_out),
	 .inner_Res4_out(inner_Res4_out),
	 .inner_Res5_out(inner_Res5_out),
	 .inner_Res6_out(inner_Res6_out),
	 .inner_Res7_out(inner_Res7_out),
	 .inner_Res8_out(inner_Res8_out),
	 .inner_Res9_out(inner_Res9_out),
	 .inner_Res10_out(inner_Res10_out),

    .condition1_triggered(condition1_triggered),
    .condition2_triggered(condition2_triggered)
    //output reg done
);

reg result_point_ISMCE_wren;

sequential_loader #(
    .ROWS(ROWS)
) seq_loader (
    .clk(clk),
    .reset(seq_loader_rst),
    .en(result_point_ISMCE_wren),
	 .point_count(point_count),
    .data_in0(quot0),
    .data_in1(quot1),
    .data_in2(quot2),
    .data_in3(quot3),
    .data_in4(quot4),
    .data_in5(quot5),
    .data_in6(quot6),
    .data_in7(quot7),
    .data_in8(quot8),
    .data_in9(quot9),
    .data_in10(quot10)
    //output reg done                    
);

genvar index;

integer a;
always@(posedge clk) begin
	if(reset) begin
		cone_start_index <= 64'b0;
		point_count <= 64'b0;
		total_point_count <= 64'b0;
		each_cone <= 64'b0;
		input_array_test_addr <= 9'b0;
	end else begin
		if (ld_int_add_sub_res_reg)
			int_add_sub_res_reg <= int_add_sub_res;
		if (ld_int_mult_res_reg)
			int_mult_res_reg <= int_mult_res;
		if (ld_rows_mult_res_reg)
			rows_mult_res_reg <= rows_mult_res;
		if (ld_rows_minus_one)
			ROWS_MINUS_ONE <= int_add_sub_res[3:0];
		if (ld_each_cone_size)
			each_cone_size <= rows_mult_res;
		if (ld_each_cone)
			each_cone <= int_add_sub_res;
		if (ld_V_index)
			V_index <= cone_start_index;
	
		if (ld_temp_V_index && !ld_init_temp_V_index) begin
			temp_V_index <= int_add_sub_res;
		end else if (!ld_temp_V_index && ld_init_temp_V_index) begin
			temp_V_index <= V_index;
		end
			
		if (ld_Uinv_index)
			Uinv_index <= int_add_sub_res;
		if (ld_temp_Uinv_index)
			temp_Uinv_index <= int_add_sub_res;
		if (ld_Winv_index)
			Winv_index <= int_add_sub_res;
		
		if (ld_temp_Winv_index && !ld_init_temp_Winv_index) begin
			temp_Winv_index <= int_add_sub_res;
		end else if (!ld_temp_Winv_index && ld_init_temp_Winv_index) begin
			temp_Winv_index <= Winv_index;
		end
		
		if (ld_q_index)
			q_index <= int_add_sub_res;
		if (ld_s_index)
			s_index <= int_add_sub_res;
		if (ld_o_index)
			o_index <= int_add_sub_res;
		if (ld_last_diagonal)
			last_diagonal <= input_array_q_a;
		if (ld_prime_diagonals)
			prime_diagonals[i] <= int_divider_quotient;
		if (ld_int_comparator_aeb_reg)
			int_comparator_aeb_reg <= int_comparator_aeb_wire;
		if (ld_total_point_count)
			total_point_count <= int_add_sub_res;
		
		if (!ld_divider_counter && clear_divider_counter) begin
			divider_counter <= 64'b0;
		end else if (ld_divider_counter && !clear_divider_counter) begin
			divider_counter <= int_add_sub_res;
		end
			
		if (!ld_point_count && clear_point_count) begin
			point_count <= 64'b0;
		end else if (ld_point_count && !clear_point_count) begin
			point_count <= int_add_sub_res;
		end
			
		if (!ld_outer && clear_outer) begin
			for (a = 0; a <= ARRAY_LENGTH; a = a + 1) outer[a] <= 64'b0;
		end else if (ld_outer && !clear_outer) begin
			outer[i] <= int_parallel_add_res;
			//outer <= int_add_sub_res;
		end
			
		if (!ld_q_summand && clear_arrays) begin
			for (a = 0; a <= ARRAY_LENGTH; a = a + 1) q_summand[a] <= 64'b0;
		end else if (ld_q_summand && !clear_arrays) begin
			q_summand[i] <= int_mult_res;
		end
		
		if (!ld_q_hat && clear_arrays) begin
			for (a = 0; a <= ARRAY_LENGTH; a = a + 1) q_hat[a] <= 64'b0;
		end else if (ld_q_hat && !clear_arrays) begin
			q_hat[i] <= int_add_sub_res;
		end
		
		if (!ld_q_trans && clear_arrays) begin
			for (a = 0; a <= ARRAY_LENGTH; a = a + 1) q_trans[a] <= 64'b0;
		end else if (ld_q_trans && !clear_arrays) begin
			q_trans[i] <= int_add_sub_res;
		end
		
		if (!ld_v_inner && clear_arrays) begin
			for (a = 0; a <= ARRAY_LENGTH; a = a + 1) v_inner[a] <= 64'b0;
		end else if (ld_v_inner && !clear_arrays) begin
			if (v_inner_sel)
				v_inner[i] <= int_add_sub_res;
			else
				v_inner[i] <= 64'b0;
		end
	
		if (!ld_inner_Res && clear_inner_Res && !ld_remain_to_inner_Res && !ld_result_adjuster_to_inner_Res) begin
			for (a = 0; a <= ARRAY_LENGTH; a = a + 1) inner_Res[a] <= q_trans[a];
		end else if (ld_inner_Res && !clear_inner_Res && !ld_remain_to_inner_Res && !ld_result_adjuster_to_inner_Res) begin
			inner_Res[i] <= inner_Res_mux_out;
		end else if (!ld_inner_Res && !clear_inner_Res && ld_remain_to_inner_Res && !ld_result_adjuster_to_inner_Res) begin
			inner_Res[0]  <= {{24{remain0[39]}},  remain0};
			inner_Res[1]  <= {{24{remain1[39]}},  remain1};
			inner_Res[2]  <= {{24{remain2[39]}},  remain2};
			inner_Res[3]  <= {{24{remain3[39]}},  remain3};
			inner_Res[4]  <= {{24{remain4[39]}},  remain4};
			inner_Res[5]  <= {{24{remain5[39]}},  remain5};
			inner_Res[6]  <= {{24{remain6[39]}},  remain6};
			inner_Res[7]  <= {{24{remain7[39]}},  remain7};
			inner_Res[8]  <= {{24{remain8[39]}},  remain8};
			inner_Res[9]  <= {{24{remain9[39]}},  remain9};
			inner_Res[10] <= {{24{remain10[39]}}, remain10};
		end else if (!ld_inner_Res && !clear_inner_Res && !ld_remain_to_inner_Res && ld_result_adjuster_to_inner_Res) begin
			inner_Res[0]  <= inner_Res0_out;
			inner_Res[1]  <= inner_Res1_out;
			inner_Res[2]  <= inner_Res2_out;
			inner_Res[3]  <= inner_Res3_out;
			inner_Res[4]  <= inner_Res4_out;
			inner_Res[5]  <= inner_Res5_out;
			inner_Res[6]  <= inner_Res6_out;
			inner_Res[7]  <= inner_Res7_out;
			inner_Res[8]  <= inner_Res8_out;
			inner_Res[9]  <= inner_Res9_out;
			inner_Res[10] <= inner_Res10_out;
		end
		
		if (clear_i) begin
			i <= 64'b0;
		end else if (ld_i) begin
			if (i_sel)
				i <= ROWS_MINUS_ONE;
			else 
				i <= int_add_sub_res;
		end
		
		if (clear_j) begin
			j <= 64'b0;
		end else if (ld_j) begin
			j <= int_add_sub_res;
		end
		
	if (clear_parallel_multiplication_results & ~do_parallel_multiplication) begin
		//for (a = 0; a <= ARRAY_LENGTH; a = a + 1) begin parallel_multiplication_results[a] <= {DATA_WIDTH{1'b0}}; end
		parallel_multiplication_results[0] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[1] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[2] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[3] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[4] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[5] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[6] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[7] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[8] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[9] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[10] <= {DATA_WIDTH{1'b0}};
		parallel_multiplication_results[11] <= {DATA_WIDTH{1'b0}};
	end else if (~clear_parallel_multiplication_results & do_parallel_multiplication) begin
		// inner_Res[i] = inner_Res[i]  + input_array[Winv_index + i * ROWS + j] * v_inner[j];
		// outer = outer + input_array[V_index + i * ROWS + j] * inner_Res[j];
		parallel_multiplication_results[0]  <= data_out_0  * (parallel_multiplication_second_operand_sel ? inner_Res[0] : v_inner[0]);
		parallel_multiplication_results[1]  <= data_out_1  * (parallel_multiplication_second_operand_sel ? inner_Res[1] : v_inner[1]);
		parallel_multiplication_results[2]  <= data_out_2  * (parallel_multiplication_second_operand_sel ? inner_Res[2] : v_inner[2]);
		parallel_multiplication_results[3]  <= data_out_3  * (parallel_multiplication_second_operand_sel ? inner_Res[3] : v_inner[3]);
		parallel_multiplication_results[4]  <= data_out_4  * (parallel_multiplication_second_operand_sel ? inner_Res[4] : v_inner[4]);
		parallel_multiplication_results[5]  <= data_out_5  * (parallel_multiplication_second_operand_sel ? inner_Res[5] : v_inner[5]);
		parallel_multiplication_results[6]  <= data_out_6  * (parallel_multiplication_second_operand_sel ? inner_Res[6] : v_inner[6]);
		parallel_multiplication_results[7]  <= data_out_7  * (parallel_multiplication_second_operand_sel ? inner_Res[7] : v_inner[7]);
		parallel_multiplication_results[8]  <= data_out_8  * (parallel_multiplication_second_operand_sel ? inner_Res[8] : v_inner[8]);
		parallel_multiplication_results[9]  <= data_out_9  * (parallel_multiplication_second_operand_sel ? inner_Res[9] : v_inner[9]);
		parallel_multiplication_results[10] <= data_out_10 * (parallel_multiplication_second_operand_sel ? inner_Res[10] : v_inner[10]);
		parallel_multiplication_results[11] <= data_out_11 * (parallel_multiplication_second_operand_sel ? inner_Res[11] : v_inner[11]);
	end
	
	if (clear_numerators & ~assign_numerators) begin
	// (outer + q_summand[i])
		num0 <= 40'b0;
		num1 <= 40'b0;
		num2 <= 40'b0;
		num3 <= 40'b0;
		num4 <= 40'b0;
		num5 <= 40'b0;
		num6 <= 40'b0;
		num7 <= 40'b0;
		num8 <= 40'b0;
		num9 <= 40'b0;
		num10 <= 40'b0;
	end else if (~clear_numerators & assign_numerators) begin
		// i'yi sifirlamak istersem ekstra state lazim, o yuzden baska bir degisken kullan bu bolmeler iki kez calisacaksa
		num0  <= numerator_sel ? (outer[0][39:0]  + q_summand[0][39:0])  : inner_Res[0][39:0];
		num1  <= numerator_sel ? (outer[1][39:0]  + q_summand[1][39:0])  : inner_Res[1][39:0];
		num2  <= numerator_sel ? (outer[2][39:0]  + q_summand[2][39:0])  : inner_Res[2][39:0];
		num3  <= numerator_sel ? (outer[3][39:0]  + q_summand[3][39:0])  : inner_Res[3][39:0];
		num4  <= numerator_sel ? (outer[4][39:0]  + q_summand[4][39:0])  : inner_Res[4][39:0];
		num5  <= numerator_sel ? (outer[5][39:0]  + q_summand[5][39:0])  : inner_Res[5][39:0];
		num6  <= numerator_sel ? (outer[6][39:0]  + q_summand[6][39:0])  : inner_Res[6][39:0];
		num7  <= numerator_sel ? (outer[7][39:0]  + q_summand[7][39:0])  : inner_Res[7][39:0];
		num8  <= numerator_sel ? (outer[8][39:0]  + q_summand[8][39:0])  : inner_Res[8][39:0];
		num9  <= numerator_sel ? (outer[9][39:0]  + q_summand[9][39:0])  : inner_Res[9][39:0];
		num10 <= numerator_sel ? (outer[10][39:0] + q_summand[10][39:0]) : inner_Res[10][39:0];
	end
		
	end
end



	
//Datapath Combinational Part
always@(*) begin

	case (rows_mult_dataa_sel) 
		2'b00: rows_mult_dataa = 8'd3;
		2'b01: rows_mult_dataa = ROWS[8:0];
		2'b10: rows_mult_dataa = rows_mult_res_reg;
		
		// bos
		2'b11: rows_mult_dataa = 8'b0;
	endcase
	
	case (rows_mult_datab_sel)
		1'b0: rows_mult_datab = ROWS[8:0];
		1'b1: rows_mult_datab = int_add_sub_res_reg[8:0];
	endcase

	case(int_mult_dataa_sel)
		2'b00: int_mult_dataa = ROWS;
		2'b01: int_mult_dataa = input_array_q_a; //int_mult_res_reg;
		2'b10: int_mult_dataa = last_diagonal;
		2'b11: int_mult_dataa = 64'd0; //i;
	endcase
	
	case(int_mult_datab_sel)
		2'b00: int_mult_datab = prime_diagonals[i]; //64'd3;
		2'b01: int_mult_datab = q_hat[j]; //int_add_sub_res_reg;
		2'b10: int_mult_datab = ROWS;
		2'b11: int_mult_datab = input_array_q_b;
	endcase
	
	case(int_add_sub_dataa_sel)
		4'b0000: int_add_sub_dataa = ROWS;
		4'b0001: int_add_sub_dataa = each_cone;
		4'b0010: int_add_sub_dataa = int_mult_res_reg;
		4'b0011: int_add_sub_dataa = ROWS_MINUS_ONE;
		4'b0100: int_add_sub_dataa = i;
		4'b0101: int_add_sub_dataa = j;
		4'b0110: int_add_sub_dataa = temp_Uinv_index;
		4'b0111: int_add_sub_dataa = temp_Winv_index;
		4'b1000: int_add_sub_dataa = q_trans[i];
		4'b1001: int_add_sub_dataa = last_diagonal;
		4'b1010: int_add_sub_dataa = inner_Res[i];
		4'b1011: int_add_sub_dataa = v_inner[i];
		4'b1100: int_add_sub_dataa = input_array_q_a;
		4'b1101: int_add_sub_dataa = 1'b1; //total_point_count
		4'b1110: int_add_sub_dataa = 64'b0; //temp_V_index
		4'b1111: int_add_sub_dataa = q_summand[i];
	endcase
	
	case(int_add_sub_datab_sel)
		4'b0000: int_add_sub_datab = 1'b1;
		4'b0001: int_add_sub_datab = V_index;
		4'b0010: int_add_sub_datab = Uinv_index;
		4'b0011: int_add_sub_datab = Winv_index;
		4'b0100: int_add_sub_datab = q_index;
		4'b0101: int_add_sub_datab = s_index;
		4'b0110: int_add_sub_datab = int_mult_res_reg;
		4'b0111: int_add_sub_datab = q_hat[i];
		4'b1000: int_add_sub_datab = temp_Winv_index;
		4'b1001: int_add_sub_datab = inner_Res[i];
		4'b1010: int_add_sub_datab = o_index;
		4'b1011: int_add_sub_datab = 64'b0; //outer;
		
		4'b1100: int_add_sub_datab = total_point_count;
		4'b1101: int_add_sub_datab = temp_V_index;
		4'b1110: int_add_sub_datab = point_count;		
		4'b1111: int_add_sub_datab = divider_counter;
	endcase
	
	case(int_add_sub_add_sub_sel)
		1'b0: int_add_sub_add_sub = 1'b0; // sub
		1'b1: int_add_sub_add_sub = 1'b1; // add
	endcase
	
	/*case(int_comparator_dataa_sel)
		2'b00: int_comparator_dataa = (int_comparator_dataa_i0_sel) ? each_cone : input_array_q_a;
		2'b01: int_comparator_dataa = (int_comparator_dataa_i1_sel) ? v_inner[i] : i;
		2'b10: int_comparator_dataa = j;
		2'b11: int_comparator_dataa = inner_Res[i];
	endcase*/
	
	case(int_comparator_dataa_sel)
		3'b000: int_comparator_dataa = each_cone;
		3'b001: int_comparator_dataa = i;
		3'b010: int_comparator_dataa = j;
		3'b011: int_comparator_dataa = inner_Res[i]; // sil
		3'b100: int_comparator_dataa = input_array_q_a; // sil, implement etmedigin yer icin lazim
		3'b101: int_comparator_dataa = v_inner[i];
		3'b110: int_comparator_dataa = point_count;
		3'b111: int_comparator_dataa = divider_counter;
	endcase
	
	/*case(int_comparator_datab_sel)
		2'b00: int_comparator_datab = (int_comparator_datab_i0_sel) ? int_add_sub_res_reg : NUMBER_OF_CONES;
		2'b01: int_comparator_datab = (int_comparator_datab_i1_sel) ? 64'hFFFFFFFFFFFFFFFF : ROWS;
		2'b10: int_comparator_datab = 64'd13; // bu degerin 2 kati + 4 kadar divider enable ediliyor
		2'b11: int_comparator_datab = (int_comparator_datab_i3_sel) ? 64'b1 : 64'd0;
	endcase*/
	
	case(int_comparator_datab_sel)
		3'b000: int_comparator_datab = NUMBER_OF_CONES;
		3'b001: int_comparator_datab = ROWS;
		3'b010: int_comparator_datab = 64'd7; // bu degerin 2 kati + 1 kadar divider enable ediliyor
		3'b011: int_comparator_datab = 64'd0;
		3'b100: int_comparator_datab = int_add_sub_res_reg;
		3'b101: int_comparator_datab = 64'hFFFFFFFFFFFFFFFF;
		3'b110: int_comparator_datab = 64'b1;
		3'b111: int_comparator_datab = 64'd1000;
	endcase
	
	case(int_divider_numer_sel)
		2'b00: int_divider_numer = last_diagonal[39:0];
		2'b01: int_divider_numer = inner_Res[i][39:0];
		2'b10: int_divider_numer = int_add_sub_res_reg[39:0];
		
		// bos
		2'b11: int_divider_numer = 40'b0;
	endcase
	
	case(int_divider_denom_sel)
		2'b00: int_divider_denom = input_array_q_a[39:0];
		2'b01: int_divider_denom = last_diagonal[39:0];
		
		// BOS
		2'b10: int_divider_denom = 40'b0;
		2'b11: int_divider_denom = 40'b0;
	endcase
	
	case(input_array_address_a_sel)
		2'b00: input_array_address_a = int_add_sub_res[8:0]; 
		2'b01: input_array_address_a = int_add_sub_res_reg[8:0];
		2'b10: input_array_address_a = temp_Uinv_index[8:0];
		2'b11: input_array_address_a = temp_Winv_index[8:0];		
	endcase
	
	case(input_array_address_b_sel)
		2'b00: input_array_address_b = int_add_sub_res[8:0]; 
		2'b01: input_array_address_b = int_add_sub_res_reg[8:0];
		2'b10: input_array_address_b = input_array_test_addr;
		2'b11: input_array_address_b = temp_V_index[8:0];	
	endcase
	
	case(inner_Res_sel)
		3'b000: inner_Res_mux_out = q_trans[i];
		3'b001: inner_Res_mux_out = int_add_sub_res_reg;
		3'b010: inner_Res_mux_out = {{24{int_divider_remain[39]}}, int_divider_remain};
		3'b011: inner_Res_mux_out = last_diagonal;
		3'b100: inner_Res_mux_out = int_parallel_add_res;
		
		//bos
		3'b101: inner_Res_mux_out = 64'b0;
		3'b110: inner_Res_mux_out = 64'b0;
		3'b111: inner_Res_mux_out = 64'b0;
	endcase
	
	int_comparator_aeb = int_comparator_aeb_wire;
	int_comparator_alb = int_comparator_alb_wire;
	
	input_array_data_a = int_mult_res_reg;
	
	inner_Res_and_input_array = int_comparator_aeb_reg && int_comparator_aeb_wire;
	
	int_comparator_not_alb = ~int_comparator_alb_wire;
	
	case (q_array_address_sel)
		2'b00: q_array_address = temp_Winv_index[8:0];
		2'b01: q_array_address = temp_V_index[8:0];
		2'b10: q_array_address = Winv_index[8:0];
		2'b11: q_array_address = V_index[8:0];
	endcase
	
	
	// IN-SYSTEM MEMORY CONTENT EDITOR, for sequential_loader
	if (ld_result_point) begin 
		result_point_ISMCE_wren = 1'b1;
		to_hps = {8'b0, quot10[7:0], quot9[7:0], quot8[7:0], quot7[7:0], quot6[7:0], quot5[7:0],
								quot4[7:0], quot3[7:0], quot2[7:0], quot1[7:0], quot0[7:0]};
	end else begin
		result_point_ISMCE_wren = 1'b0;
		to_hps = 96'b0;
	end

end

endmodule