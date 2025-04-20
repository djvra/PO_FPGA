module control_unit(
	input go_i,
	input reset,
	input clk,
	output reg generation_done,
	
	// register operations
	output reg ld_int_add_sub_res_reg,
	output reg ld_int_mult_res_reg,
	
	output reg ld_rows_minus_one,
	output reg ld_each_cone_size,
	output reg ld_each_cone,
	output reg ld_V_index,
	output reg ld_temp_V_index,
	output reg ld_init_temp_V_index,
	output reg ld_Uinv_index,
	output reg ld_temp_Uinv_index,
	output reg ld_Winv_index,
	output reg ld_temp_Winv_index,
	output reg ld_init_temp_Winv_index,
	output reg ld_q_index,
	output reg ld_s_index,
	output reg ld_o_index,
	output reg ld_last_diagonal,
	output reg ld_prime_diagonals,
	output reg ld_q_summand,
	output reg ld_q_hat,
	output reg ld_q_trans,
	output reg ld_inner_Res,
	output reg ld_v_inner,
	output reg ld_int_comparator_aeb_reg,
	output reg ld_total_point_count,
	output reg ld_outer,
	output reg ld_result_point,
	output reg ld_point_count,
	output reg ld_i,
	output reg ld_j,
	output reg ld_divider_counter,
	
	// clear
	output reg clear_i,
	output reg clear_j,
	output reg clear_divider_counter,
	
	// array operations
	output reg clear_point_count,
	output reg clear_outer,
	output reg clear_inner_Res,
	output reg clear_arrays,
	
	// integer operations
	output reg [1:0] int_mult_dataa_sel,
	output reg [1:0] int_mult_datab_sel,
	output reg [3:0] int_add_sub_dataa_sel,
	output reg [3:0] int_add_sub_datab_sel,
	output reg int_add_sub_add_sub_sel,
	output reg [2:0] int_comparator_dataa_sel,
	output reg [2:0] int_comparator_datab_sel,
	output reg int_comparator_dataa_i0_sel,
	output reg int_comparator_dataa_i1_sel,
	output reg int_comparator_datab_i0_sel,
	output reg int_comparator_datab_i1_sel,
	output reg int_comparator_datab_i3_sel,
	output reg [1:0] int_divider_numer_sel,
	output reg [1:0] int_divider_denom_sel,
	output reg int_divider_clken,
	output reg [2:0] inner_Res_sel,
	output reg i_sel,
	output reg v_inner_sel,
	
	// input_array operations
	output reg [1:0] input_array_address_a_sel,
	output reg [1:0] input_array_address_b_sel,
	output reg input_array_wren_a,
	output reg input_array_wren_b,
	
	output reg do_parallel_multiplication,
	output reg clear_parallel_multiplication_results,
	output reg parallel_multiplication_second_operand_sel,
	output reg [1:0] q_array_address_sel,
	output reg int_parallel_add_first_operand_sel,
	//output reg increment_temp_Winv_index,
	
	output reg ram_module_input_array_rst,
	output reg ram_module_input_array_en,
	
	output reg clear_numerators,
	output reg assign_numerators,
	output reg numerator_sel,
	output reg seq_loader_rst,
	output reg ld_remain_to_inner_Res,
	output reg ld_result_adjuster_to_inner_Res,
	output reg parallel_res_adj_rst,
	output reg parallel_res_adj_en,
	
	output reg [1:0] rows_mult_dataa_sel,
	output reg rows_mult_datab_sel,
	output reg ld_rows_mult_res_reg,
	
	input condition1_triggered,
	input condition2_triggered,
	
	// comparator signals
	input int_comparator_aeb,
	input int_comparator_alb,
	input int_comparator_not_alb,
	input j_index_comparator_alb,
	input inner_Res_and_input_array,
	
	output [6:0] current_state_test,
	output [63:0] state_count_wire
);

parameter 	START = 7'h00, 
				CALCULATE_EACH_CONE_SIZE_0 = 7'h01,  // 3*ROWS ve ROWS+1
				CALCULATE_EACH_CONE_SIZE_1  = 7'h02, // usttekinin sonuclari carp
				
				OUTER_FOR_LOOP_CHECK = 7'h05, // each_cone < number_of_cone
				
				SPLIT_INDEXES_0 = 7'h06, // *V_index = cone_start_index, int_mult_res_reg = ROWS * COLUMNS
				SPLIT_INDEXES_1 = 7'h08, // *Uinv_index = *V_index + int_mult_res_reg
				SPLIT_INDEXES_2 = 7'h09, // *Winv_index = *Uinv_index + int_mult_res_reg
				SPLIT_INDEXES_3 = 7'h0a, // *q_index = *Winv_index + int_mult_res_reg
				SPLIT_INDEXES_4 = 7'h0b, // *s_index = *q_index + ROWS; 
				SPLIT_INDEXES_5 = 7'h0c, // *o_index = *s_index + ROWS;
				
				GET_LAST_DIAGONAL = 7'h0d, // input_array[s_index + ROWS_];
				INITIALIZE_LAST_DIAGONAL = 7'h0e, // input_array[s_index], input_array[q_index], i = 0
				
				FIRST_FOR_LOOP_CHECK_I = 7'h0f, // i < ROWS, input_array[s_index + i]
				
				FIRST_FOR_LOOP_PRIME_DIAGONALS_0 = 7'h10, // prime_diagonals[i] = last_diagonal / input_array[s_index + i], input_array[q_index + i] 
				FIRST_FOR_LOOP_PRIME_DIAGONALS_1 = 7'h11,
				FIRST_FOR_LOOP_PRIME_DIAGONALS_2 = 7'h12,
				
				FIRST_FOR_LOOP_Q_SUMMAND_0 = 7'h13, // q_summand[i] = last_diagonal * input_array[q_index + i];
				FIRST_FOR_LOOP_CHECK_J = 7'h17, // j < ROWS				
				FIRST_FOR_LOOP_Q_HAT_0 = 7'h18,
				FIRST_FOR_LOOP_Q_HAT_1 = 7'h19,
				FIRST_FOR_LOOP_Q_HAT_2 = 7'h20,
				FIRST_FOR_LOOP_Q_HAT_3 = 7'h21,
				FIRST_FOR_LOOP_INCREMENT_J = 7'h22, // ++j
				FIRST_FOR_LOOP_INCREMENT_I = 7'h23, // ++i
				
				
				SECOND_FOR_LOOP_PREPARATION = 7'h29,
				SECOND_FOR_LOOP_CHECK_I = 7'h2a, 								
				SECOND_FOR_LOOP_CHECK_J = 7'h2b,  									
				SECOND_FOR_LOOP_Q_TRANS_0 = 7'h2c,										
				SECOND_FOR_LOOP_Q_TRANS_1 = 7'h2d,										
				SECOND_FOR_LOOP_Q_TRANS_2 = 7'h2e,								
				SECOND_FOR_LOOP_INCREMENT_J = 7'h2f,				
				SECOND_FOR_LOOP_INCREMENT_I = 7'h30,
				
				
				WHILE_LOOP = 7'h31,
				
				THIRD_FOR_LOOP_CHECK_I = 7'h32,
				THIRD_FOR_LOOP_INNER_RES_0 = 7'h34,
				THIRD_FOR_LOOP_INNER_RES_1 = 7'h35,
				THIRD_FOR_LOOP_INNER_RES_2 = 7'h36,
				THIRD_FOR_LOOP_INNER_RES_3 = 7'h37,
				THIRD_FOR_LOOP_INNER_RES_4 = 7'h39,
				THIRD_FOR_LOOP_INNER_RES_5 = 7'h3a,
				THIRD_FOR_LOOP_INNER_RES_6 = 7'h3b,
				
				FOURTH_FOR_LOOP_PREPARATION = 7'h42,
				FOURTH_FOR_LOOP_CHECK_I = 7'h43,		
				FOURTH_FOR_LOOP_OUTER_0 = 7'h45,
				FOURTH_FOR_LOOP_OUTER_1 = 7'h46,
				FOURTH_FOR_LOOP_OUTER_2 = 7'h47,
				FOURTH_FOR_LOOP_OUTER_3 = 7'h48,												

				FOURTH_FOR_LOOP_RESULT_POINT_0 = 7'h49,
				FOURTH_FOR_LOOP_RESULT_POINT_1 = 7'h4a,
				FOURTH_FOR_LOOP_RESULT_POINT_2 = 7'h4b,
				FOURTH_FOR_LOOP_RESULT_POINT_3 = 7'h4c,
				FOURTH_FOR_LOOP_RESULT_POINT_4 = 7'h4d,
				FOURTH_FOR_LOOP_RESULT_POINT_5 = 7'h4e,
				FOURTH_FOR_LOOP_INCREMENT_I = 7'h4f,
		
				
				INNER_WHILE_PREPARATION = 7'h50,
				INNER_WHILE_0 = 7'h51,
				INNER_WHILE_1 = 7'h52,
				INNER_WHILE_2 = 7'h53,
				INNER_WHILE_3 = 7'h54,
				INNER_WHILE_4 = 7'h55,
				INNER_WHILE_5 = 7'h56,
				
				CHECK_BREAK_CONDITION = 7'h57,
						
				OUTER_FOR_LOOP_INCREMENT = 7'h7d, // ++each_cone
				PRINT_TOTAL_POINT_COUNT = 7'h7e, // bu toplam point sayisini bastirmak icin
				DONE  = 7'h7f;

reg [6:0] current_state, next_state; // 128 bit
assign current_state_test = current_state;

reg [63:0] state_count = 1;
assign state_count_wire = state_count;
reg start_to_count_states = 0;

//State Register Definition
always @(posedge clk) begin
	if(reset) begin
		current_state <= START;
	end else begin
		current_state <= next_state;
		
		if (go_i)
			start_to_count_states <= 1;
		
		if (~generation_done & start_to_count_states) begin
			state_count = state_count + 1; 
		end
	end
end

//Next State Logic
always @(*) begin
	
	case(current_state)
	
		START:	begin
					if(go_i)
						next_state = CALCULATE_EACH_CONE_SIZE_0;
					else
						next_state = START;
					end
					
		CALCULATE_EACH_CONE_SIZE_0: next_state = CALCULATE_EACH_CONE_SIZE_1;
		CALCULATE_EACH_CONE_SIZE_1: next_state = OUTER_FOR_LOOP_CHECK;
		
		OUTER_FOR_LOOP_CHECK: 	begin
										if (int_comparator_alb)
											next_state = SPLIT_INDEXES_0;
										else 
											next_state = PRINT_TOTAL_POINT_COUNT;
										end
										
		SPLIT_INDEXES_0: next_state = SPLIT_INDEXES_1;
		SPLIT_INDEXES_1: next_state = SPLIT_INDEXES_2;
		SPLIT_INDEXES_2: next_state = SPLIT_INDEXES_3;
		SPLIT_INDEXES_3: next_state = SPLIT_INDEXES_4;
		SPLIT_INDEXES_4: next_state = SPLIT_INDEXES_5;
		SPLIT_INDEXES_5: next_state = GET_LAST_DIAGONAL;
		
		GET_LAST_DIAGONAL: next_state = INITIALIZE_LAST_DIAGONAL;
		INITIALIZE_LAST_DIAGONAL: next_state = FIRST_FOR_LOOP_CHECK_I;
		
		FIRST_FOR_LOOP_CHECK_I: begin
										if (int_comparator_alb)
											next_state = FIRST_FOR_LOOP_PRIME_DIAGONALS_0;
										else 
											next_state = SECOND_FOR_LOOP_PREPARATION;
										end
										
		FIRST_FOR_LOOP_PRIME_DIAGONALS_0: next_state = FIRST_FOR_LOOP_PRIME_DIAGONALS_1;
		FIRST_FOR_LOOP_PRIME_DIAGONALS_1: next_state = FIRST_FOR_LOOP_PRIME_DIAGONALS_2;
		FIRST_FOR_LOOP_PRIME_DIAGONALS_2: begin
													 if (int_comparator_alb)
														next_state = FIRST_FOR_LOOP_PRIME_DIAGONALS_1;
													 else 
														next_state = FIRST_FOR_LOOP_Q_SUMMAND_0;
													 end
														
		FIRST_FOR_LOOP_Q_SUMMAND_0: next_state = FIRST_FOR_LOOP_CHECK_J;
				
		FIRST_FOR_LOOP_CHECK_J: begin
										if (int_comparator_alb)
											next_state = FIRST_FOR_LOOP_Q_HAT_0;
										else 
											next_state = FIRST_FOR_LOOP_INCREMENT_I;
										end
										
		FIRST_FOR_LOOP_Q_HAT_0: next_state = FIRST_FOR_LOOP_Q_HAT_1;
		FIRST_FOR_LOOP_Q_HAT_1: next_state = FIRST_FOR_LOOP_Q_HAT_2;
		FIRST_FOR_LOOP_Q_HAT_2: next_state = FIRST_FOR_LOOP_Q_HAT_3;
		FIRST_FOR_LOOP_Q_HAT_3: next_state = FIRST_FOR_LOOP_INCREMENT_J;
		FIRST_FOR_LOOP_INCREMENT_J: next_state = FIRST_FOR_LOOP_CHECK_J;
		FIRST_FOR_LOOP_INCREMENT_I: next_state = FIRST_FOR_LOOP_CHECK_I;
		
		
		
		SECOND_FOR_LOOP_PREPARATION: next_state = SECOND_FOR_LOOP_CHECK_I;
					
		SECOND_FOR_LOOP_CHECK_I:   begin
											if (j_index_comparator_alb & int_comparator_alb)
												next_state = SECOND_FOR_LOOP_Q_TRANS_0;
											else if (~j_index_comparator_alb & int_comparator_alb)
												next_state = SECOND_FOR_LOOP_INCREMENT_I;
											else 
												next_state = WHILE_LOOP;
											end			
				
		SECOND_FOR_LOOP_Q_TRANS_0:   next_state = SECOND_FOR_LOOP_Q_TRANS_1;						
		SECOND_FOR_LOOP_Q_TRANS_1:   next_state = SECOND_FOR_LOOP_Q_TRANS_2;						
		SECOND_FOR_LOOP_Q_TRANS_2:   next_state = SECOND_FOR_LOOP_INCREMENT_J;	
		SECOND_FOR_LOOP_INCREMENT_J: next_state = SECOND_FOR_LOOP_CHECK_I;
		SECOND_FOR_LOOP_INCREMENT_I: next_state = SECOND_FOR_LOOP_CHECK_I;
		
		WHILE_LOOP: next_state = THIRD_FOR_LOOP_CHECK_I;
											
		THIRD_FOR_LOOP_CHECK_I:   begin
											if (int_comparator_alb)
												next_state = THIRD_FOR_LOOP_INNER_RES_0;
											else 
												next_state = THIRD_FOR_LOOP_INNER_RES_2;
											end	
											
		THIRD_FOR_LOOP_INNER_RES_0: next_state = THIRD_FOR_LOOP_INNER_RES_1;
		THIRD_FOR_LOOP_INNER_RES_1: next_state = THIRD_FOR_LOOP_CHECK_I;
		
		THIRD_FOR_LOOP_INNER_RES_2: next_state = THIRD_FOR_LOOP_INNER_RES_3;
						
		THIRD_FOR_LOOP_INNER_RES_3: next_state = THIRD_FOR_LOOP_INNER_RES_4;
		THIRD_FOR_LOOP_INNER_RES_4: begin
												if (int_comparator_alb)
													next_state = THIRD_FOR_LOOP_INNER_RES_3;
												else
													next_state = THIRD_FOR_LOOP_INNER_RES_5;
												end
		
		THIRD_FOR_LOOP_INNER_RES_5: begin
												 if (condition1_triggered)
													next_state = THIRD_FOR_LOOP_INNER_RES_6;
												 else	
													next_state = FOURTH_FOR_LOOP_PREPARATION;
												 end
											 
		THIRD_FOR_LOOP_INNER_RES_6: next_state = FOURTH_FOR_LOOP_PREPARATION;



		FOURTH_FOR_LOOP_PREPARATION: next_state = FOURTH_FOR_LOOP_CHECK_I;

		FOURTH_FOR_LOOP_CHECK_I:   begin
											if (int_comparator_alb)
												next_state = FOURTH_FOR_LOOP_OUTER_0;
											else 
												next_state = FOURTH_FOR_LOOP_RESULT_POINT_0;
											end
												
		FOURTH_FOR_LOOP_OUTER_0: next_state = FOURTH_FOR_LOOP_OUTER_1;
		FOURTH_FOR_LOOP_OUTER_1: next_state = FOURTH_FOR_LOOP_OUTER_3;
		FOURTH_FOR_LOOP_OUTER_3: next_state = FOURTH_FOR_LOOP_CHECK_I;

		FOURTH_FOR_LOOP_RESULT_POINT_0: begin
												  if (int_comparator_alb)
														next_state = FOURTH_FOR_LOOP_RESULT_POINT_2;
												  else 
														next_state = FOURTH_FOR_LOOP_RESULT_POINT_1;
												  end
												  
		FOURTH_FOR_LOOP_RESULT_POINT_1: next_state = FOURTH_FOR_LOOP_RESULT_POINT_2;
		FOURTH_FOR_LOOP_RESULT_POINT_2: next_state = FOURTH_FOR_LOOP_RESULT_POINT_3;
		FOURTH_FOR_LOOP_RESULT_POINT_3: next_state = FOURTH_FOR_LOOP_RESULT_POINT_4;
		FOURTH_FOR_LOOP_RESULT_POINT_4: begin
												if (int_comparator_alb)
													next_state = FOURTH_FOR_LOOP_RESULT_POINT_3;
												else
													next_state = FOURTH_FOR_LOOP_RESULT_POINT_5;
												end
		FOURTH_FOR_LOOP_RESULT_POINT_5: next_state = INNER_WHILE_PREPARATION;
												 
		FOURTH_FOR_LOOP_INCREMENT_I: next_state = FOURTH_FOR_LOOP_CHECK_I;



		INNER_WHILE_PREPARATION: next_state = INNER_WHILE_0;
										 
										 						
		INNER_WHILE_0:				begin
										if (int_comparator_alb)
											next_state = CHECK_BREAK_CONDITION;
										else
											next_state = INNER_WHILE_1;
										end
											
		INNER_WHILE_1: 			next_state = INNER_WHILE_2;
		
		INNER_WHILE_2:				begin
										if (int_comparator_alb)
											next_state = INNER_WHILE_3;
										else 
											next_state = INNER_WHILE_4;
										end
										
		INNER_WHILE_3:				next_state = CHECK_BREAK_CONDITION;
		INNER_WHILE_4:				next_state = INNER_WHILE_5;
		INNER_WHILE_5: 			next_state = INNER_WHILE_0;
		
		CHECK_BREAK_CONDITION: if (int_comparator_aeb)
											next_state = OUTER_FOR_LOOP_INCREMENT;
										else
											next_state = WHILE_LOOP;
													
		OUTER_FOR_LOOP_INCREMENT: next_state = OUTER_FOR_LOOP_CHECK;
		
		PRINT_TOTAL_POINT_COUNT: next_state = DONE;
		
		default: next_state = current_state;
	
	endcase
					
end

//Output Logic
always @(*) begin
	generation_done = 1'b0;
	
	ld_int_add_sub_res_reg = 1'b0;
	ld_int_mult_res_reg = 1'b0;
	
	ld_rows_minus_one = 1'b0;
	ld_each_cone_size = 1'b0;
	ld_each_cone = 1'b0;
	ld_V_index = 1'b0;
	ld_temp_V_index = 1'b0;
	ld_init_temp_V_index = 1'b0;
	ld_Uinv_index = 1'b0;
	ld_temp_Uinv_index = 1'b0; // bunun da initi olmalı ekle bunu
	ld_Winv_index = 1'b0;
	ld_temp_Winv_index = 1'b0;
	ld_init_temp_Winv_index = 1'b0;
	ld_q_index = 1'b0;
	ld_s_index = 1'b0;
	ld_o_index = 1'b0;
	ld_last_diagonal = 1'b0; 
	//ld_input_array_address_a = 1'b0;
	ld_prime_diagonals = 1'b0;
	ld_q_summand = 1'b0;
	ld_q_hat = 1'b0;
	ld_q_trans = 1'b0;
	ld_inner_Res = 1'b0;
	ld_v_inner = 1'b0;
	ld_int_comparator_aeb_reg = 1'b0;
	ld_total_point_count = 1'b0;
	ld_outer = 1'b0;
	ld_result_point = 1'b0;
	ld_point_count = 1'b0;
	ld_i = 1'b0;
	ld_j = 1'b0;
	ld_divider_counter = 1'b0;
	
	clear_i = 1'b0;
	clear_j = 1'b0;
	clear_divider_counter = 1'b0;
	
	clear_point_count = 1'b0;
	clear_inner_Res = 1'b0;
	clear_outer = 1'b0;
	clear_arrays = 1'b0;
	
	int_mult_dataa_sel = 2'b00;
	int_mult_datab_sel = 2'b00;
	int_add_sub_dataa_sel = 4'b0000;
	int_add_sub_datab_sel = 4'b0000;
	int_add_sub_add_sub_sel = 1'b0;
	int_comparator_dataa_sel = 3'b000;
	int_comparator_datab_sel = 3'b000;
	int_comparator_dataa_i0_sel = 1'b0;
	int_comparator_dataa_i1_sel = 1'b0;
	int_comparator_datab_i0_sel = 1'b0;
	int_comparator_datab_i1_sel = 1'b0;
	int_comparator_datab_i3_sel = 1'b0;
	int_divider_numer_sel = 2'b00;
	int_divider_denom_sel = 2'b00;
	int_divider_clken = 1'b0;
	inner_Res_sel = 3'b000;
	i_sel = 1'b0;
	v_inner_sel = 1'b0;
	
	input_array_address_a_sel = 2'b00;
	input_array_address_b_sel = 2'b00;
	input_array_wren_a = 1'b0;
	input_array_wren_b = 1'b0;
	
	do_parallel_multiplication = 1'b0;
	clear_parallel_multiplication_results = 1'b0;
	parallel_multiplication_second_operand_sel = 1'b0;
	q_array_address_sel = 2'b00;
	int_parallel_add_first_operand_sel = 1'b0;
	//increment_temp_Winv_index = 1'b0;
	
	ram_module_input_array_rst = 1'b0;
	ram_module_input_array_en = 1'b0;
	
	clear_numerators = 1'b0;
	assign_numerators = 1'b0;
	numerator_sel = 1'b0;
	seq_loader_rst = 1'b0;
	ld_remain_to_inner_Res = 1'b0;
	ld_result_adjuster_to_inner_Res = 1'b0;
	parallel_res_adj_rst = 1'b0;
	parallel_res_adj_en = 1'b0;
	
	rows_mult_dataa_sel = 2'b00;
	rows_mult_datab_sel = 1'b0;
	ld_rows_mult_res_reg = 1'b0;
	
	case(current_state)
		START: begin
				 // ROWS - 1
				 int_add_sub_dataa_sel = 4'b0000; // ROWS
				 int_add_sub_datab_sel = 4'b0000; // 1
				 int_add_sub_add_sub_sel = 1'b0; // substract
				 ld_rows_minus_one = 1'b1;
				 
				 ram_module_input_array_rst = 1'b1;
				 seq_loader_rst = 1'b1;
				 end
					
		CALCULATE_EACH_CONE_SIZE_0: 	begin
												// 3*ROWS
												/*int_mult_dataa_sel = 3'b000;
												int_mult_datab_sel = 3'b000;
												ld_int_mult_res_reg = 1'b1;*/
												
												rows_mult_dataa_sel = 2'b00; // 3
												rows_mult_datab_sel = 1'b0; // ROWS
												ld_rows_mult_res_reg = 1'b1;
												
												// ROWS+1
												int_add_sub_dataa_sel = 4'b0000;
												int_add_sub_datab_sel = 4'b0000;
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_int_add_sub_res_reg = 1'b1;
												end
												
		CALCULATE_EACH_CONE_SIZE_1: 	begin
												// usttekilerin carpimi 
												/*int_mult_dataa_sel = 3'b001;
												int_mult_datab_sel = 3'b001;*/
												
												rows_mult_dataa_sel = 2'b10; // rows_mult_res_reg
												rows_mult_datab_sel = 1'b1; // int_add_sub_res_reg[3:0]
												ld_each_cone_size = 1'b1;
												end
												
		OUTER_FOR_LOOP_CHECK: 			begin // each_cone < number_of_cone
												//int_comparator_dataa_i0_sel = 1'b1; // each_cone
												int_comparator_dataa_sel = 3'b000; // each_cone
												int_comparator_datab_sel = 3'b000;
												end
												
		SPLIT_INDEXES_0: 					begin
												ld_V_index = 1'b1;
												
												int_mult_dataa_sel = 2'b00; // take square of the ROWS
												int_mult_datab_sel = 2'b10;
												ld_int_mult_res_reg = 1'b1;
												end							
												
		SPLIT_INDEXES_1:					begin
												// *Uinv_index = *V_index + int_mult_res_reg
												int_add_sub_dataa_sel = 4'b0010; // int_mult_res_reg
												int_add_sub_datab_sel = 4'b0001; // V_index
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_Uinv_index = 1'b1;
												
												ld_temp_Uinv_index = 1'b1;
												end
												
		SPLIT_INDEXES_2: 					begin
												int_add_sub_dataa_sel = 4'b0010; // int_mult_res_reg
												int_add_sub_datab_sel = 4'b0010; // Uinv_index
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_Winv_index = 1'b1;
												end
												
		SPLIT_INDEXES_3:					begin
												int_add_sub_dataa_sel = 4'b0010; // int_mult_res_reg
												int_add_sub_datab_sel = 4'b0011; // Winv_index
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_q_index = 1'b1;
												end
												
		SPLIT_INDEXES_4:					begin
												int_add_sub_dataa_sel = 4'b0000; // ROWS
												int_add_sub_datab_sel = 4'b0100; // q_index
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_s_index = 1'b1;
												end
												
		SPLIT_INDEXES_5:					begin
												int_add_sub_dataa_sel = 4'b0000; // ROWS
												int_add_sub_datab_sel = 4'b0101; // s_index
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_o_index = 1'b1;
												
												clear_arrays = 1'b1;
												end
												
		GET_LAST_DIAGONAL: 				begin // input_array[s_index + ROWS_];
												int_add_sub_dataa_sel = 4'b0011; // ROWS_
												int_add_sub_datab_sel = 4'b0101; // s_index
												int_add_sub_add_sub_sel = 1'b1; // add
												input_array_address_a_sel = 2'b00;
												end
												
		INITIALIZE_LAST_DIAGONAL: 		begin // last_diagonal = input_array_q_a;
												ld_last_diagonal = 1'b1;
												
												clear_i = 1'b1; // i = 0
												end
												
		FIRST_FOR_LOOP_CHECK_I:   		begin
												int_comparator_dataa_sel = 3'b001; // i
												int_comparator_datab_sel = 3'b001; // ROWS
												
												int_add_sub_dataa_sel = 4'b0100; // i
												int_add_sub_datab_sel = 4'b0101; // s_index
												int_add_sub_add_sub_sel = 1'b1; // add
												
												input_array_address_a_sel = 2'b00; // input_array[s_index + i]
												end
												
		FIRST_FOR_LOOP_PRIME_DIAGONALS_0:  begin // prime_diagonals[i] = last_diagonal / input_array[s_index + i], i = 0
													int_divider_numer_sel = 2'b00; 
													int_divider_denom_sel = 2'b00;
													int_divider_clken = 1'b1; // bolmeye basla
													//ld_prime_diagonals = 1'b1;
													
													int_add_sub_dataa_sel = 4'b0100; // i
													int_add_sub_datab_sel = 4'b0100; // q_index
													int_add_sub_add_sub_sel = 1'b1; // add
													ld_int_add_sub_res_reg = 1'b1;
													
													//input_array_address_b_sel = 2'b00; // input_array[q_index + i]
													
													clear_j = 1'b1; // j = 0;
													clear_divider_counter = 1'b1;
													end
													
		FIRST_FOR_LOOP_PRIME_DIAGONALS_1: begin
													 int_divider_clken = 1'b1; // bolmeye devam
													 
													 int_add_sub_dataa_sel = 4'b1101; // 1
													 int_add_sub_datab_sel = 4'b1111; // divider_counter
													 int_add_sub_add_sub_sel = 1'b1; // add
													 ld_divider_counter = 1'b1;
													 end
													
		FIRST_FOR_LOOP_PRIME_DIAGONALS_2: begin
													 int_divider_clken = 1'b1; // bolmeye devam
													 
													 int_comparator_dataa_sel = 3'b111; // divider_counter
													 int_comparator_datab_sel = 3'b010; // cycle sayisi
													 
													 input_array_address_b_sel = 2'b01; // int_add_sub_res_reg[8:0], input_array[q_index + i]
													 end
																
		FIRST_FOR_LOOP_Q_SUMMAND_0: 	begin 
											//int_divider_clken = 1'b1; // bolmeye devam
											
											//input_array_address_b_sel = 2'b01; // int_add_sub_res_reg
											
											//int_mult_dataa_sel = 3'b010; // last_diagonal
											//int_mult_datab_sel = 3'b011; // input_array[q_index + i]
											//ld_q_summand = 1'b1;
													
											//clear_j = 1'b1; // j = 0;

											ld_prime_diagonals = 1'b1;
											
											int_mult_dataa_sel = 2'b10; // last_diagonal
											int_mult_datab_sel = 2'b11; // input_array_q_b, input_array[q_index + i]
											ld_q_summand = 1'b1;
											
											// temp_Winv_index = Winv_index + i;
											int_add_sub_dataa_sel = 4'b0100; // i
											int_add_sub_datab_sel = 4'b0011; // Winv_index
											int_add_sub_add_sub_sel = 1'b1; // add
											ld_temp_Winv_index = 1'b1;
											end										
														
		FIRST_FOR_LOOP_CHECK_J:			begin
												int_comparator_dataa_sel = 3'b010; // j
												int_comparator_datab_sel = 3'b001; // ROWS
												
												/*// Uinv_index + i * ROWS + j
												int_mult_dataa_sel = 3'b011; // i 
												int_mult_datab_sel = 3'b010; // ROWS
												ld_int_mult_res_reg = 1'b1;*/
												
												/*int_add_sub_dataa_sel = 3'b101; // j
												int_add_sub_datab_sel = 3'b010; // Uinv_index
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_int_add_sub_res_reg = 1'b1;*/
												
												// q_index + j
												int_add_sub_dataa_sel = 4'b0101; // j
												int_add_sub_datab_sel = 4'b0100; // q_index
												int_add_sub_add_sub_sel = 1'b1; // add
												
												input_array_address_a_sel = 2'b10; // temp_Uinv_index -> input_array[Uinv_index + i * ROWS + j]
												input_array_address_b_sel = 2'b00; // input_array[q_index + j];
												end
		
		FIRST_FOR_LOOP_Q_HAT_0:			begin
												// Uinv_index + i * ROWS + j
												/*int_add_sub_dataa_sel = 3'b010; // int_mult_res_reg
												int_add_sub_datab_sel = 3'b110; // int_add_sub_res_reg
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_int_add_sub_res_reg = 1'b1;*/
												
												// input_array[Uinv_index + i * ROWS + j] * input_array[q_index + j];
												int_mult_dataa_sel = 2'b01; // input_array_q_a
												int_mult_datab_sel = 2'b11; // input_array_q_b
												ld_int_mult_res_reg = 1'b1;
												end
												
												
		FIRST_FOR_LOOP_Q_HAT_1: 		begin
												/*// q_index + j
												int_add_sub_dataa_sel = 3'b101; // j
												int_add_sub_datab_sel = 3'b100; // q_index
												int_add_sub_add_sub_sel = 1'b1; // add*/
												
												/*input_array_address_a_sel = 2'b01; // input_array[Uinv_index + i * ROWS + j]
												input_array_address_b_sel = 2'b00; // input_array[q_index + j];*/
												
												int_add_sub_dataa_sel = 4'b0010; // int_mult_res_reg
												int_add_sub_datab_sel = 4'b0111; // q_hat
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_q_hat = 1'b1;
												
												input_array_address_a_sel = 2'b11; // temp_Winv_index[8:0]
												end
												
		FIRST_FOR_LOOP_Q_HAT_2: 		begin
												/*// input_array[Uinv_index + i * ROWS + j] * input_array[q_index + j];
												int_mult_dataa_sel = 3'b100; // input_array_q_a
												int_mult_datab_sel = 3'b011; // input_array_q_b
												ld_int_mult_res_reg = 1'b1;*/
												
												int_mult_dataa_sel = 2'b01; // input_array_q_a
												int_mult_datab_sel = 2'b00; // prime_diagonals[i]
												ld_int_mult_res_reg = 1'b1; 	
						
												int_add_sub_dataa_sel = 4'b0110; // temp_Uinv_index
												int_add_sub_datab_sel = 4'b0000; // 1
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_temp_Uinv_index = 1'b1;
												end
												
		FIRST_FOR_LOOP_Q_HAT_3: 		begin
												// input_array'ın dataa girisine direkt int_mult_res_reg bagladim datapath'te
												input_array_wren_a = 1'b1;
												input_array_address_a_sel = 2'b11; // temp_Winv_index[8:0]
												
												int_add_sub_dataa_sel = 4'b0000; // ROWS
												int_add_sub_datab_sel = 4'b1000; // temp_Winv_index
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_temp_Winv_index = 1'b1;
												
												/*int_add_sub_dataa_sel = 3'b010; // int_mult_res_reg
												int_add_sub_datab_sel = 3'b111; // q_hat
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_q_hat = 1'b1;*/
												
												
												
												// Winv_index + j * COLUMNS + i
												/*int_mult_dataa_sel = 3'b101; // j
												int_mult_datab_sel = 3'b010; // ROWS
												ld_int_mult_res_reg = 1'b1;*/
												end
										
												
		FIRST_FOR_LOOP_INCREMENT_J: 	begin
												int_add_sub_dataa_sel = 4'b0101; // j
												int_add_sub_datab_sel = 4'b0000; // 1
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_j = 1'b1;
												end
																
		FIRST_FOR_LOOP_INCREMENT_I: 	begin
												int_add_sub_dataa_sel = 4'b0100; // i
												int_add_sub_datab_sel = 4'b0000; // 1
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_i = 1'b1;
												end
		
												/*begin // prime_diagonals[i] = last_diagonal / input_array[s_index + i], i = 0
												int_divider_numer_sel = 2'b00; 
												int_divider_denom_sel = 2'b00;
												ld_prime_diagonals = 1'b1;
												
												// carpimi da yap burada 
												// q_summand[i] = last_diagonal * input_array[q_index + i], i = 0
												
												end*/
												
		SECOND_FOR_LOOP_PREPARATION: 	begin
												clear_i = 1'b1;
												clear_j = 1'b1;
												ld_init_temp_Winv_index = 1'b1;
												end
												
		SECOND_FOR_LOOP_CHECK_I:   	begin
												int_comparator_dataa_sel = 3'b001; // i
												int_comparator_datab_sel = 3'b001; // ROWS
												
												input_array_address_a_sel = 2'b11; // input_array[temp_Winv_index]
												end
												
		SECOND_FOR_LOOP_CHECK_J:   	begin
												int_comparator_dataa_sel = 3'b010; // j
												int_comparator_datab_sel = 3'b001; // ROWS
												
												//input_array_address_a_sel = 2'b11; // input_array[temp_Winv_index]
												end
												
		SECOND_FOR_LOOP_Q_TRANS_0:		begin
												int_mult_dataa_sel = 2'b01; // input_array_q_a
												int_mult_datab_sel = 2'b01; // q_hat[j]
												ld_int_mult_res_reg = 1'b1;
												end
												
		SECOND_FOR_LOOP_Q_TRANS_1:		begin
												int_add_sub_dataa_sel = 4'b1000; // q_trans[i]
												int_add_sub_datab_sel = 4'b0110; // int_mult_res_reg
												int_add_sub_add_sub_sel = 1'b0; // substract
												ld_q_trans = 1'b1;
												end
												
		SECOND_FOR_LOOP_Q_TRANS_2:		begin 
												int_add_sub_dataa_sel = 4'b0111; // temp_Winv_index
												int_add_sub_datab_sel = 4'b0000; // 1
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_temp_Winv_index = 1'b1;
												end
												
		SECOND_FOR_LOOP_INCREMENT_J: 	begin
												int_add_sub_dataa_sel = 4'b0101; // j
												int_add_sub_datab_sel = 4'b0000; // 1
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_j = 1'b1;
												end
																
		SECOND_FOR_LOOP_INCREMENT_I: 	begin
												int_add_sub_dataa_sel = 4'b0100; // i
												int_add_sub_datab_sel = 4'b0000; // 1
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_i = 1'b1;
												
												clear_j = 1'b1; // j = 0;
												
												// 3. for loop icin
												q_array_address_sel = 2'b10; // Winv_index[8:0]
												ram_module_input_array_en = 1'b1;
												end		
												
		
		
		WHILE_LOOP:						begin // 31
											// inner_Res[ROWS]={0};
											clear_inner_Res = 1'b1; // inner_Res[i] = q_int[i]; burada q_translarin 12'si de yukleniyor
											clear_i = 1'b1;
											clear_j = 1'b1;	
											//ld_init_temp_Winv_index = 1'b1;
											
											ld_init_temp_Winv_index = 1'b1; // 3. for loop icin
											clear_parallel_multiplication_results = 1'b1;	
											end
		
		
		THIRD_FOR_LOOP_CHECK_I:   	begin // 32
											int_comparator_dataa_sel = 3'b001; // i
											int_comparator_datab_sel = 3'b001; // ROWS
											
											//input_array_address_a_sel = 2'b11; // input_array[temp_Winv_index]
											
											//q_array_address_sel = 1'b0; // temp_Winv_index sirayla gidiyor
											//clear_inner_Res = 1'b1; // inner_Res[i] = q_int[i];
											parallel_multiplication_second_operand_sel = 1'b0; // v_inner[j], v_inner[j+1], v_inner[j+2]...
											do_parallel_multiplication = 1'b1;
											
											int_add_sub_dataa_sel = 4'b0000; // ROWS
											int_add_sub_datab_sel = 4'b1000; // temp_Winv_index
											int_add_sub_add_sub_sel = 1'b1; // add
											ld_temp_Winv_index = 1'b1;
											end
											
		THIRD_FOR_LOOP_INNER_RES_0:  begin // 34
											  /*int_mult_dataa_sel = 3'b100; // input_array_q_a
											  int_mult_datab_sel = 3'b110; // v_inner[j]
											  ld_int_mult_res_reg = 1'b1; */
											  
											  // inner res in iç for looptaki son hali hesaplanip ld edilmeli burda
											  int_parallel_add_first_operand_sel = 1'b0; // inner_Res[i]
											  inner_Res_sel = 3'b100; // int_parallel_add_res
											  ld_inner_Res = 1'b1;
											  
											  q_array_address_sel = 2'b00; // temp_Winv_index[8:0];
											  ram_module_input_array_en = 1'b1;
											  end
											  
		THIRD_FOR_LOOP_INNER_RES_1:  begin // 35
											  /*int_add_sub_dataa_sel = 4'b1010; // inner_Res[i]
											  int_add_sub_datab_sel = 4'b0110; // int_mult_res_reg
											  int_add_sub_add_sub_sel = 1'b1; // add
											  
											  ld_int_add_sub_res_reg = 1'b1;*/
											  
											  /*int_add_sub_dataa_sel = 4'b0000; // ROWS
											  int_add_sub_datab_sel = 4'b1000; // temp_Winv_index
											  int_add_sub_add_sub_sel = 1'b1; // add
											  ld_temp_Winv_index = 1'b1;*/
											  
											  int_add_sub_dataa_sel = 4'b0100; // i
											  int_add_sub_datab_sel = 4'b0000; // 1
											  int_add_sub_add_sub_sel = 1'b1; // add
											  ld_i = 1'b1;
											  
											  numerator_sel = 1'b0;
											  assign_numerators = 1'b1;
											  end
											  
		THIRD_FOR_LOOP_INNER_RES_2:  begin 
											  //inner_Res_sel = 3'b001; // int_add_sub_res_reg
											  //ld_inner_Res = 1'b1;
											  
											  int_divider_clken = 1'b1;
											  clear_divider_counter = 1'b1;
											  end
												
		THIRD_FOR_LOOP_INNER_RES_3:  begin 
												int_divider_clken = 1'b1; // bolmeye devam
																									 
												int_add_sub_dataa_sel = 4'b1101; // 1
											   int_add_sub_datab_sel = 4'b1111; // divider_counter
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_divider_counter = 1'b1;
												end
												
		THIRD_FOR_LOOP_INNER_RES_4: begin 
												int_divider_clken = 1'b1; // bolmeye devam
												
												int_comparator_dataa_sel = 3'b111; // divider_counter
												int_comparator_datab_sel = 3'b010; // cycle sayisi
												
												parallel_res_adj_rst = 1'b1;
												end
												
		THIRD_FOR_LOOP_INNER_RES_5: begin 
												 //inner_Res_sel = 3'b010; // int_divider_remain
												 //ld_inner_Res = 1'b1;
												 
												 ld_remain_to_inner_Res = 1'b1;
												 
												 parallel_res_adj_en = 1'b1;
												 
												 // sonra alttaki state parallel_result_adj cond1 dogru gelirse
												 end
												
		THIRD_FOR_LOOP_INNER_RES_6:   begin // 3a
												/*//int_comparator_datab_i3_sel = 1'b0; // 0
												int_comparator_dataa_sel = 3'b011; // inner_Res[i]
												//int_comparator_datab_sel = 2'b11; // 0
												int_comparator_datab_sel = 3'b011; // 0
												
												ld_int_comparator_aeb_reg = 1'b1;
												ld_int_comparator_alb_reg = 1'b1;*/
												
												ld_result_adjuster_to_inner_Res = 1'b1;
												end

												
												
		FOURTH_FOR_LOOP_PREPARATION: begin	
											  ld_init_temp_Winv_index = 1'b1; // 3. for loop icin bu, fazla state eklememek için böyle yaptım
											  
											  clear_i = 1'b1;
											  clear_j = 1'b1;
											  ld_init_temp_V_index = 1'b1;
											  clear_outer = 1'b1;
											  clear_parallel_multiplication_results = 1'b1;
											  clear_numerators = 1'b1;
											  
											  q_array_address_sel = 2'b11;
											  ram_module_input_array_en = 1'b1;
											  end
										
							
		FOURTH_FOR_LOOP_CHECK_I:   	begin
												int_comparator_dataa_sel = 3'b001; // i
												int_comparator_datab_sel = 3'b001; // ROWS
												
												//clear_outer = 1'b1;

												//clear_j = 1'b1;
												
												//input_array_address_b_sel = 2'b11; // input_array[temp_V_index]
												
												// burada memoryi oku
												//q_array_address_sel = 2'b01; // temp_V_index sirayla gidiyor
												end
												
		/*FOURTH_FOR_LOOP_CHECK_J:   	begin
												int_comparator_dataa_sel = 3'b010; // j
												int_comparator_datab_sel = 3'b001; // ROWS
												
												input_array_address_b_sel = 2'b11; // input_array[temp_V_index]
												end	*/
												
		FOURTH_FOR_LOOP_OUTER_0:		begin
												/*int_mult_dataa_sel = 3'b110; // inner_Res[j]
												int_mult_datab_sel = 3'b011; // input_array_q_b
												ld_int_mult_res_reg = 1'b1;*/
												
												// burada paralel çarpma yap
												// burada memoryi oku
												//q_array_address_sel = 1'b1; // temp_V_index sirayla gidiyor
												parallel_multiplication_second_operand_sel = 1'b1; // inner_Res[j], inner_Res[j+1], inner_Res[j+2]...
												do_parallel_multiplication = 1'b1;
												end
												
		FOURTH_FOR_LOOP_OUTER_1:		begin
												// outer + input_array[temp_V_index] * inner_Res[j];
												/*int_add_sub_dataa_sel = 4'b0010; // int_mult_res_reg
												int_add_sub_datab_sel = 4'b1011; // outer
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_outer = 1'b1;*/
												
												// burada paralel toplama yap sonucu outer'a yaz
												int_parallel_add_first_operand_sel = 1'b1; // outer
												ld_outer = 1'b1;
												
												// temp_V_index + ROWS
												int_add_sub_dataa_sel = 4'b0000; // ROWS
												int_add_sub_datab_sel = 4'b1101; // temp_V_index
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_temp_V_index = 1'b1;
												end
												
      FOURTH_FOR_LOOP_OUTER_3:		begin
												// ++temp_V_index
												// int_add_sub_dataa_sel = 4'b1110; // temp_V_index
												// int_add_sub_datab_sel = 4'b0000; // 1
												
												/*int_add_sub_dataa_sel = 4'b1101; // 1
												int_add_sub_datab_sel = 4'b1101; // temp_V_index
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_temp_V_index = 1'b1;*/
												
												int_add_sub_dataa_sel = 4'b0100; // i
												int_add_sub_datab_sel = 4'b0000; // 1
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_i = 1'b1;
												
												//clear_outer = 1'b1;
												
												q_array_address_sel = 2'b01; // temp_V_index[8:0];
											   ram_module_input_array_en = 1'b1;
												end

		FOURTH_FOR_LOOP_RESULT_POINT_0: begin
												  // (outer + q_summand[i])
												  int_add_sub_dataa_sel = 4'b1111; // q_summand[i]
												  int_add_sub_datab_sel = 4'b1011; // outer
												  int_add_sub_add_sub_sel = 1'b1; // add
												  ld_int_add_sub_res_reg = 1'b1;  
												  
												  numerator_sel = 1'b1;
												  assign_numerators = 1'b1;
												  
												  // BURADA POINT COUNTUN 1000'DEN KUCUK OLUP OLMADIGINI HESAPLA 
												  int_comparator_dataa_sel = 3'b110; // point_count
												  int_comparator_datab_sel = 3'b111; // 1000
												  end
												  
		FOURTH_FOR_LOOP_RESULT_POINT_1: begin
												  // eger 1000 point olmussa sifirla
												  clear_point_count = 1'b1;
												  end
												  
		FOURTH_FOR_LOOP_RESULT_POINT_2: begin
												  // result_point[point_count][i] = (outer + q_summand[i]) / last_diagonal;
												  int_divider_numer_sel = 2'b10; // int_add_sub_res_reg
												  int_divider_denom_sel = 2'b01; // last_diagonal
												  int_divider_clken = 1'b1;
												  
												  clear_divider_counter = 1'b1;
												  //ld_result_point = 1'b1;
												  
												  /*int_add_sub_dataa_sel = 4'b1101; // 1
												  int_add_sub_datab_sel = 4'b1110; // point_count
												  int_add_sub_add_sub_sel = 1'b1; // add
												  ld_point_count = 1'b1;*/
												  end
												  
		FOURTH_FOR_LOOP_RESULT_POINT_3: begin
												  int_divider_clken = 1'b1; // bolmeye devam
													 
												  int_add_sub_dataa_sel = 4'b1101; // 1
												  int_add_sub_datab_sel = 4'b1111; // divider_counter
												  int_add_sub_add_sub_sel = 1'b1; // add
												  ld_divider_counter = 1'b1;
												  end
													
		FOURTH_FOR_LOOP_RESULT_POINT_4: begin
												  int_divider_clken = 1'b1; // bolmeye devam
													 
												  int_comparator_dataa_sel = 3'b111; // divider_counter
												  int_comparator_datab_sel = 3'b010; // cycle sayisi
												  end
												  
		FOURTH_FOR_LOOP_RESULT_POINT_5: begin // 7'h67
												  ld_result_point = 1'b1;
												  
												  int_add_sub_dataa_sel = 4'b1101; // 1
												  int_add_sub_datab_sel = 4'b1100; // total_point_count
											     int_add_sub_add_sub_sel = 1'b1; // add
											     ld_total_point_count = 1'b1;
												  end
		
		FOURTH_FOR_LOOP_INCREMENT_I: 	begin
												int_add_sub_dataa_sel = 4'b0100; // i
												int_add_sub_datab_sel = 4'b0000; // 1
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_i = 1'b1;
												
												clear_j = 1'b1; // j = 0;
												clear_outer = 1'b1;
												
												q_array_address_sel = 2'b01; // temp_V_index[8:0];
											   ram_module_input_array_en = 1'b1;
												end
												
								
												
				
		INNER_WHILE_PREPARATION: begin // i = ROWS-1;
										 i_sel = 1'b1;
										 ld_i = 1'b1;
										 
										 // ++point_count
										 int_add_sub_dataa_sel = 4'b1101; // 1
										 int_add_sub_datab_sel = 4'b1110; // point_count
										 int_add_sub_add_sub_sel = 1'b1; // add
										 ld_point_count = 1'b1;
										 end
										 
										 						
		INNER_WHILE_0:				begin 
										// while(i >= 0) kontrolu bu state'te yapilacak
										//int_comparator_dataa_i1_sel = 1'b0; // i
										//int_comparator_datab_i3_sel = 1'b0; // 0
										int_comparator_dataa_sel = 3'b001; // i
										//int_comparator_datab_sel = 2'b11;
										int_comparator_datab_sel = 3'b011; // 0
										
										// input_array[s_index+i]
										int_add_sub_dataa_sel = 4'b0100; // i
										int_add_sub_datab_sel = 4'b0101; // s_index
										int_add_sub_add_sub_sel = 1'b1; // add
										
										input_array_address_a_sel = 2'b00; // int_add_sub_res
										end
							
		INNER_WHILE_1: 			begin 
										// input_array[s_index+i]-1
										int_add_sub_dataa_sel = 4'b1100; // input_array_q_a
										int_add_sub_datab_sel = 4'b0000; // 1
										int_add_sub_add_sub_sel = 1'b0; // substract
										ld_int_add_sub_res_reg = 1'b1;
										end
		
		INNER_WHILE_2:				begin
										// if(v_inner[i] < input_array[s_index+i]-1)
										//int_comparator_dataa_i1_sel = 1'b1; // v_inner[i]
										//int_comparator_datab_i0_sel = 1'b1; // int_add_sub_res_reg
										int_comparator_dataa_sel = 3'b101; // v_inner[i]
										//int_comparator_datab_sel = 2'b00;
										int_comparator_datab_sel = 3'b100; // int_add_sub_res_reg
										end
										
		INNER_WHILE_3:				begin
										// v_inner[i] = v_inner[i] + 1; break;
									   int_add_sub_dataa_sel = 4'b1011; // v_inner[i]
										int_add_sub_datab_sel = 4'b0000; // 1
										int_add_sub_add_sub_sel = 1'b1; // add
										v_inner_sel = 1'b1;
										ld_v_inner = 1'b1;
										end
												
		INNER_WHILE_4:				begin
										// v_inner[i] = 0;
										v_inner_sel = 1'b0;
										ld_v_inner = 1'b1;
										end
										
		INNER_WHILE_5:				begin
										// i-=1;
									   int_add_sub_dataa_sel = 4'b0100; // i
										int_add_sub_datab_sel = 4'b0000; // 1
										int_add_sub_add_sub_sel = 1'b0; // substract
										i_sel = 1'b0;
										ld_i = 1'b1;
										end
										
		
		CHECK_BREAK_CONDITION: begin
									  //int_comparator_dataa_i1_sel = 1'b0; // i
									  //int_comparator_datab_i1_sel = 1'b1; // 64'hFFFFFFFFFFFFFFFF
									  int_comparator_dataa_sel = 3'b001; // i
									  //int_comparator_datab_sel = 2'b01;
									  int_comparator_datab_sel = 3'b101; // 64'hFFFFFFFFFFFFFFFF
									  
									  q_array_address_sel = 2'b10;
									  ram_module_input_array_en = 1'b1;
									  end												
		
		OUTER_FOR_LOOP_INCREMENT:		begin // ++each_cone
												int_add_sub_dataa_sel = 4'b0001; // each_cone
												int_add_sub_datab_sel = 4'b0000; // 1
												int_add_sub_add_sub_sel = 1'b1; // add
												ld_each_cone = 1'b1;
											
												end
												
		DONE: begin
				generation_done = 1'b1;
				end
								
		
	endcase
end
	

endmodule