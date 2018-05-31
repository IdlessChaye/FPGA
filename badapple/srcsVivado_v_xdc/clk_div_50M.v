`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/29 18:27:38
// Design Name: 
// Module Name: clk_div_50M
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


module clk_div_50M (
	clk, // 杈撳叆鏃堕挓
	clk_out // 杈撳嚭鏃堕挓
    );
	input clk;
	output reg clk_out=0;
	
	always@(posedge clk)  begin
		clk_out <= ~clk_out;
	end
endmodule
