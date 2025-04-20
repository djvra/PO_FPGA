
module po_fpga_simulation #(
	 parameter ROWS = 12
)(
	input go_i,
	input clk,
	input reset,
	output done
	
);
// mux select
wire int_add_sub_add_sub_sel, int_divider_clken, int_comparator_dataa_i0_sel, int_comparator_dataa_i1_sel,
			int_comparator_datab_i0_sel, int_comparator_datab_i1_sel, int_comparator_datab_i3_sel, i_sel, v_inner_sel,
			rows_mult_datab_sel;

wire [1:0] int_divider_numer_sel, int_divider_denom_sel, rows_mult_dataa_sel, int_mult_dataa_sel, int_mult_datab_sel;
				
wire [2:0] int_comparator_dataa_sel, int_comparator_datab_sel,
				inner_Res_sel;

wire [3:0] int_add_sub_dataa_sel, int_add_sub_datab_sel;

// integer_array operations
wire [1:0] input_array_address_a_sel, input_array_address_b_sel;

// load signal for operator registers
wire ld_int_add_sub_res_reg, ld_int_mult_res_reg, ld_int_comparator_aeb_reg;

// clear
wire clear_i, clear_j, clear_inner_Res, clear_outer, clear_point_count, clear_divider_counter;

// load signal for registers
wire ld_rows_minus_one, ld_each_cone_size, ld_each_cone, ld_V_index, ld_temp_V_index, ld_init_temp_V_index, 
		ld_Uinv_index, ld_temp_Uinv_index, ld_Winv_index, ld_temp_Winv_index, ld_init_temp_Winv_index, 
		ld_q_index, ld_s_index, ld_o_index, ld_last_diagonal, ld_prime_diagonals, 
		ld_q_summand, ld_q_hat, ld_q_trans,	ld_inner_Res, ld_v_inner, ld_total_point_count, ld_outer, ld_result_point,
		ld_point_count, ld_i, ld_j, ld_divider_counter, ld_rows_mult_res_reg;

// array operations
wire clear_arrays;

// input_array operations
wire input_array_wren_a, input_array_wren_b;

wire do_parallel_multiplication, clear_parallel_multiplication_results, increment_temp_Winv_index, parallel_multiplication_second_operand_sel,
	   int_parallel_add_first_operand_sel, clear_numerators, assign_numerators, numerator_sel, seq_loader_rst, ld_remain_to_inner_Res,
		ld_result_adjuster_to_inner_Res, parallel_res_adj_rst, parallel_res_adj_en, condition1_triggered, condition2_triggered;

wire [1:0] q_array_address_sel;
wire ram_module_input_array_rst, ram_module_input_array_en;
		
// comparator signals
wire int_comparator_aeb, int_comparator_alb, int_comparator_not_alb, inner_Res_and_input_array, j_index_comparator_alb;

reg [3:0] NUMBER_OF_CONES;

control_unit cu (
	.go_i(go_i),
	.reset(reset),
	.clk(clk),
	.done(done),
	
	.ld_int_add_sub_res_reg(ld_int_add_sub_res_reg),
	.ld_int_mult_res_reg(ld_int_mult_res_reg),
	
	.ld_rows_minus_one(ld_rows_minus_one),
	.ld_each_cone_size(ld_each_cone_size),
	.ld_each_cone(ld_each_cone),
	.ld_V_index(ld_V_index),
	.ld_temp_V_index(ld_temp_V_index),
	.ld_init_temp_V_index(ld_init_temp_V_index),
	.ld_Uinv_index(ld_Uinv_index),
	.ld_temp_Uinv_index(ld_temp_Uinv_index),
	.ld_Winv_index(ld_Winv_index),
	.ld_temp_Winv_index(ld_temp_Winv_index),
	.ld_init_temp_Winv_index(ld_init_temp_Winv_index),
	.ld_q_index(ld_q_index),
	.ld_s_index(ld_s_index),
	.ld_o_index(ld_o_index),
	.ld_last_diagonal(ld_last_diagonal),
	.ld_prime_diagonals(ld_prime_diagonals),
	.ld_q_summand(ld_q_summand),
	.ld_q_hat(ld_q_hat),
	.ld_q_trans(ld_q_trans),
	.ld_inner_Res(ld_inner_Res),
	.ld_v_inner(ld_v_inner),
	.ld_int_comparator_aeb_reg(ld_int_comparator_aeb_reg),
	.ld_total_point_count(ld_total_point_count),
	.ld_result_point(ld_result_point),
	.ld_outer(ld_outer),
	.ld_point_count(ld_point_count),
	.ld_i(ld_i),
	.ld_j(ld_j),
	.ld_divider_counter(ld_divider_counter),
	
	.clear_i(clear_i),
	.clear_j(clear_j),
	.clear_divider_counter(clear_divider_counter),
	
	.clear_point_count(clear_point_count),
	.clear_outer(clear_outer),
	.clear_inner_Res(clear_inner_Res),
	.clear_arrays(clear_arrays),
	
	.int_mult_dataa_sel(int_mult_dataa_sel),
	.int_mult_datab_sel(int_mult_datab_sel),
	.int_add_sub_dataa_sel(int_add_sub_dataa_sel),
	.int_add_sub_datab_sel(int_add_sub_datab_sel),
	.int_add_sub_add_sub_sel(int_add_sub_add_sub_sel),
	.int_comparator_dataa_sel(int_comparator_dataa_sel),
	.int_comparator_datab_sel(int_comparator_datab_sel),
	.int_comparator_dataa_i0_sel(int_comparator_dataa_i0_sel),
	.int_comparator_dataa_i1_sel(int_comparator_dataa_i1_sel),
	.int_comparator_datab_i0_sel(int_comparator_datab_i0_sel),
	.int_comparator_datab_i1_sel(int_comparator_datab_i1_sel),
	.int_comparator_datab_i3_sel(int_comparator_datab_i3_sel),
	.int_divider_numer_sel(int_divider_numer_sel),
	.int_divider_denom_sel(int_divider_denom_sel),
	.int_divider_clken(int_divider_clken),
	.inner_Res_sel(inner_Res_sel),
	.i_sel(i_sel),
	.v_inner_sel(v_inner_sel),
	
	.input_array_address_a_sel(input_array_address_a_sel),
	.input_array_address_b_sel(input_array_address_b_sel),
	.input_array_wren_a(input_array_wren_a),
	.input_array_wren_b(input_array_wren_b),
	
	.do_parallel_multiplication(do_parallel_multiplication),
	.clear_parallel_multiplication_results(clear_parallel_multiplication_results),
	.parallel_multiplication_second_operand_sel(parallel_multiplication_second_operand_sel),
	.q_array_address_sel(q_array_address_sel),
	.int_parallel_add_first_operand_sel(int_parallel_add_first_operand_sel),
	//.increment_temp_Winv_index(increment_temp_Winv_index),
	
	.ram_module_input_array_rst(ram_module_input_array_rst),
	.ram_module_input_array_en(ram_module_input_array_en),
	
	.clear_numerators(clear_numerators),
	.assign_numerators(assign_numerators),
	.numerator_sel(numerator_sel),
	.seq_loader_rst(seq_loader_rst),
	.ld_remain_to_inner_Res(ld_remain_to_inner_Res),
	.ld_result_adjuster_to_inner_Res(ld_result_adjuster_to_inner_Res),
	.parallel_res_adj_rst(parallel_res_adj_rst),
	.parallel_res_adj_en(parallel_res_adj_en),
	
	.rows_mult_dataa_sel(rows_mult_dataa_sel),
	.rows_mult_datab_sel(rows_mult_datab_sel),
	.ld_rows_mult_res_reg(ld_rows_mult_res_reg),
	
	.condition1_triggered(condition1_triggered),
	.condition2_triggered(condition2_triggered),
	
	.int_comparator_aeb(int_comparator_aeb),
	.int_comparator_alb(int_comparator_alb),
	.int_comparator_not_alb(int_comparator_not_alb),
	.j_index_comparator_alb(j_index_comparator_alb),
	.inner_Res_and_input_array(inner_Res_and_input_array)
);


datapath #(
    .ROWS(ROWS)
) dp (
	.go_i(go_i),
	.clk(clk),
	.reset(reset),
	
	.ld_int_add_sub_res_reg(ld_int_add_sub_res_reg),
	.ld_int_mult_res_reg(ld_int_mult_res_reg),
	
	.ld_rows_minus_one(ld_rows_minus_one),
	.ld_each_cone_size(ld_each_cone_size),
	.ld_each_cone(ld_each_cone),
	.ld_V_index(ld_V_index),
	.ld_temp_V_index(ld_temp_V_index),
	.ld_init_temp_V_index(ld_init_temp_V_index),
	.ld_Uinv_index(ld_Uinv_index),
	.ld_temp_Uinv_index(ld_temp_Uinv_index),
	.ld_Winv_index(ld_Winv_index),
	.ld_temp_Winv_index(ld_temp_Winv_index),
	.ld_init_temp_Winv_index(ld_init_temp_Winv_index),
	.ld_q_index(ld_q_index),
	.ld_s_index(ld_s_index),
	.ld_o_index(ld_o_index),
	.ld_last_diagonal(ld_last_diagonal),
	.ld_prime_diagonals(ld_prime_diagonals),
	.ld_q_summand(ld_q_summand),
	.ld_q_hat(ld_q_hat),
	.ld_q_trans(ld_q_trans),
	.ld_inner_Res(ld_inner_Res),
	.ld_v_inner(ld_v_inner),
	.ld_int_comparator_aeb_reg(ld_int_comparator_aeb_reg),
	.ld_total_point_count(ld_total_point_count),
	.ld_outer(ld_outer),
	.ld_result_point(ld_result_point),
	.ld_point_count(ld_point_count),
	.ld_i(ld_i),
	.ld_j(ld_j),
	.ld_divider_counter(ld_divider_counter),
	
	.clear_i(clear_i),
	.clear_j(clear_j),
	.clear_divider_counter(clear_divider_counter),
	
	.clear_point_count(clear_point_count),
	.clear_outer(clear_outer),
	.clear_inner_Res(clear_inner_Res),
	.clear_arrays(clear_arrays),
	
	.int_mult_dataa_sel(int_mult_dataa_sel),
	.int_mult_datab_sel(int_mult_datab_sel),
	.int_add_sub_dataa_sel(int_add_sub_dataa_sel),
	.int_add_sub_datab_sel(int_add_sub_datab_sel),
	.int_add_sub_add_sub_sel(int_add_sub_add_sub_sel),
	.int_comparator_dataa_sel(int_comparator_dataa_sel),
	.int_comparator_datab_sel(int_comparator_datab_sel),
	.int_comparator_dataa_i0_sel(int_comparator_dataa_i0_sel),
	.int_comparator_dataa_i1_sel(int_comparator_dataa_i1_sel),
	.int_comparator_datab_i0_sel(int_comparator_datab_i0_sel),
	.int_comparator_datab_i1_sel(int_comparator_datab_i1_sel),
	.int_comparator_datab_i3_sel(int_comparator_datab_i3_sel),
	.int_divider_numer_sel(int_divider_numer_sel),
	.int_divider_denom_sel(int_divider_denom_sel),
	.int_divider_clken(int_divider_clken),
	.inner_Res_sel(inner_Res_sel),
	.i_sel(i_sel),
	.v_inner_sel(v_inner_sel),
	
	.input_array_address_a_sel(input_array_address_a_sel),
	.input_array_address_b_sel(input_array_address_b_sel),
	.input_array_wren_a(input_array_wren_a),
	.input_array_wren_b(input_array_wren_b),
	
	.do_parallel_multiplication(do_parallel_multiplication),
	.clear_parallel_multiplication_results(clear_parallel_multiplication_results),
	.parallel_multiplication_second_operand_sel(parallel_multiplication_second_operand_sel),
	.q_array_address_sel(q_array_address_sel),
	.int_parallel_add_first_operand_sel(int_parallel_add_first_operand_sel),
	//.increment_temp_Winv_index(increment_temp_Winv_index),
	
	.ram_module_input_array_rst(ram_module_input_array_rst),
	.ram_module_input_array_en(ram_module_input_array_en),
	
	.clear_numerators(clear_numerators),
	.assign_numerators(assign_numerators),
	.numerator_sel(numerator_sel),
	.seq_loader_rst(seq_loader_rst),
	.ld_remain_to_inner_Res(ld_remain_to_inner_Res),
	.ld_result_adjuster_to_inner_Res(ld_result_adjuster_to_inner_Res),
	.parallel_res_adj_rst(parallel_res_adj_rst),
	.parallel_res_adj_en(parallel_res_adj_en),
	
	.rows_mult_dataa_sel(rows_mult_dataa_sel),
	.rows_mult_datab_sel(rows_mult_datab_sel),
	.ld_rows_mult_res_reg(ld_rows_mult_res_reg),
	
	.condition1_triggered(condition1_triggered),
	.condition2_triggered(condition2_triggered),
	
	.int_comparator_aeb(int_comparator_aeb),
	.int_comparator_alb(int_comparator_alb),
	.int_comparator_not_alb(int_comparator_not_alb),
	.j_index_comparator_alb(j_index_comparator_alb),
	.inner_Res_and_input_array(inner_Res_and_input_array),
	
	//.ROWS(ROWS),
	.NUMBER_OF_CONES(NUMBER_OF_CONES)
);


endmodule