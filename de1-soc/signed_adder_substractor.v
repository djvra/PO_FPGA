// Quartus Prime Verilog Template
// Signed adder/subtractor

module signed_adder_subtractor
#(parameter WIDTH=64)
(
	input signed [WIDTH-1:0] dataa,
	input signed [WIDTH-1:0] datab,
	input add_sub,	  // if this is 1, add; else subtract
	output reg [WIDTH-1:0] result
);
	
	always @ (*)
	begin
		if (add_sub)
			result <= dataa + datab;
		else
			result <= dataa - datab;
	end

endmodule