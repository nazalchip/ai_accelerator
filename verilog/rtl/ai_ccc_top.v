// SPDX-FileCopyrightText: 2026 Nazal
// SPDX-License-Identifier: Apache-2.0

module ai_accelerator #(
    parameter NUM_CYCLES = 10,
    parameter NUM_MACS = 4,
    parameter WIDTH = 8,
    parameter ACC_WIDTH = 32
)(
    input clk,
    input reset,
    input start,
    input [WIDTH-1:0] weight [0:NUM_MACS-1],
    input [WIDTH-1:0] activation [0:NUM_MACS-1],
    output [ACC_WIDTH-1:0] acc [0:NUM_MACS-1],
    output done
);
    wire enable;
    
    inference_controller #(.NUM_CYCLES(NUM_CYCLES)) ctrl(
        .clk(clk),
        .reset(reset),
        .start(start),
        .enable(enable),
        .done(done)
    );
    
    MAC_array #(
        .NUM_MACS(NUM_MACS),
        .WIDTH(WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) mac(
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .weight(weight),
        .activation(activation),
        .acc(acc)
    );
endmodule
