// SPDX-FileCopyrightText: 2026 Nazal
// SPDX-License-Identifier: Apache-2.0

module inference_controller #(
    parameter NUM_CYCLES = 10
)(
    input clk,
    input reset,
    input start,
    output reg enable,
    output reg done
);
    parameter IDLE    = 2'b00;
    parameter LOAD    = 2'b01;
    parameter COMPUTE = 2'b10;
    parameter OUTPUT  = 2'b11;
    
    reg [1:0] state;
    reg [7:0] counter;
    
    always @(posedge clk) begin
        if(reset) begin
            state <= IDLE;
            counter <= 0;
        end
        else
            case(state)
                IDLE:    if(start) state <= LOAD;
                LOAD:              state <= COMPUTE;
                COMPUTE: begin
                    counter <= counter + 1;
                    if(counter == NUM_CYCLES-1) begin
                        state <= OUTPUT;
                        counter <= 0;
                    end
                end
                OUTPUT:            state <= IDLE;
                default:           state <= IDLE;
            endcase
    end
    
    always @(*) begin
        case(state)
            IDLE:    begin enable=0; done=0; end
            LOAD:    begin enable=0; done=0; end
            COMPUTE: begin enable=1; done=0; end
            OUTPUT:  begin enable=0; done=1; end
            default: begin enable=0; done=0; end
        endcase
    end
endmodule
