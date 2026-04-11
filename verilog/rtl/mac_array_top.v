// SPDX-FileCopyrightText: 2026 Nazal
// SPDX-License-Identifier: Apache-2.0

module MAC_array #(
    parameter NUM_MACS = 4,
    parameter WIDTH = 8,
    parameter ACC_WIDTH = 32
)(
    input clk,
    input reset,
    input enable,
    input [WIDTH-1:0] weight [0:NUM_MACS-1],
    input [WIDTH-1:0] activation [0:NUM_MACS-1],
    output [ACC_WIDTH-1:0] acc [0:NUM_MACS-1]
);
    genvar i;
    generate
        for(i = 0; i < NUM_MACS; i = i + 1) begin : mac_array
            MAC u(
                .clk(clk),
                .reset(reset),
                .enable(enable),
                .weight(weight[i]),
                .activation(activation[i]),
                .accumulator(acc[i])
            );
        end
    endgenerate
endmodule
