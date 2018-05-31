`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/28 19:46:29
// Design Name: 
// Module Name: sram_read
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


module sram_read_unit(
	clk,
	sram_read_start,
	write_done,
	data_after_chuli,
	sram_read_loadbytedone,
	sram_read_selec,
	sram_read_read,
	sram_read_write,
	data_from_sram,
	sram_read_addr,
	sram_read_finish,
	sram_read_count,
	read_pause,
	addr_reset
    );

	input clk;
	input sram_read_start;

	input write_done;
	output reg[7:0]data_after_chuli;
	output sram_read_loadbytedone;

	output sram_read_selec;
	output sram_read_read;
	output sram_read_write;
	input[15:0]data_from_sram;
	output[18:0] sram_read_addr;

	output sram_read_finish;
	output[19:0]sram_read_count;
	output read_pause;
	input addr_reset;

	reg[18:0] addr_tmp = 0;
	assign sram_read_addr = addr_tmp;
	assign read_pause = ((addr_tmp % 512) == 0) ? 1'b1 : 1'b0;

	wire sram_read_done;
	always @ (posedge sram_read_done)
		if(addr_reset)
			addr_tmp <= 0;
		else
			addr_tmp <= addr_tmp + 1;

	parameter M = 200000; //must oushu , same with sram_write_unit
	reg[19:0] count = 0;
	assign sram_read_count = count;
	always@(posedge write_done)
		if(addr_reset)
			count <= 0;
		else if(sram_read_start)
			count <= count + 1;

	localparam st_IDLE1 = 0,
			   st_D1 = 1,
			   st_IDLE2 = 2,
			   st_D2 = 3,
			   st_READ_DOWN1 = 4,
			   st_READ_DOWN2 = 5,
			   st_FINISH = 6;
	reg[3:0] cur_st=0,nxt_st=0;
	always @ (posedge clk)
		cur_st <= nxt_st;
	always @ * begin
		nxt_st = cur_st;
		case(cur_st) 
			st_IDLE1:if(sram_read_start)if(write_done)nxt_st=st_READ_DOWN1;
			st_READ_DOWN1:if(count>=M)nxt_st=st_FINISH;else nxt_st=st_IDLE2;
			st_IDLE2:if(sram_read_start)if(write_done)nxt_st=st_READ_DOWN2;
			st_READ_DOWN2:if(count>=M)nxt_st=st_FINISH;else nxt_st=st_IDLE1;
			st_FINISH:if(count<M)nxt_st=st_IDLE1; else nxt_st=st_FINISH;
			default:nxt_st=st_IDLE1;
		endcase
	end

	always @ (posedge clk) 
		if(cur_st==st_IDLE1)
			data_after_chuli <= data_from_sram[15:8];
		else if(cur_st==st_IDLE2)
			data_after_chuli <= data_from_sram[7:0];

	assign sram_read_done = cur_st==st_READ_DOWN1 ? 1'b1 : 1'b0;

	assign sram_read_loadbytedone = cur_st==st_READ_DOWN1 || cur_st==st_READ_DOWN2 ? 1'b1 : 1'b0;

	assign sram_read_read = cur_st==st_IDLE1 ? 1'b1 : 1'b0;
	assign sram_read_write = 0;
	assign sram_read_selec = cur_st==st_IDLE1 ? 1'b1 : 1'b0;

	assign sram_read_finish = cur_st==st_FINISH ? 1'b1 : 1'b0;
endmodule
