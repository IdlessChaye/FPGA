`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/27 16:39:28
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
	clk,
	rxd,
	receive_ack,
	data_i,
	data_finish
	);

	input clk; // 时钟信号
	input rxd; // 当前收到的一比特数据
	output receive_ack; // 收完�?字节数据为高
	output reg[7:0] data_i=0; // 收完的一字节数据
	output data_finish;

	localparam IDLE = 0,
			   RECEIVE = 1,
			   RECEIVE_END = 2;

	reg[3:0] cur_st=IDLE,nxt_st=IDLE;
	reg[4:0] count=0;
	reg[7:0] data_i_tmp=0;

	always @(posedge clk) 
		cur_st <= nxt_st;

	always @ * begin
		nxt_st = cur_st;
		case(cur_st)
			IDLE: if(!rxd) nxt_st = RECEIVE;
			RECEIVE: if(count==7) nxt_st = RECEIVE_END;
			RECEIVE_END:if(rxd) nxt_st = IDLE;
			default: nxt_st = IDLE;
		endcase
	end

	always @(posedge clk) begin
		if(cur_st == RECEIVE)
			count <= count + 1;
		else if(cur_st==IDLE | cur_st==RECEIVE_END)
			count <= 0;
	end

	always @(posedge clk) begin
		if(cur_st==RECEIVE) begin
			data_i_tmp[6:0] <= data_i_tmp[7:1];
			data_i_tmp[7] <= rxd;
		end
	end

	always @ (posedge receive_ack)
		data_i <= data_i_tmp;

	assign receive_ack = cur_st == RECEIVE_END ? 1'b1 : 1'b0;
	// never over
	assign data_finish = 0;
endmodule
