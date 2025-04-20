`timescale 1ns / 1ps

module tb_po_fpga;

	//integer ROWSCL = 3;
	
    // Inputs
    reg clk;
    reg go_i;
	 reg reset;
	 reg yeni = 1;
	 //reg [3:0] ROWS = 3;
	 //reg [3:0] NUMBER_OF_CONES = 1;

    // Outputs
    wire done;
	 
	 parameter ROWS = 9;
	 
	 po_fpga_simulation #(
		.ROWS(ROWS)
	 ) uut (
        .clk(clk), 
        .go_i(go_i), 
        .done(done),
		  .reset(reset)
    );

	 initial begin
        clk = 0;
        forever #10 clk = ~clk; // Clock period is 10 ns
    end

    integer file_id;
	 integer i;
	 reg signed [63:0] signed_q_hat, signed_q_trans, signed_inner_Res, signed_outer;
	 
	 always @(posedge clk) begin
		/*if (uut.cu.current_state == uut.cu.FIRST_FOR_LOOP_CHECK_J) begin
			for (i = 0; i < uut.dp.ROWS; i = i + 1) begin
				$display("prime_diagonals[%0d] = %0d", i, uut.dp.prime_diagonals[i]);
				$display("q_summand[%0d] = %0d", i, uut.dp.q_summand[i]);
			end
		end*/
		
		/*else if (uut.cu.current_state == uut.cu.FIRST_FOR_LOOP_Q_HAT_2) begin
			$display("int_mult_res = %0d", uut.dp.int_mult_res);
		end*/
		
		/*else if (uut.cu.current_state == uut.cu.FIRST_FOR_LOOP_INCREMENT_J) begin
			for (i = 0; i < uut.dp.ROWS; i = i + 1) begin
				$display("q_hat[%0d] = %0d", i, uut.dp.q_hat[i]);
			end
			//$display("int_mult_res_reg = %0d", uut.dp.int_mult_res_reg); // deneyip gorme amacli rege koydum
			//$display("-");
		end*/
		
		if (uut.cu.current_state == uut.cu.SECOND_FOR_LOOP_PREPARATION) begin
			for (i = 0; i < uut.dp.ROWS; i = i + 1) begin
					$display("prime_diagonals[%0d] = %0d", i, uut.dp.prime_diagonals[i]);
					$fwrite(file_id, "prime_diagonals[%0d] = %0d\n", i, uut.dp.prime_diagonals[i]);
			end
			
			for (i = 0; i < uut.dp.ROWS; i = i + 1) begin
				$display("q_summand[%0d] = %0d", i, uut.dp.q_summand[i]);
				$fwrite(file_id, "q_summand[%0d] = %0d\n", i, uut.dp.q_summand[i]);
			end
			
			/*for (i = 0; i < uut.dp.ROWS; i = i + 1) begin
				$display("q_hat[%0d] = %0d", i, uut.dp.q_hat[i]);
			end*/
			
			//$display("-----");
		end
		
		else if (uut.cu.current_state == uut.cu.FIRST_FOR_LOOP_INCREMENT_J) begin
			signed_q_hat = uut.dp.q_hat[uut.dp.i];
			$display("q_hat[%0d] = %0d", uut.dp.i, signed_q_hat);
			$fwrite(file_id, "q_hat[%0d] = %0d\n", uut.dp.i, signed_q_hat);
		end
		
		else if (uut.cu.current_state == uut.cu.SECOND_FOR_LOOP_INCREMENT_J) begin
			signed_q_trans = uut.dp.q_trans[uut.dp.i];
			$display("q_trans[%0d] = %0d", uut.dp.i, signed_q_trans);
			$fwrite(file_id, "q_trans[%0d] = %0d\n", uut.dp.i, signed_q_trans);
		end
		
		/*else if (uut.cu.current_state == uut.cu.FOURTH_FOR_LOOP_PREPARATION) begin
			for (i = 0; i < uut.dp.ROWS; i = i + 1) begin
				signed_inner_Res = uut.dp.inner_Res[i];
				$display("inner_Res[%0d] = %0d\n", i, signed_inner_Res);
				//$fwrite(file_id, "inner_Res[%0d] = %0d\n", i, signed_inner_Res);
			end
		end
		
		else if (uut.cu.current_state == uut.cu.INNER_WHILE_PREPARATION) begin
			for (i = 0; i < uut.dp.ROWS; i = i + 1) begin
				signed_outer = uut.dp.outer[i];
				$display("outer[%0d] = %0d", i, signed_outer);
				//$fwrite(file_id, "outer[%0d] = %0d\n", i, signed_outer);
			end
		end
		
		else if (uut.cu.current_state == uut.cu.FOURTH_FOR_LOOP_RESULT_POINT_5) begin
			$display("%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n", uut.dp.quot0, uut.dp.quot1, uut.dp.quot2, uut.dp.quot3, uut.dp.quot4, uut.dp.quot5, uut.dp.quot6, uut.dp.quot7, uut.dp.quot8, uut.dp.quot9);
		end*/
		
		else if (uut.cu.current_state == uut.cu.PRINT_TOTAL_POINT_COUNT) begin
				$display("total_point_count = %0d", uut.dp.total_point_count);
				$display("state_count = %0d", uut.cu.state_count);
		end
	
		/*else if (uut.cu.current_state == uut.cu.OUTER_FOR_LOOP_INCREMENT) begin
			$display("=============================================");
		end*/
		
		/*else if (uut.cu.current_state == uut.cu.DONE) begin
			for (i = 0; i < 150; i = i + 1) begin
				uut.dp.input_array_address_b = i;
				$display("input_array[%0d] = %0d", i, uut.dp.input_array_q_b);
			end
		end*/
	 end
	 
	 reg signed [63:0] signed_var;
	 
    initial begin  
		  
		  /*if ($value$plusargs("ROWSCL=%d", ROWSCL)) begin
            $display("Parsed ROWSCL = %d", ROWSCL);
				uut.dp.ROWS = ROWSCL;
        end else begin
            $display("No command-line argument for input_value");
				uut.dp.ROWS = 3;
        end*/
	 
		  //uut.ROWS = 6;
		  
		  uut.NUMBER_OF_CONES = 1;
		  
		  reset = 0;
		  go_i = 1;
		 
        #30;
		  go_i = 0;
		  
		  case (ROWS)
				2: begin
					$readmemh("data2.hex", uut.dp.input_array.mem_array);
					$readmemh("data2.hex", uut.dp.ram_module_input_array.memory0);
					$readmemh("data2.hex", uut.dp.ram_module_input_array.memory1);
					$readmemh("data2.hex", uut.dp.ram_module_input_array.memory2);
					$readmemh("data2.hex", uut.dp.ram_module_input_array.memory3);
					$readmemh("data2.hex", uut.dp.ram_module_input_array.memory4);
					$readmemh("data2.hex", uut.dp.ram_module_input_array.memory5);
					end
            3: begin
					$readmemh("data3.hex", uut.dp.input_array.mem_array);
					$readmemh("data3.hex", uut.dp.ram_module_input_array.memory0);
					$readmemh("data3.hex", uut.dp.ram_module_input_array.memory1);
					$readmemh("data3.hex", uut.dp.ram_module_input_array.memory2);
					$readmemh("data3.hex", uut.dp.ram_module_input_array.memory3);
					$readmemh("data3.hex", uut.dp.ram_module_input_array.memory4);
					$readmemh("data3.hex", uut.dp.ram_module_input_array.memory5);
					end
            4: begin
					$readmemh("data4.hex", uut.dp.input_array.mem_array);
					$readmemh("data4.hex", uut.dp.ram_module_input_array.memory0);
					$readmemh("data4.hex", uut.dp.ram_module_input_array.memory1);
					$readmemh("data4.hex", uut.dp.ram_module_input_array.memory2);
					$readmemh("data4.hex", uut.dp.ram_module_input_array.memory3);
					$readmemh("data4.hex", uut.dp.ram_module_input_array.memory4);
					$readmemh("data4.hex", uut.dp.ram_module_input_array.memory5);
					end
            5: begin
					$readmemh("data5.hex", uut.dp.input_array.mem_array);
					$readmemh("data5.hex", uut.dp.ram_module_input_array.memory0);
					$readmemh("data5.hex", uut.dp.ram_module_input_array.memory1);
					$readmemh("data5.hex", uut.dp.ram_module_input_array.memory2);
					$readmemh("data5.hex", uut.dp.ram_module_input_array.memory3);
					$readmemh("data5.hex", uut.dp.ram_module_input_array.memory4);
					$readmemh("data5.hex", uut.dp.ram_module_input_array.memory5);
					end
            6: begin
						if (yeni) begin
							$readmemh("data6_yeni.hex", uut.dp.input_array.mem_array);
							$readmemh("data6_yeni.hex", uut.dp.ram_module_input_array.memory0);
							$readmemh("data6_yeni.hex", uut.dp.ram_module_input_array.memory1);
							$readmemh("data6_yeni.hex", uut.dp.ram_module_input_array.memory2);
							$readmemh("data6_yeni.hex", uut.dp.ram_module_input_array.memory3);
							$readmemh("data6_yeni.hex", uut.dp.ram_module_input_array.memory4);
							$readmemh("data6_yeni.hex", uut.dp.ram_module_input_array.memory5);
						end else begin
							$readmemh("data6.hex", uut.dp.input_array.mem_array);
							$readmemh("data6.hex", uut.dp.ram_module_input_array.memory0);
							$readmemh("data6.hex", uut.dp.ram_module_input_array.memory1);
							$readmemh("data6.hex", uut.dp.ram_module_input_array.memory2);
							$readmemh("data6.hex", uut.dp.ram_module_input_array.memory3);
							$readmemh("data6.hex", uut.dp.ram_module_input_array.memory4);
							$readmemh("data6.hex", uut.dp.ram_module_input_array.memory5);
						end
					
					end
            7: begin
						if (yeni) begin
							$readmemh("data7_yeni.hex", uut.dp.input_array.mem_array);
							$readmemh("data7_yeni.hex", uut.dp.ram_module_input_array.memory0);
							$readmemh("data7_yeni.hex", uut.dp.ram_module_input_array.memory1);
							$readmemh("data7_yeni.hex", uut.dp.ram_module_input_array.memory2);
							$readmemh("data7_yeni.hex", uut.dp.ram_module_input_array.memory3);
							$readmemh("data7_yeni.hex", uut.dp.ram_module_input_array.memory4);
							$readmemh("data7_yeni.hex", uut.dp.ram_module_input_array.memory5);
						end else begin
							$readmemh("data7.hex", uut.dp.input_array.mem_array);
							$readmemh("data7.hex", uut.dp.ram_module_input_array.memory0);
							$readmemh("data7.hex", uut.dp.ram_module_input_array.memory1);
							$readmemh("data7.hex", uut.dp.ram_module_input_array.memory2);
							$readmemh("data7.hex", uut.dp.ram_module_input_array.memory3);
							$readmemh("data7.hex", uut.dp.ram_module_input_array.memory4);
							$readmemh("data7.hex", uut.dp.ram_module_input_array.memory5);
						end
					end
            8: begin
						if (yeni) begin
							$readmemh("data8_yeni.hex", uut.dp.input_array.mem_array);
							$readmemh("data8_yeni.hex", uut.dp.ram_module_input_array.memory0);
							$readmemh("data8_yeni.hex", uut.dp.ram_module_input_array.memory1);
							$readmemh("data8_yeni.hex", uut.dp.ram_module_input_array.memory2);
							$readmemh("data8_yeni.hex", uut.dp.ram_module_input_array.memory3);
							$readmemh("data8_yeni.hex", uut.dp.ram_module_input_array.memory4);
							$readmemh("data8_yeni.hex", uut.dp.ram_module_input_array.memory5);
						end else begin
							$readmemh("data8.hex", uut.dp.input_array.mem_array);
							$readmemh("data8.hex", uut.dp.ram_module_input_array.memory0);
							$readmemh("data8.hex", uut.dp.ram_module_input_array.memory1);
							$readmemh("data8.hex", uut.dp.ram_module_input_array.memory2);
							$readmemh("data8.hex", uut.dp.ram_module_input_array.memory3);
							$readmemh("data8.hex", uut.dp.ram_module_input_array.memory4);
							$readmemh("data8.hex", uut.dp.ram_module_input_array.memory5);
						end
					end
            9: begin
						if (yeni) begin
							$readmemh("data9_yeni.hex", uut.dp.input_array.mem_array);
							$readmemh("data9_yeni.hex", uut.dp.ram_module_input_array.memory0);
							$readmemh("data9_yeni.hex", uut.dp.ram_module_input_array.memory1);
							$readmemh("data9_yeni.hex", uut.dp.ram_module_input_array.memory2);
							$readmemh("data9_yeni.hex", uut.dp.ram_module_input_array.memory3);
							$readmemh("data9_yeni.hex", uut.dp.ram_module_input_array.memory4);
							$readmemh("data9_yeni.hex", uut.dp.ram_module_input_array.memory5);
						end else begin
							$readmemh("data9.hex", uut.dp.input_array.mem_array);
							$readmemh("data9.hex", uut.dp.ram_module_input_array.memory0);
							$readmemh("data9.hex", uut.dp.ram_module_input_array.memory1);
							$readmemh("data9.hex", uut.dp.ram_module_input_array.memory2);
							$readmemh("data9.hex", uut.dp.ram_module_input_array.memory3);
							$readmemh("data9.hex", uut.dp.ram_module_input_array.memory4);
							$readmemh("data9.hex", uut.dp.ram_module_input_array.memory5);
						end
					end
            10:begin 
					$readmemh("data10.hex", uut.dp.input_array.mem_array);
					$readmemh("data10.hex", uut.dp.ram_module_input_array.memory0);
					$readmemh("data10.hex", uut.dp.ram_module_input_array.memory1);
					$readmemh("data10.hex", uut.dp.ram_module_input_array.memory2);
					$readmemh("data10.hex", uut.dp.ram_module_input_array.memory3);
					$readmemh("data10.hex", uut.dp.ram_module_input_array.memory4);
					$readmemh("data10.hex", uut.dp.ram_module_input_array.memory5);
					end
            11:begin
					$readmemh("data11.hex", uut.dp.input_array.mem_array);
					$readmemh("data11.hex", uut.dp.ram_module_input_array.memory0);
					$readmemh("data11.hex", uut.dp.ram_module_input_array.memory1);
					$readmemh("data11.hex", uut.dp.ram_module_input_array.memory2);
					$readmemh("data11.hex", uut.dp.ram_module_input_array.memory3);
					$readmemh("data11.hex", uut.dp.ram_module_input_array.memory4);
					$readmemh("data11.hex", uut.dp.ram_module_input_array.memory5);
					end
            //12: $readmemh("data12.hex", uut.dp.input_array.mem_array);
            default: $display("Invalid ROWS value: %d", uut.dp.ROWS);
        endcase
		  
		 /*if (uut.dp.ROWS == 3)
			  file_id = $fopen("output_3.txt", "w");
		 else if (uut.dp.ROWS == 4)
			  file_id = $fopen("output_4.txt", "w");
		 else if (uut.dp.ROWS == 5)
			  file_id = $fopen("output_5.txt", "w");
		 else if (uut.dp.ROWS == 6)
			  file_id = $fopen("output_6.txt", "w");
		 else if (uut.dp.ROWS == 7)
			  file_id = $fopen("output_7.txt", "w");
		 else if (uut.dp.ROWS == 8)
			  file_id = $fopen("output_8.txt", "w");
		 else if (uut.dp.ROWS == 9)
			  file_id = $fopen("output_9.txt", "w");
		 else if (uut.dp.ROWS == 10)
			  file_id = $fopen("output_10.txt", "w");
		 else if (uut.dp.ROWS == 11)
			  file_id = $fopen("output_11.txt", "w");
		 else if (uut.dp.ROWS == 12)
			  file_id = $fopen("output_12.txt", "w");
		 else
			  file_id = $fopen("output_default.txt", "w");
		 */
		  
		  //file_id = $fopen("output.txt", "w");

		  
		  go_i = 0;
		  reset = 1;
		  
		  #20;
		  
		  go_i = 1;
		  reset = 0;
		  
		  #20;
		  
		  go_i = 0;
			  
			  //$display("clock %d", clk);
			
			
		  #20;
		  uut.dp.input_array_test_addr = 9'b0;
		  uut.cu.input_array_address_b_sel = 2'b10;
        #20;
  
		  /*for (i = 0; i < uut.dp.each_cone_size; i = i + 1) begin
			  uut.cu.input_array_address_b_sel = 2'b10;
			  signed_var = uut.dp.input_array_q_b;
		     $display("input_array[%0d] = %0d\n", i, signed_var);
			  $fwrite(file_id, "input_array[%0d] = %0d\n", i, signed_var);
			  uut.dp.input_array_test_addr = uut.dp.input_array_test_addr + 1;
			  #20;
		  end*/
		
        if (done) begin
            $display("Test passed: done signal asserted.");
				$fclose(file_id);
				$finish;
        end else begin
            $display("Test failed: done signal not asserted.");
        end
		
        //$stop;
    end
      
endmodule
