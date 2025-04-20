module parallel_divider(
    input clk,
	 input clken,
    input reset,
	 input [39:0] den, 
    input [39:0] num0, 
    input [39:0] num1, 
    input [39:0] num2,
    input [39:0] num3,
    input [39:0] num4,
    input [39:0] num5,
    input [39:0] num6,
    input [39:0] num7,
    input [39:0] num8,
    input [39:0] num9,
    input [39:0] num10,
    output [39:0] quot0,
    output [39:0] quot1,
    output [39:0] quot2,
    output [39:0] quot3,
    output [39:0] quot4,
    output [39:0] quot5,
    output [39:0] quot6,
    output [39:0] quot7,
    output [39:0] quot8,
    output [39:0] quot9,
    output [39:0] quot10,
	 output [39:0] remain0,
	 output [39:0] remain1,
	 output [39:0] remain2,
	 output [39:0] remain3,
	 output [39:0] remain4,
	 output [39:0] remain5, 
	 output [39:0] remain6, 
	 output [39:0] remain7,
	 output [39:0] remain8,
	 output [39:0] remain9,
	 output [39:0] remain10
);

	integer_divider divider0(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num0),
		.quotient(quot0),
		.remain(remain0)
	);
	
	integer_divider divider1(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num1),
		.quotient(quot1),
		.remain(remain1)
	);

	integer_divider divider2(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num2),
		.quotient(quot2),
		.remain(remain2)
	);

	integer_divider divider3(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num3),
		.quotient(quot3),
		.remain(remain3)
	);
	
	integer_divider divider4(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num4),
		.quotient(quot4),
		.remain(remain4)
	);
	
	integer_divider divider5(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num5),
		.quotient(quot5),
		.remain(remain5)
	);
	
	integer_divider divider6(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num6),
		.quotient(quot6),
		.remain(remain6)
	);
	
	integer_divider divider7(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num7),
		.quotient(quot7),
		.remain(remain7)
	);
	
	integer_divider divider8(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num8),
		.quotient(quot8),
		.remain(remain8)
	);
	
	integer_divider divider9(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num9),
		.quotient(quot9),
		.remain(remain9)
	);
	
	integer_divider divider10(
		.clken(clken),
		.clock(clk),
		.denom(den),
		.numer(num10),
		.quotient(quot10),
		.remain(remain10)
	);

endmodule
