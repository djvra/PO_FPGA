// dumps last 1000 points so that we can see it on the In System Memory Content Editor

module sequential_loader #(
    parameter ROWS = 12
)(
    input wire clk,
    input wire reset,
    input wire en, 
	 input wire [9:0] point_count,
    input wire [7:0] data_in0,
    input wire [7:0] data_in1,
    input wire [7:0] data_in2,
    input wire [7:0] data_in3,
    input wire [7:0] data_in4,
    input wire [7:0] data_in5,
    input wire [7:0] data_in6,
    input wire [7:0] data_in7,
    input wire [7:0] data_in8,
    input wire [7:0] data_in9,
    input wire [7:0] data_in10,
    output reg done                    
);

    reg [13:0] bram_index;
	 reg [7:0] data;
	 reg [7:0] quotients [0:10];
	 reg wren;
	 reg continue_;
	 integer i = 0;
	 
	 reg [1:0] state;
    localparam IDLE = 0, WRITE = 1, INCREMENT = 2, OPER_DONE = 3;
	 
	 single_port_ram result_point_ISMCE( 
		.address(bram_index),
		.clock(clk),
		.data(data),
		.wren(wren)
		//.q(result_point_ISMCE_q)
	);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 1'b0;
				wren <= 1'b0;
				continue_ <= 0;
				i <= 32'b0;
				state <= IDLE;
        end else begin
				case (state)
				
					IDLE: begin
						if (en) begin
							bram_index <= point_count * ROWS[13:0];
							quotients[0] <= data_in0;
							quotients[1] <= data_in1;
							quotients[2] <= data_in2;
							quotients[3] <= data_in3;
							quotients[4] <= data_in4;
							quotients[5] <= data_in5;
							quotients[6] <= data_in6;
							quotients[7] <= data_in7;
							quotients[8] <= data_in8;
							quotients[9] <= data_in9;
							quotients[10] <= data_in10;
							done <= 1'b0;
							wren <= 1'b0;
							i <= 32'b0;
							continue_ <= 1'b1;
							state <= WRITE;
						end
					end
					
					WRITE: begin
						if (i < ROWS && continue_) begin
							wren <= 1'b1;
							data <= quotients[i];
							state <= INCREMENT;
						end else if (continue_) begin
							 wren <= 1'b0;
							 state <= OPER_DONE;
						end
					end
					
					INCREMENT: begin
									  if (continue_) begin
										  wren <= 1'b0;
										  bram_index <= bram_index + 1'b1;
										  i <= i + 1;
										  state <= WRITE;
									  end
								  end
					
					OPER_DONE: begin
							if (continue_) begin
								wren <= 1'b0;
								done <= 1'b1;
								continue_ <= 1'b0;
								i <= 32'b0;
								state <= IDLE;
							end
               end
                
               default: state <= IDLE;
					
				endcase
        end
    end

endmodule
