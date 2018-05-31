`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/27 17:18:36
// Design Name: 
// Module Name: badapple_top
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


module badapple_top(
    output sck, // spiÃ§Å¡â€žsckÃ¤Â¿Â¡Ã¥ÂÂ·
    //input mosi,
    output miso, // spiÃ§Å¡â€žmisoÃ¤Â¿Â¡Ã¥ÂÂ·
    output reg reset_oled, // Ã¯Â¼Å¸Ã¯Â¼Å¸Ã¯Â¼?
    input clk, // FPGAÃ¦ÂÂ¿Ã¥Â­ÂÃ¤Â¸Å Ã§â€Å¸Ã¦Ë�?�ÂÃ§Å¡�???100MHzÃ§Å¡â€žÃ¦�??”Â¶Ã©�??™Å¸Ã¤Â¿Â¡Ã¥�???
    output dc, // Ã©Â«ËœÃ¦â€¢Â°Ã¦ÂÂ®Ã¯Â¼Å�?�Ã¤Â½Å½Ã¥�??˜Â½Ã¤Â??
    output sck_reg, // spi_masterÃ¦Â¨Â¡Ã¥Ââ€�?�Ã§�??Å¸Ã¦Ë†ÂÃ§�???1MHzÃ§Å¡â€žÃ¦�??”Â¶Ã©�??™Å¸Ã¤Â¿Â¡Ã¥�???

    input rxd,
    output reg st_init,
	output reg st_clear,
	output reg st_wait,
	output reg st_write,
    output[3:0] en0,en1,
    output[7:0] sseg0,sseg1,

    inout wire [15:0] sram_data,
    output  [18:0] sram_addr,
    output         sram_oe_r,
    output         sram_ce_r,
    output         sram_we_r,
    output         sram_ub_r,
    output         sram_lb_r,

    input keepgoing,
    output showdelay,
    input addr_reset
    );
    reg [31:0]reset_count;
    reg reset_n;
    initial begin
        reset_count=0;
        reset_n=0;
    end

    always@(posedge clk)
        if(reset_count>=30000)
            reset_count<=30000;
        else reset_count<=reset_count+1;
    
    always@(posedge clk)
        if(reset_count==10) begin
            reset_oled<=1;
            reset_n<=1;
        end
        else if(reset_count==10000) begin
            reset_oled<=0;
            reset_n<=0;
        end
        else if(reset_count==30000) begin
 			reset_oled<=1;        	
            reset_n<=1;
        end
    
    reg spi_send; // spiÃ¥ÂÂ¯Ã¥Å Â¨Ã¤Â¿Â¡Ã¥ÂÂ·Ã¯Â¼Å’Ã¥ÂÂ¯Ã¤Â»Â¥Ã¤Â¸â�?�¬Ã§�??ºÂ´Ã¤Â¸ÂºÃ©Â«ËœÃ§â?ÂµÃ¥Â??
    reg [7:0]spi_data_out; // spiÃ¨Â¦ÂÃ¤Â¼Â Ã¨Â¾â€œÃ§Å¡�??žÃ¦â?¢Â°Ã¦ÂÂ?
    wire spi_send_done; // spiÃ¤Â¼Â Ã¥Â®Å’Ã¤Â�??Ã¤Â¸ÂªÃ¥Â­â€�?�Ã¨Å �??šÃ¤Â¸ÂºÃ©Â??
    reg dc_in; // spi_masterÃ§Å¡â€ždc_in
    wire reset=!reset_n; // Ã¤Â¸ÂºÃ¤Â»â‚¬Ã¤Â¹Ë�?�Ã¤Â¸ÂÃ¦ËœÂ¯reset_regÃ£â‚¬�??šÃ??â€š�????
    
    // Ã¤Â¸ÂÃ¤Â»â€¦Ã¤ÂºÂ§Ã§�??Å?1MHzÃ§Å¡â€žÃ¦�??”Â¶Ã©�??™Å¸Ã¯Â¼Å�?�Ã¨Â¿ËœÃ¥Â®Å¾Ã§Å½Â°spiÃ§Å¡â€žmisoÃ¨ÂµÂ·Ã¥Â§â€¹Ã¤Â¿Â¡Ã¥ÂÂ·Ã¤Â¸Âºspi_send
    spi_master spi_master 
    (
        .sck    (sck), // Ã©ÂÅ¾Ã¥Â·Â¥Ã¤Â½Å“Ã§Å¡â€žÃ¦â?”Â¶�???â„¢Ã¦ËœÂ¯Ã©Â«ËœÃ§�??ÂµÃ¥Â¹Â³Ã¯Â¼Å’Ã¥Â·Â¥Ã¤Â½Å�?�Ã¥�?? ÂÃ¥ÂË?1MHz
        .miso   (miso),
        .cs     (cs), // Ã§â€°�??¡Ã???
        .rst    (1),
        .spi_send   (spi_send), // Ã¥ÂÂ¯Ã¥Å Â¨Ã¤Â¿Â¡Ã¥ÂÂ·
        .spi_data_out   (spi_data_out), // Ã¥Â¾â€¦Ã¤Â¼Â Ã¦�??¢Â°Ã¦ÂÂ?
        .spi_send_done  (spi_send_done), // Ã¤Â¼Â Ã¨Â¾â€œÃ¥Â®Å�?�Ã¦Ë�?��??
        .clk    (clk), // 100MHz
        .dc_in  (dc_in), // 
        .dc_out (dc), // Ã¥Â½â€œcsÃ¤Â¸ÂºÃ¤Â½Å½Ã¦â€�?�Â¶Ã¤Â¸Âºdc_in,Ã¨Â¦ÂÃ¤Â¸ÂÃ§â€žÂ¶Ã¤Â¼Â Ã©â�?�¬ÂÃ¦Å�?�â€¡Ã¤Â??
        .sck_reg (sck_reg) // 1MHz clk Ã©Â©Â¬Ã¤Â¸ÂÃ¥ÂÅ“Ã¨Â¹â€žÃ¥Â??
    ); // Ã¦â‚¬Å½Ã¤Â¹Ë�?�Ã¥Â°�??˜Ã¤Âºâ? Ã¤Â¸ÂªmosiÃ¥â€¢Å �???â€š�???â€š�????
    
    wire spi_send_init;
    wire [7:0]spi_data_init;
    wire dc_init;
    wire init_done;
    
    oled_init oled_init
    (
        .send_done  (spi_send_done), // from spi_master
        .spi_send   (spi_send_init),
        .spi_data   (spi_data_init),
        .clk        (sck_reg), // from spi_master
        .init_done  (init_done),
        .dc         (dc_init), 
        .reset      (reset) // !reset_n
    );
    
    wire spi_send_write;
    wire [7:0]spi_data_write;
    wire dc_write;
    wire write_done;
    reg [7:0]write_data;
    reg [7:0]set_pos_x_reg=0,set_pos_y_reg=0;
    wire[7:0]set_pos_x,set_pos_y;
    reg write_start;

	assign set_pos_x = set_pos_x_reg;
    assign set_pos_y = set_pos_y_reg;
    
    oled_write_data oled_write_data(
        .send_done  (spi_send_done), // from spi_master
        .spi_send   (spi_send_write),
        .spi_data   (spi_data_write),
        .clk        (sck_reg), // from spi_master
        .dc         (dc_write),
        .write_start(write_start),
        .write_done (write_done),
        .write_data (write_data),
        .set_pos_x  (set_pos_x),
        .set_pos_y  (set_pos_y),
        .reset  (reset) // !reset_n
    );    
    
    wire spi_send_clear;
    wire [7:0]spi_data_clear;
    wire dc_clear;
    reg clear_start;
    wire clear_done;    

    oled_clear oled_clear
    (
        .send_done  (spi_send_done), // from spi_master
        .spi_send   (spi_send_clear),
        .spi_data   (spi_data_clear),
        .clk        (sck_reg), // from spi_master
        .dc         (dc_clear),
        .clear_start(clear_start),
        .clear_done (clear_done),
        .reset  (reset) // !reset_n
    );
    

    wire clk_out_uart;
    clk_div_uart clk_div_uart
    (
    	.clk(clk),
    	.clk_out(clk_out_uart)
    );

    wire receive_ack;
    wire data_finish;
    wire[7:0] data_i;
    uart_rx uart_rx
    (
    	.clk(clk_out_uart),
    	.rxd(rxd),
    	.receive_ack(receive_ack),
    	.data_i(data_i),
    	.data_finish(data_finish)
    );


    wire clk_out_50M;
    clk_div_50M clk_div_50M 
    (
        .clk(clk),
        .clk_out(clk_out_50M)
    );

    wire sram_selec;
    wire sram_write;
    wire sram_read;
    wire[15:0] data_wr_in;
    wire[15:0] data_wr_out;
    wire[18:0] addr_wr;
    sram_ctrl sram_ctrl(
        .clk(clk_out_50M),
        .rst_n(1),

        .selec(sram_selec),
        .write(sram_write),
        .read(sram_read),
        .data_wr_in(data_wr_in),
        .data_wr_out(data_wr_out),
        .addr_wr(addr_wr),

        .sram_data(sram_data),
        .sram_addr(sram_addr),
        .sram_oe_r(sram_oe_r),
        .sram_ce_r(sram_ce_r),
        .sram_we_r(sram_we_r),
        .sram_ub_r(sram_ub_r),
        .sram_lb_r(sram_lb_r)
    );


    wire sram_write_start;
    wire sram_write_read;
    wire sram_write_write;
    wire sram_write_selec;
    wire [15:0] write_data_wr;
    wire [18:0] write_addr_wr;
    wire sram_write_finish;
    wire[19:0] sram_write_count;
    sram_write_unit sram_write_unit(
        .clk(clk_out_uart),
        .sram_write_start(sram_write_start),

        .data_i(data_i),
        .receive_ack(receive_ack),

        .sram_write_selec(sram_write_selec),
        .sram_write_write(sram_write_write),
        .sram_write_read(sram_write_read),
        .sram_write_data(write_data_wr),
        .sram_write_addr(write_addr_wr),

        .sram_write_finish(sram_write_finish),
        .sram_write_count(sram_write_count)
    );


    wire sram_read_start;
    wire[7:0] data_after_chuli;
    wire sram_read_loadbytedone;
    wire sram_read_selec;
    wire sram_read_read;
    wire sram_read_write;
    wire [15:0] read_data_wr;
    wire [18:0] read_addr_wr;
    wire sram_read_finish;    
    wire [19:0] sram_read_count;
    wire read_pause;
    sram_read_unit sram_read_unit(
        .clk(sck_reg),
        .sram_read_start(sram_read_start),

        .write_done(write_done),
        .data_after_chuli(data_after_chuli),
        .sram_read_loadbytedone(sram_read_loadbytedone),

        .sram_read_selec(sram_read_selec),
        .sram_read_read(sram_read_read),
        .sram_read_write(sram_read_write),
        .data_from_sram(read_data_wr),
        .sram_read_addr(read_addr_wr),

        .sram_read_finish(sram_read_finish),
        .sram_read_count(sram_read_count),
        .read_pause(read_pause),
        .addr_reset(addr_reset)
    );
    
    assign showdelay = delay_signal;
    reg delay_signal=0;

    parameter zhenshu = 1100*7/5/2;
    parameter yimiaozhexiexia = 100_000_000;
    parameter duoshaoxiayizhen = yimiaozhexiexia / zhenshu;
    reg[26:0] zhencount = 0;
    always @ *
        if(zhencount>=duoshaoxiayizhen) begin
            delay_signal = 0;
        end
        else if(read_pause)
            delay_signal = 1;
    always @ (posedge clk)
        if(delay_signal && keepgoing)
            zhencount <= zhencount + 1;
        else begin
            zhencount <= 0;
        end

    localparam INIT = 0,
    		   CLEAR = 1,
    		   WAIT = 2,
    		   WRITE = 3,
    		   BADAPPLE_FINISH = 4,
               LOAD = 5,
               DELAY = 6;

    reg [5:0]cur_st=0,nxt_st=0;
    
    assign sram_read = cur_st==LOAD ? sram_write_read : sram_read_read;
    assign sram_write = cur_st==LOAD ? sram_write_write : sram_read_write;
    assign sram_selec = cur_st==LOAD ? sram_write_selec : sram_read_selec;
    assign addr_wr = cur_st==LOAD ? write_addr_wr : read_addr_wr;
    assign data_wr_in = write_data_wr;
    assign read_data_wr = data_wr_out;
    
    always@(posedge sck_reg)
        if(reset)
            cur_st<=INIT;
        else 
            cur_st<=nxt_st;
    always@(*)
    begin
        nxt_st=cur_st;
        case(cur_st) // Ã¤Â»?Ã¤Â¹Ë†Ã¤Â»â�?�¬Ã¤Â¹Ë�?�doneÃ¥Â°Â±Ã¦ËœÂ¯Ã§Å Â¶Ã¦?ÂÃ¥Ë†â€¡Ã¦ÂÂ¢Ã§Å¡â?žÃ¤Â¿Â¡Ã¥ÂÂ?
            INIT:if(init_done)     nxt_st=CLEAR;
            CLEAR:if(clear_done)    nxt_st=LOAD;
            LOAD:if(sram_write_finish) nxt_st=WRITE;
            WAIT:/*if(sram_read_finish) nxt_st=BADAPPLE_FINISH;else if(sram_read_loadbytedone)*/ if(delay_signal)nxt_st=DELAY; else nxt_st=WRITE;
            WRITE:if(write_done)    nxt_st=WAIT;
            DELAY:if(!delay_signal) nxt_st=WRITE;
            BADAPPLE_FINISH:nxt_st=BADAPPLE_FINISH;
            default:nxt_st=BADAPPLE_FINISH;
        endcase
    end
    assign sram_write_start = cur_st==LOAD ? 1'b1 : 1'b0;
    assign sram_read_start = cur_st==WAIT || cur_st==WRITE ? 1'b1 : 1'b0;

    // 只有下一个状态是WRITE才启�?
   	always @ (posedge sram_read_loadbytedone) begin
        if(delay_signal) begin
            set_pos_x_reg <= 0;
            set_pos_y_reg <= 0;
        end
        else
       		if(set_pos_x_reg < 127) begin
       			set_pos_x_reg <= set_pos_x_reg + 1;
       		end
       		else begin
    			set_pos_x_reg <= 0;  
    			if(set_pos_y_reg < 7) begin
    	   			set_pos_y_reg <= set_pos_y_reg + 1;
    	   		end
    	   		else begin
    	   			set_pos_y_reg <= 0;
    	   		end			 			
       		end
   	end

    always@(*) begin
        if(reset) begin
            write_data=0;
            write_start=0;
        end
        else begin
            if(cur_st==WRITE) begin
                write_data=data_after_chuli;
                write_start=1;
            end        
            else begin
            	write_start=0;                        
           	end
        end
    end

    // clear_start
    always@(*)
        if(reset) clear_start=0;
        else if(cur_st==CLEAR) clear_start=1;
        else clear_start=0;
    
    // dc_in
    always@(*)
        if(reset)   dc_in=0;
        else if(cur_st==INIT)  dc_in=dc_init;
        else if(cur_st==CLEAR)  dc_in=dc_clear;
        else if(cur_st==WRITE)  dc_in=dc_write;
        else dc_in=0;
    
    // spi_data_out
    always@(*)
        if(reset)   spi_data_out=0;
        else if(cur_st==INIT)  spi_data_out=spi_data_init;
        else if(cur_st==CLEAR)  spi_data_out=spi_data_clear;
        else if(cur_st==WRITE)  spi_data_out=spi_data_write;
        else spi_data_out=0;
    
    // spi_send
    always@(*)
        if(reset) spi_send=0;
        else if(cur_st==INIT) spi_send=spi_send_init;
        else if(cur_st==CLEAR) spi_send=spi_send_clear;
        else if(cur_st==WRITE) spi_send=spi_send_write;
        else spi_send = 0;

//PORT IS OCCUPIED    // Debug单元，�?�过灯来判断当前状�??
    always@(*) begin
        case(cur_st) // Ã¤Â»?Ã¤Â¹Ë†Ã¤Â»â�?�¬Ã¤Â¹Ë�?�doneÃ¥Â°Â±Ã¦ËœÂ¯Ã§Å Â¶Ã¦?ÂÃ¥Ë†â€¡Ã¦ÂÂ¢Ã§Å¡â?žÃ¤Â¿Â¡Ã¥ÂÂ?
            INIT:begin st_init=1;st_clear=0;st_wait=0;st_write=0;end
            CLEAR:begin st_init=1;st_clear=1;st_wait=0;st_write=0;end
            LOAD:begin st_init=0;st_clear=1;st_wait=0;st_write=0;end
            WAIT: begin st_init=0;st_clear=0;st_wait=1;st_write=0;end
            WRITE:begin st_init=0;st_clear=0;st_wait=0;st_write=1;end
            BADAPPLE_FINISH:begin st_init=1;st_clear=1;st_wait=1;st_write=1;end
            default:begin st_init=1;st_clear=0;st_wait=1;st_write=1;end
        endcase
    end
    wire[19:0] sram_count;
    assign sram_count = cur_st == LOAD ? sram_write_count : sram_read_count;
    super_stop_watch_test super_stop_watch_test(
        .showdata({4'b0,sram_count}),
        .en0(en0),
        .en1(en1),
        .sseg0(sseg0),
        .sseg1(sseg1) 
    );

endmodule
