// SPDX-FileCopyrightText: 2026 Nazal
// SPDX-License-Identifier: Apache-2.0

module MAC #(
    parameter WIDTH = 8,
    parameter ACC_WIDTH = 32
)(
    input clk,
    input reset,
    input enable,
    input [WIDTH-1:0] weight,
    input [WIDTH-1:0] activation,
    output reg [ACC_WIDTH-1:0] accumulator
);
    wire [2*WIDTH-1:0] mult_result;
    assign mult_result = weight * activation;
    
    always @(posedge clk) begin
        if(reset)
            accumulator <= 0;
        else if(enable)
            accumulator <= accumulator + mult_result;
    end
endmodule
