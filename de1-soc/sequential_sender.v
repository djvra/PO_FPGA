module sequential_sender (
    input wire clk,             // Clock input
    input wire reset,           // Reset input
    input wire load,            // Load signal
    input wire [5:0] ROWS,
    input wire [31:0] data_in_0, // Input 32-bit data 0
    input wire [31:0] data_in_1, // Input 32-bit data 1
    input wire [31:0] data_in_2, // Input 32-bit data 2
    input wire valid_pulse,      // Valid signal from HPS
	 input wire generation_done,
	 output reg sending_done,
    output reg [31:0] number_out, // 32-bit output
    output reg valid,            // Valid output signal
    output reg cu_dp_clock_enable, // Clock enable signal
	 output reg [7:0] debug_state
);

    reg [31:0] numbers [2:0];
    reg [4:0] state, saved_state;
    reg [5:0] cycle_counter, unsigned_6bit_comp_datab;
	 reg valid_pulse_d;
	 wire rows_lt;
	 wire [5:0] incrementer_res;

    localparam cycles_wait = 6'd30;

    localparam IDLE  = 5'd0,
               SEND1 = 5'd1, WAIT1 = 5'd2,
               SEND2 = 5'd3, WAIT2 = 5'd4,
               SEND3 = 5'd5, WAIT3 = 5'd6,
               STOP  = 5'd7;

	 unsigned_6bit_comparator unsigned_6bit_comp (
		 .dataa(ROWS),
		 .datab(unsigned_6bit_comp_datab),
		 .alb(rows_lt)
	 );
	 
	 assign incrementer_res = cycle_counter + 6'd1;
	 
	 always @(posedge clk) begin
		 valid_pulse_d <= valid_pulse;
	 end
	 wire valid_pulse_edge = valid_pulse & ~valid_pulse_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            saved_state <= IDLE;
				debug_state <= 8'b0;
            cycle_counter <= 6'd0;
            number_out <= 32'd0;
            valid <= 1'b1;
            cu_dp_clock_enable <= 1'b1;
            numbers[0] <= 32'd0;
            numbers[1] <= 32'd0;
            numbers[2] <= 32'd0;
				sending_done <= 1'b0;
        end else begin
			
				debug_state <= state;
		  
            case (state)
                IDLE: begin
                    number_out <= 32'd0;
						  valid <= 1'b1;
                    cu_dp_clock_enable <= 1'b1; // Enable word generation
                    if (load & ~generation_done) begin
                        numbers[0] <= data_in_0;
                        numbers[1] <= data_in_1;
                        numbers[2] <= data_in_2;
                        state <= SEND1;
                    end else if (~load & generation_done) begin
								number_out <= 32'hFFFFFFFF;
								if (valid_pulse_edge) begin
									sending_done <= 1'b1;
								end
						  end
                end

                SEND1: begin
                    number_out <= numbers[0];
                    state <= WAIT1;
                    cycle_counter <= 6'd0;
						  unsigned_6bit_comp_datab <= 6'd5;
                end

                WAIT1: begin
                    if (valid_pulse_edge) begin
                        //state <= (ROWS < 6'd5) ? IDLE : SEND2;
                        state <= (rows_lt) ? IDLE : SEND2;
                        cycle_counter <= 6'd0;
                    end else if (cycle_counter < cycles_wait) begin
                        //cycle_counter <= cycle_counter + 6'd1;
								cycle_counter <= incrementer_res;
                    end else begin
                        //saved_state <= (ROWS < 6'd5) ? IDLE : SEND2;
                        saved_state <= (rows_lt) ? IDLE : SEND2;
                        state <= STOP;
                    end
                end

                SEND2: begin
                    number_out <= numbers[1];
                    state <= WAIT2;
                    cycle_counter <= 6'd0;
						  unsigned_6bit_comp_datab <= 6'd9;
                end

                WAIT2: begin
                    if (valid_pulse_edge) begin
                        //state <= (ROWS < 6'd9) ? IDLE : SEND3;
                        state <= (rows_lt) ? IDLE : SEND3;
                        cycle_counter <= 6'd0;
                    end else if (cycle_counter < cycles_wait) begin
                        //cycle_counter <= cycle_counter + 6'd1;
								cycle_counter <= incrementer_res;
                    end else begin
                        //saved_state <= (ROWS < 6'd9) ? IDLE : SEND3;
                        saved_state <= (rows_lt) ? IDLE : SEND3;
                        state <= STOP;
                    end
                end

                SEND3: begin
                    number_out <= numbers[2];
                    state <= WAIT3;
                    cycle_counter <= 6'd0;
                end

                WAIT3: begin
                    if (valid_pulse_edge) begin
                        state <= IDLE;
                        cycle_counter <= 6'd0; // Reset cycle counter
                    end else if (cycle_counter < cycles_wait) begin
                        //cycle_counter <= cycle_counter + 6'd1;
								cycle_counter <= incrementer_res;
                    end else begin
                        saved_state <= IDLE;
                        state <= STOP;
                    end
                end

                STOP: begin
                    cu_dp_clock_enable <= 1'b0; // Stop word generation
                    if (valid_pulse_edge) begin
                        state <= saved_state; // Resume from saved state
                        cu_dp_clock_enable <= 1'b1; // Re-enable word generation
                        cycle_counter <= 6'd0; // Reset cycle counter
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
