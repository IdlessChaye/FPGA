`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/16 23:15:06
// Design Name: 
// Module Name: stop_watch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stop_watch (
        input clk,
        input go,clr,
        output[3:0] d7,d6,d5,d4,d3,d2,d1,d0
    );
    
    localparam COUNT_VALUE = 100_000_000;
    reg[26:0] ms_reg;
    reg[3:0] d7_reg,d6_reg,d5_reg,d4_reg,d3_reg,d2_reg,d1_reg,d0_reg;
    wire ms_tick;
    reg[3:0] d7_next,d6_next,d5_next,d4_next,d3_next,d2_next,d1_next,d0_next;
    
    always @ (posedge clk)
        if(clr == 0) begin
            ms_reg <= 27'b0;
            d0_reg <= 4'b0;
            d1_reg <= 4'b0;
            d2_reg <= 4'b0;
            d3_reg <= 4'b0;
            d4_reg <= 4'b0;
            d5_reg <= 4'b0;
            d6_reg <= 4'b0;
            d7_reg <= 4'b0;            
        end else if(go == 1) begin
            if(ms_reg < COUNT_VALUE - 1)
                ms_reg <= ms_reg + 1;
            else   
                ms_reg <= 0;
            d0_reg <= d0_next;
            d1_reg <= d1_next;
            d2_reg <= d2_next;
            d3_reg <= d3_next;
            d4_reg <= d4_next;
            d5_reg <= d5_next;
            d6_reg <= d6_next;
            d7_reg <= d7_next;
        end
    
    always @ (ms_tick) begin
        if(clr == 0) begin
            d0_next = 4'b0;
            d1_next = 4'b0;
            d2_next = 4'b0;
            d3_next = 4'b0;
            d4_next = 4'b0;
            d5_next = 4'b0;
            d6_next = 4'b0;
            d7_next = 4'b0;
        end else if(ms_tick) begin
            if(d0_next < 9)
                d0_next = d0_next + 1;
            else begin
                d0_next = 0;
                if(d1_next < 9)
                    d1_next = d1_next + 1;
                else begin
                    d1_next = 0;
                    if(d2_next < 9)
                        d2_next = d2_next + 1;
                    else begin
                        d2_next = 0;
                        if(d3_next < 5)
                            d3_next = d3_next + 1;
                        else begin
                            d3_next = 0;
                            if(d4_next < 9)
                                d4_next = d4_next + 1;
                            else begin
                                d4_next = 0;
                                if(d5_next < 5)
                                    d5_next = d5_next + 1;
                                else begin
                                    d5_next = 0;
                                    if(d6_next < 9)
                                        d6_next = d6_next + 1;
                                    else begin
                                        d6_next = 0;
                                        if(d7_next < 9)
                                            d7_next = d7_next + 1;
                                        else begin
                                            d7_next = 0;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end 
        end
    end
    
    assign ms_tick = ms_reg == COUNT_VALUE - 1 ? 1'b1 : 1'b0;
    assign d0 = d0_reg;
    assign d1 = d1_reg;
    assign d2 = d2_reg;
    assign d3 = d3_reg;
    assign d4 = d4_reg;
    assign d5 = d5_reg;
    assign d6 = d6_reg;
    assign d7 = d7_reg;

endmodule

