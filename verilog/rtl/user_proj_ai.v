// SPDX-FileCopyrightText: 2026 Nazal
// SPDX-License-Identifier: Apache-2.0

module user_proj_ai #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,
    input  [BITS-1:0] io_in,
    output [BITS-1:0] io_out,
    output [BITS-1:0] io_oeb,
    output [2:0] irq
);
    reg [7:0] weight [0:3];
    reg [7:0] activation [0:3];
    reg start;
    wire done;
    wire [31:0] acc [0:3];
    
    wire valid;
    reg wbs_ack_o_reg;
    reg [31:0] wbs_dat_o_reg;
    
    assign valid = wbs_cyc_i && wbs_stb_i;
    assign wbs_ack_o = wbs_ack_o_reg;
    assign wbs_dat_o = wbs_dat_o_reg;
    assign irq = {2'b00, done};
    assign io_out = 32'b0;
    assign io_oeb = 32'b1;
    assign la_data_out = {acc[3][31:0]};

    always @(posedge wb_clk_i) begin
        if(wb_rst_i) begin
            weight[0] <= 0; weight[1] <= 0;
            weight[2] <= 0; weight[3] <= 0;
            activation[0] <= 0; activation[1] <= 0;
            activation[2] <= 0; activation[3] <= 0;
            start <= 0;
            wbs_ack_o_reg <= 0;
            wbs_dat_o_reg <= 0;
        end
        else begin
            start <= 0;
            wbs_ack_o_reg <= 0;
            
            if(valid && !wbs_ack_o_reg) begin
                wbs_ack_o_reg <= 1;
                
                if(wbs_we_i) begin
                    case(wbs_adr_i)
                        32'h30000000: begin
                            weight[0] <= wbs_dat_i[7:0];
                            weight[1] <= wbs_dat_i[15:8];
                            weight[2] <= wbs_dat_i[23:16];
                            weight[3] <= wbs_dat_i[31:24];
                        end
                        32'h30000004: begin
                            activation[0] <= wbs_dat_i[7:0];
                            activation[1] <= wbs_dat_i[15:8];
                            activation[2] <= wbs_dat_i[23:16];
                            activation[3] <= wbs_dat_i[31:24];
                        end
                        32'h30000008: begin
                            start <= wbs_dat_i[0];
                        end
                    endcase
                end
                else begin
                    case(wbs_adr_i)
                        32'h3000000C: wbs_dat_o_reg <= acc[0];
                        32'h30000010: wbs_dat_o_reg <= acc[1];
                        32'h30000014: wbs_dat_o_reg <= acc[2];
                        32'h30000018: wbs_dat_o_reg <= acc[3];
                        32'h3000001C: wbs_dat_o_reg <= {31'b0, done};
                    endcase
                end
            end
        end
    end

    ai_accelerator #(
        .NUM_CYCLES(10),
        .NUM_MACS(4),
        .WIDTH(8),
        .ACC_WIDTH(32)
    ) ai_acc (
        .clk(wb_clk_i),
        .reset(wb_rst_i),
        .start(start),
        .weight(weight),
        .activation(activation),
        .acc(acc),
        .done(done)
    );

endmodule
