module dual_port_ram #(
    parameter DATA_WIDTH = 64,  // Width of the data
    parameter ADDR_WIDTH = 9    // Address width (512 words => 9-bit address)
)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] address_a,
    input wire [ADDR_WIDTH-1:0] address_b,
    input wire [DATA_WIDTH-1:0] data_a,
    input wire [DATA_WIDTH-1:0] data_b,
    input wire wren_a,
    input wire wren_b,
    output reg [DATA_WIDTH-1:0] q_a,
    output reg [DATA_WIDTH-1:0] q_b,
	 
	 input [3:0] ROWS
);

    // Define the memory array
    reg [DATA_WIDTH-1:0] mem_array [0:(2**ADDR_WIDTH)-1];
	 
	 initial begin
		$readmemh("data11_yeni.hex", mem_array);
	 end

    // Port A operations
    always @(posedge clk) begin
        if (wren_a) begin
            mem_array[address_a] <= data_a;  // Write data to port A
        end
        q_a <= mem_array[address_a];  // Read data from port A
    end

    // Port B operations
    always @(posedge clk) begin
        if (wren_b) begin
            mem_array[address_b] <= data_b;  // Write data to port B
        end
        q_b <= mem_array[address_b];  // Read data from port B
    end

endmodule
