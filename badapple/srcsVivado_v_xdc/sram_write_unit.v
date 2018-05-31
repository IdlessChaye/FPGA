`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/28 18:49:02
// Design Name: 
// Module Name: sram_write
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


module sram_write_unit(
	clk,
	sram_write_start,
	data_i,
	receive_ack,
	sram_write_selec,
	sram_write_write,
	sram_write_read,
	sram_write_data,
	sram_write_addr,
	sram_write_finish,
	sram_write_count
    );
	
	input clk; // å’Œuartä¸?ä¸ªclk
	input sram_write_start;
	input[7:0] data_i;
	input receive_ack;

	output sram_write_selec;
	output sram_write_write;
	output sram_write_read;
	output [15:0]sram_write_data;
	output [18:0]sram_write_addr;

	output sram_write_finish;
	output[19:0]sram_write_count;

	reg[18:0] addr_tmp=0;
	reg[15:0] data_tmp=0;
	assign sram_write_data = data_tmp;
	assign sram_write_addr = addr_tmp;

	wire sram_write_done;
	always @ (posedge sram_write_done)
		addr_tmp <= addr_tmp + 1;

	parameter N = 200000; //must oushu , same with sram_write_unit
	reg[19:0] count = 0; // Bytes data already got
	assign sram_write_count = count;
	always @ (posedge receive_ack)
		if(sram_write_start)
			count <= count + 1;

	localparam st_IDLE1 = 0,
			   st_D1 = 1,
			   st_D2 = 2,
			   st_SEND = 3,
			   st_FINISH = 4,
			   st_IDLE2 = 5,
			   st_WRITE_DONE=6;
	reg[3:0] cur_st=0,nxt_st=0;
	always@(posedge clk)
		cur_st <= nxt_st;
	always @ * begin
		nxt_st = cur_st;
		case(cur_st) 
			st_IDLE1:if(sram_write_start)if(receive_ack)nxt_st=st_D1;
			st_D1:nxt_st=st_IDLE2;
			st_IDLE2:if(sram_write_start)if(receive_ack)nxt_st=st_D2;
			st_D2:nxt_st=st_SEND;
			st_SEND:if(count>=N)nxt_st=st_FINISH;else nxt_st=st_WRITE_DONE;
			st_WRITE_DONE:nxt_st=st_IDLE1;
			st_FINISH:nxt_st=st_FINISH;
			default:nxt_st=st_FINISH;
		endcase
	end

	always @ (posedge clk)
		if(cur_st == st_D1)
			data_tmp[15:8] <= data_i;
		else if(cur_st == st_D2)
			data_tmp[7:0] <= data_i;

	assign sram_write_done = cur_st == st_WRITE_DONE ? 1'b1 : 1'b0;

	assign sram_write_write = cur_st == st_SEND ? 1'b1 : 1'b0;
	assign sram_write_read = 0;
	assign sram_write_selec = cur_st == st_SEND ? 1'b1 : 1'b0;

	assign sram_write_finish = cur_st == st_FINISH ? 1'b1 : 1'b0;
endmodule
