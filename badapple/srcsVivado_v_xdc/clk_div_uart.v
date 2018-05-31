`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/27 16:55:43
// Design Name: 
// Module Name: clk_div
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


module clk_div_1M(
	clk, // 输入时钟
	clk_out // 输出时钟
    );
	input clk;
	output reg clk_out=0;

	localparam Baud_Rate = 115200; // 波特�?
	localparam div_num = 'd100_000_000 / Baud_Rate / 2; // 分频�?

	reg[15:0] num;

	always@(posedge clk)  begin
		if(num==div_num) begin
			num <= 1;
			clk_out <= ~clk_out;
		end
		else begin
			num <= num + 1;
		end
	end
endmodule
