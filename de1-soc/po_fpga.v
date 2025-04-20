module po_fpga(

	//////////// CLOCK //////////
	/*input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,*/
	input 		          		CLOCK_50,

	//////////// SDRAM //////////
	/*output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,*/

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// IR //////////
	/*input 		          		IRDA_RXD,
	output		          		IRDA_TXD,*/

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// HPS //////////
	//inout 		          		HPS_CONV_USB_N,
	//output		    [14:0]		HPS_DDR3_ADDR,
	output		    [12:0]		HPS_DDR3_ADDR,
	output		     [2:0]		HPS_DDR3_BA,
	output		          		HPS_DDR3_CAS_N,
	output		          		HPS_DDR3_CKE,
	output		          		HPS_DDR3_CK_N,
	output		          		HPS_DDR3_CK_P,
	output		          		HPS_DDR3_CS_N,
	//output		     [3:0]		HPS_DDR3_DM,
	output		               HPS_DDR3_DM,
	//inout 		    [31:0]		HPS_DDR3_DQ,
	inout 		    [7:0]		HPS_DDR3_DQ,
	//inout 		    [3:0]      HPS_DDR3_DQS_N,
	//inout 		    [3:0]      HPS_DDR3_DQS_P,
	inout 		     				HPS_DDR3_DQS_P,
	inout 		     				HPS_DDR3_DQS_N,
	output		          		HPS_DDR3_ODT,
	output		          		HPS_DDR3_RAS_N,
	output		          		HPS_DDR3_RESET_N,
	input 		          		HPS_DDR3_RZQ,
	output		          		HPS_DDR3_WE_N,
	
	// kullanilmiyor
	/*output		          		HPS_ENET_GTX_CLK,
	inout 		          		HPS_ENET_INT_N,
	output		          		HPS_ENET_MDC,
	inout 		          		HPS_ENET_MDIO,
	input 		          		HPS_ENET_RX_CLK,
	input 		     [3:0]		HPS_ENET_RX_DATA,
	input 		          		HPS_ENET_RX_DV,
	output		     [3:0]		HPS_ENET_TX_DATA,
	output		          		HPS_ENET_TX_EN,
	inout 		     [3:0]		HPS_FLASH_DATA,
	output		          		HPS_FLASH_DCLK,
	output		          		HPS_FLASH_NCSO,
	inout 		     [1:0]		HPS_GPIO,
	inout 		          		HPS_GSENSOR_INT,
	inout 		          		HPS_I2C1_SCLK,
	inout 		          		HPS_I2C1_SDAT,
	inout 		          		HPS_I2C2_SCLK,
	inout 		          		HPS_I2C2_SDAT,
	inout 		          		HPS_I2C_CONTROL,
	inout 		          		HPS_KEY,
	inout 		          		HPS_LED,
	output		          		HPS_SD_CLK,
	inout 		          		HPS_SD_CMD,
	inout 		     [3:0]		HPS_SD_DATA,
	output		          		HPS_SPIM_CLK,
	input 		          		HPS_SPIM_MISO,
	output		          		HPS_SPIM_MOSI,
	inout 		          		HPS_SPIM_SS,*/
	input 		          		HPS_UART_RX,
	output		          		HPS_UART_TX
	/*input 		          		HPS_USB_CLKOUT,
	inout 		     [7:0]		HPS_USB_DATA,
	input 		          		HPS_USB_DIR,
	input 		          		HPS_USB_NXT,
	output		          		HPS_USB_STP*/
);

parameter ROWS = 5;

wire clk, generation_done, sending_done, reset, go_i;
wire clk_0, clk_1, clk_2, clk_3, clk_80, clk_90, clk_100, clk_110, clk_120;

wire raw_reset = ~KEY[3];
wire raw_go_i = ~KEY[2];

one_shot_button one_shot_button_reset (
    .clk(clk),
    .button(raw_reset),
    .pulse_out(reset)
);

one_shot_button one_shot_button_go_i (
    .clk(clk),
    .button(raw_go_i),
    .pulse_out(go_i)
);

//assign clk = CLOCK_50;

my_clock test_clock(
	.refclk(CLOCK_50),
	.rst(SW[9]),
	.outclk_0(clk_0), // 100
	.locked(LEDR[1])
);

assign clk = clk_0; 

wire cu_dp_clock_enable;
wire cu_dp_clock;
wire valid;

alt_clk controlled_clock_ip (
	.inclk  (clk),  //  altclkctrl_input.inclk
	.ena    (cu_dp_clock_enable),    //                  .ena
	.outclk (cu_dp_clock)  // altclkctrl_output.outclk
);

wire [63:0] total_cycle_count;
cycle_counter total_cycle_ctr (
    .clk(clk),        
    .reset(reset),       
    .go_i(go_i),
    .done(sending_done),
    .cycle_count(total_cycle_count)
	 // .counting()
);

wire [63:0] generation_cycle_count;
/*cycle_counter generation_cycle_ctr (
    .clk(clk),        
    .reset(reset),       
    .go_i(go_i),
    .done(generation_done),
    .cycle_count(generation_cycle_count)
	 // .counting()
);*/

/*my_clock test_clock(
	.refclk(CLOCK_50_B5B),
	.rst(SW[9]),
	.outclk_0(clk_0), // 60
	.outclk_1(clk_1), // 65
	.outclk_2(clk_2), // 70
	.outclk_3(clk_3), // 75
	.locked(LEDR[1])
);

reg clk_mux;
always @(*) begin
  //case (SW[9:6])
  case (SW[7:6])
		2'b00: clk_mux = clk_0; 
		2'b01: clk_mux = clk_1;
		2'b10: clk_mux = clk_2; 
		2'b11: clk_mux = clk_3; 
		default: clk_mux = clk_0;
  endcase
end

assign clk = clk_mux;*/

assign LEDR[0] = ~generation_done;

reg [3:0] NUMBER_OF_CONES = 1;

wire [31:0] fpga_total_point_count;
wire [6:0] current_state_test;
//assign LEDR[9:3] = current_state_test;

wire [95:0] to_hps;

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

control_unit cu (
	.go_i(go_i),
	.reset(reset),
	//.clk(clk),
	.clk(cu_dp_clock),
	.generation_done(generation_done),
	
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
	.inner_Res_and_input_array(inner_Res_and_input_array),
	
	.current_state_test(current_state_test),
	.state_count_wire(generation_cycle_count)
);

datapath #(
    .ROWS(ROWS)
) dp (
	.go_i(go_i),
	//.clk(clk),
	.clk(cu_dp_clock),
	.reset(reset),
	
	.NUMBER_OF_CONES(NUMBER_OF_CONES),
	
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
	
	.int_comparator_aeb(int_comparator_aeb),
	.int_comparator_alb(int_comparator_alb),
	.int_comparator_not_alb(int_comparator_not_alb),
	.j_index_comparator_alb(j_index_comparator_alb),
	.inner_Res_and_input_array(inner_Res_and_input_array),
	.ld_result_adjuster_to_inner_Res(ld_result_adjuster_to_inner_Res),
	.parallel_res_adj_rst(parallel_res_adj_rst),
	.parallel_res_adj_en(parallel_res_adj_en),
	
	.rows_mult_dataa_sel(rows_mult_dataa_sel),
	.rows_mult_datab_sel(rows_mult_datab_sel),
	.ld_rows_mult_res_reg(ld_rows_mult_res_reg),
	
	.condition1_triggered(condition1_triggered),
	.condition2_triggered(condition2_triggered),
	
	.fpga_total_point_count(fpga_total_point_count),
	
	.to_hps(to_hps)
);


wire [31:0] number_out;
wire hps_valid;

sequential_sender seq_sender (
    .clk(clk),
    .reset(reset),
    .load(ld_result_point),
	 .ROWS(ROWS[5:0]),
    .data_in_0(to_hps[31:0]),
    .data_in_1(to_hps[63:32]),
    .data_in_2(to_hps[95:64]),
    .number_out(number_out),
	 .valid_pulse(hps_valid),
	 .generation_done(generation_done),
	 .sending_done(sending_done),
	 .valid(valid),
	 .cu_dp_clock_enable(cu_dp_clock_enable),
	 .debug_state(LEDR[9:2])
);

parallel_hps_single_pio parallelhps (
	.clk_clk                 			(clk),
	.hps_io_hps_io_uart1_inst_RX		(HPS_UART_RX),
	.hps_io_hps_io_uart1_inst_TX		(HPS_UART_TX),
	.memory_mem_a            			(HPS_DDR3_ADDR),
	.memory_mem_ba           			(HPS_DDR3_BA),
	.memory_mem_ck           			(HPS_DDR3_CK_P),  // Note: Adjusted as DDR3 typically uses a differential pair
	.memory_mem_ck_n         			(HPS_DDR3_CK_N),
	.memory_mem_cke          			(HPS_DDR3_CKE),
	.memory_mem_cs_n         			(HPS_DDR3_CS_N),
	.memory_mem_ras_n        			(HPS_DDR3_RAS_N),
	.memory_mem_cas_n        			(HPS_DDR3_CAS_N),
	.memory_mem_we_n         			(HPS_DDR3_WE_N),
	.memory_mem_reset_n      			(HPS_DDR3_RESET_N),
	
	.memory_mem_dm           			(HPS_DDR3_DM), 
	
	.memory_mem_dq           			(HPS_DDR3_DQ),
	.memory_mem_dqs          			(HPS_DDR3_DQS_P), // Note: Adjusted as DDR3 typically uses a differential pair
	.memory_mem_dqs_n        			(HPS_DDR3_DQS_N),
	
	.memory_mem_odt          			(HPS_DDR3_ODT),
	.memory_oct_rzqin        			(HPS_DDR3_RZQ),
	.parallel_input_export	 			(number_out),
	.hps_valid_export						(hps_valid)
);


parameter [6:0] SEGMENT_0 = 7'b1000000; // Digit 0
parameter [6:0] SEGMENT_1 = 7'b1111001; // Digit 1
parameter [6:0] SEGMENT_2 = 7'b0100100; // Digit 2
parameter [6:0] SEGMENT_3 = 7'b0110000; // Digit 3
parameter [6:0] SEGMENT_4 = 7'b0011001; // Digit 4
parameter [6:0] SEGMENT_5 = 7'b0010010; // Digit 5
parameter [6:0] SEGMENT_6 = 7'b0000010; // Digit 6
parameter [6:0] SEGMENT_7 = 7'b1111000; // Digit 7
parameter [6:0] SEGMENT_8 = 7'b0000000; // Digit 8
parameter [6:0] SEGMENT_9 = 7'b0010000; // Digit 9
parameter [6:0] SEGMENT_A = 7'b0001000; // Digit A
parameter [6:0] SEGMENT_B = 7'b0000011; // Digit B
parameter [6:0] SEGMENT_C = 7'b1000110; // Digit C
parameter [6:0] SEGMENT_D = 7'b0100001; // Digit D
parameter [6:0] SEGMENT_E = 7'b0000110; // Digit E
parameter [6:0] SEGMENT_F = 7'b0001110; // Digit F

reg [3:0] chunk_A, chunk_B, chunk_C, chunk_D, chunk_E, chunk_F, chunk_G, chunk_H;

reg [3:0] total_cycle_part_A, total_cycle_part_B, total_cycle_part_C, total_cycle_part_D, 
				total_cycle_part_E, total_cycle_part_F, total_cycle_part_G, total_cycle_part_H, 
				total_cycle_part_I, total_cycle_part_J, total_cycle_part_K, total_cycle_part_L, 
				total_cycle_part_M, total_cycle_part_N, total_cycle_part_O, total_cycle_part_P;

reg [3:0] generation_cycle_count_part_A, generation_cycle_count_part_B, generation_cycle_count_part_C, 
			generation_cycle_count_part_D, generation_cycle_count_part_E, generation_cycle_count_part_F, 
			generation_cycle_count_part_G, generation_cycle_count_part_H, generation_cycle_count_part_I, 
			generation_cycle_count_part_J, generation_cycle_count_part_K, generation_cycle_count_part_L, 
			generation_cycle_count_part_M, generation_cycle_count_part_N, generation_cycle_count_part_O, 
			generation_cycle_count_part_P;

reg [6:0] hex_0, hex_1, hex_2, hex_3, hex_4, hex_5;

always @* begin
	 chunk_A = fpga_total_point_count[31:28];
	 chunk_B = fpga_total_point_count[27:24];
	 chunk_C = fpga_total_point_count[23:20];
	 chunk_D = fpga_total_point_count[19:16];
    chunk_E = fpga_total_point_count[15:12];
    chunk_F = fpga_total_point_count[11:8];
    chunk_G = fpga_total_point_count[7:4];
    chunk_H = fpga_total_point_count[3:0];
	 
	 total_cycle_part_A = total_cycle_count[63:60];
	 total_cycle_part_B = total_cycle_count[59:56];
	 total_cycle_part_C = total_cycle_count[55:52];
	 total_cycle_part_D = total_cycle_count[51:48];
	 total_cycle_part_E = total_cycle_count[47:44];
	 total_cycle_part_F = total_cycle_count[43:40];
	 total_cycle_part_G = total_cycle_count[39:36];
	 total_cycle_part_H = total_cycle_count[35:32];
	 total_cycle_part_I = total_cycle_count[31:28];
	 total_cycle_part_J = total_cycle_count[27:24];
	 total_cycle_part_K = total_cycle_count[23:20];
	 total_cycle_part_L = total_cycle_count[19:16];
	 total_cycle_part_M = total_cycle_count[15:12];
	 total_cycle_part_N = total_cycle_count[11:8];
	 total_cycle_part_O = total_cycle_count[7:4];
	 total_cycle_part_P = total_cycle_count[3:0];
	 
	 generation_cycle_count_part_A = generation_cycle_count[63:60];
	 generation_cycle_count_part_B = generation_cycle_count[59:56];
	 generation_cycle_count_part_C = generation_cycle_count[55:52];
	 generation_cycle_count_part_D = generation_cycle_count[51:48];
	 generation_cycle_count_part_E = generation_cycle_count[47:44];
	 generation_cycle_count_part_F = generation_cycle_count[43:40];
	 generation_cycle_count_part_G = generation_cycle_count[39:36];
	 generation_cycle_count_part_H = generation_cycle_count[35:32];
	 generation_cycle_count_part_I = generation_cycle_count[31:28];
	 generation_cycle_count_part_J = generation_cycle_count[27:24];
	 generation_cycle_count_part_K = generation_cycle_count[23:20];
	 generation_cycle_count_part_L = generation_cycle_count[19:16];
	 generation_cycle_count_part_M = generation_cycle_count[15:12];
	 generation_cycle_count_part_N = generation_cycle_count[11:8];
	 generation_cycle_count_part_O = generation_cycle_count[7:4];
	 generation_cycle_count_part_P = generation_cycle_count[3:0];

	 if (SW[5]) begin
		hex_5 = 7'b1111111;
		hex_4 = 7'b1111111;
		hex_3 = 7'b1111111;
		hex_2 = 7'b1111111;
		hex_1 = get_segment({1'b0, current_state_test[6:4]});
		hex_0 = get_segment(current_state_test[3:0]);
		/*hex_5 = 7'b1111111;
		hex_4 = 7'b1111111;
		hex_3 = get_segment(total_cycle_part_A);
		hex_2 = get_segment(total_cycle_part_B);
		hex_1 = get_segment(total_cycle_part_C);
		hex_0 = get_segment(total_cycle_part_D);*/
	 end else if (SW[4]) begin
		hex_5 = get_segment(total_cycle_part_E);
		hex_4 = get_segment(total_cycle_part_F);
		hex_3 = get_segment(total_cycle_part_G);
		hex_2 = get_segment(total_cycle_part_H);
		hex_1 = get_segment(total_cycle_part_I);
		hex_0 = get_segment(total_cycle_part_J);
	 end else if (SW[3]) begin
		hex_5 = get_segment(total_cycle_part_K);
		hex_4 = get_segment(total_cycle_part_L);
		hex_3 = get_segment(total_cycle_part_M);
		hex_2 = get_segment(total_cycle_part_N);
		hex_1 = get_segment(total_cycle_part_O);
		hex_0 = get_segment(total_cycle_part_P);
		/*hex_5 = 7'b1111111;
		hex_4 = 7'b1111111;
		hex_3 = get_segment(generation_cycle_count_part_A);
		hex_2 = get_segment(generation_cycle_count_part_B);
		hex_1 = get_segment(generation_cycle_count_part_C);
		hex_0 = get_segment(generation_cycle_count_part_D);*/
	 end else if (SW[2]) begin
		hex_5 = get_segment(generation_cycle_count_part_E);
		hex_4 = get_segment(generation_cycle_count_part_F);
		hex_3 = get_segment(generation_cycle_count_part_G);
		hex_2 = get_segment(generation_cycle_count_part_H);
		hex_1 = get_segment(generation_cycle_count_part_I);
		hex_0 = get_segment(generation_cycle_count_part_J);
	 end else if (SW[1]) begin
		hex_5 = get_segment(generation_cycle_count_part_K);
		hex_4 = get_segment(generation_cycle_count_part_L);
		hex_3 = get_segment(generation_cycle_count_part_M);
		hex_2 = get_segment(generation_cycle_count_part_N);
		hex_1 = get_segment(generation_cycle_count_part_O);
		hex_0 = get_segment(generation_cycle_count_part_P);
	 end else if (SW[0]) begin // point count
		hex_5 = 7'b1111111;
		hex_4 = 7'b1111111;
		hex_3 = 7'b1111111;
		hex_2 = 7'b1111111;
		hex_1 = get_segment(chunk_A);
		hex_0 = get_segment(chunk_B);
	 end else begin
		hex_5 = get_segment(chunk_C);
		hex_4 = get_segment(chunk_D);
		hex_3 = get_segment(chunk_E);
		hex_2 = get_segment(chunk_F);
		hex_1 = get_segment(chunk_G);
		hex_0 = get_segment(chunk_H);
	 end
end

assign HEX5 = hex_5;
assign HEX4 = hex_4;
assign HEX3 = hex_3;
assign HEX2 = hex_2;
assign HEX1 = hex_1;
assign HEX0 = hex_0;


function [6:0] get_segment(input [3:0] chunk);
    begin
        case(chunk)
            4'b0000: get_segment = SEGMENT_0;
            4'b0001: get_segment = SEGMENT_1;
            4'b0010: get_segment = SEGMENT_2;
            4'b0011: get_segment = SEGMENT_3;
            4'b0100: get_segment = SEGMENT_4;
            4'b0101: get_segment = SEGMENT_5;
            4'b0110: get_segment = SEGMENT_6;
            4'b0111: get_segment = SEGMENT_7;
            4'b1000: get_segment = SEGMENT_8;
            4'b1001: get_segment = SEGMENT_9;
            4'b1010: get_segment = SEGMENT_A;
            4'b1011: get_segment = SEGMENT_B;
            4'b1100: get_segment = SEGMENT_C;
            4'b1101: get_segment = SEGMENT_D;
            4'b1110: get_segment = SEGMENT_E;
            4'b1111: get_segment = SEGMENT_F;
            default: get_segment = 7'b1110111;
        endcase
    end
endfunction


endmodule
