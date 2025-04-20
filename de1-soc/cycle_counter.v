module cycle_counter (
    input wire clk,
    input wire reset,
    input wire go_i,        // Start counting when high
    input wire done,        // Stop counting when high
    output reg [63:0] cycle_count, // Cycle count output
    output reg counting
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cycle_count <= 64'd0;
            counting <= 1'b0;
        end else begin
            if (go_i && !counting) begin
                counting <= 1'b1;   // Start counting
                cycle_count <= 64'd0;
            end else if (counting) begin
                if (done) begin
                    counting <= 1'b0;  // Stop counting
                end else begin
                    cycle_count <= cycle_count + 1'b1;  // Increment counter
                end
            end
        end
    end

endmodule
