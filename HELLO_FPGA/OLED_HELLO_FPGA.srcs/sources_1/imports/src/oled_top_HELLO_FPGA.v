`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2016 10:23:47 AM
// Design Name: 
// Module Name: oled_top
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


module oled_top(
    output sck, // spi的sck信号
    //input mosi,
    output miso, // spi的miso信号

    output reg reset_oled, // ？？�?
    input clk, // FPGA板子上生成的100MHz的时钟信�?
    output dc, // 高数据，低命�?
    output sck_reg // spi_master模块生成�?1MHz的时钟信�?
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
        if(reset_count==10)
        begin
            reset_oled<=1;
            reset_n<=1;
        end
        else if(reset_count==10000)
        begin
            reset_oled<=0;
            reset_n<=0;
        end
        else if(reset_count==20000)
            reset_oled<=1;
        else if(reset_count==30000)
            reset_n<=1;
    
    reg spi_send; // spi启动信号，可以一直为高电�?
    reg [7:0]spi_data_out; // spi要传输的数据
    wire spi_send_done; // spi传完�?个字节为�?
    reg dc_in; // spi_master的dc_in
    wire reset=!reset_n; // 为什么不是reset_reg。�?��??
    
    // 不仅产生1MHz的时钟，还实现spi的miso起始信号为spi_send
    spi_master spi_master 
    (
        .sck    (sck), // 非工作的时�?�是高电平，工作再变1MHz
        .miso   (miso),
        .cs     (cs), // 片�??
        .rst    (1),
        .spi_send   (spi_send), // 启动信号
        .spi_data_out   (spi_data_out), // 待传数据
        .spi_send_done  (spi_send_done), // 传输完成
        .clk    (clk), // 100MHz
        .dc_in  (dc_in), // 
        .dc_out (dc), // 当cs为低时为dc_in,要不然传送指�?
        .sck_reg (sck_reg) // 1MHz clk 马不停蹄�?
    ); // 怎么少了个mosi啊�?��?��??
    
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
    reg [47:0]write_data;
    reg [7:0]set_pos_x,set_pos_y;
    reg write_start;
    
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
    


    // 数据，高位是图像的左边，每一个字节的比特从下�?上码
    localparam  X=48'h00_63_14_08_14_63,   // X
                I=48'h00_00_41_7F_41_00,   // I
                L=48'h00_7F_40_40_40_40,   // L
                N=48'h00_7F_04_08_10_7F,   // N
                H=48'h00_7F_08_08_08_7F,   // H
                E=48'h00_7F_49_49_49_49,   // E
                O=48'h00_3E_41_41_41_3E,   // O
                F=48'h00_7F_09_09_09_09,   // F
                P=48'h00_7F_09_09_09_06,   // P
                G=48'h00_3E_41_49_49_39,   // G
                A=48'h00_7C_0A_09_0A_7C;   // A
    
    reg [5:0]cur_st,nxt_st;
    initial begin 
        cur_st=0;
        nxt_st=0;
    end
    always@(posedge sck_reg)
        if(reset) 
            cur_st<=0;
        else 
            cur_st<=nxt_st;
    always@(*)
    begin
        nxt_st=cur_st;
        case(cur_st) // �?么什么done就是状�?�切换的信号
            0:if(init_done)     nxt_st=1;
            1:if(clear_done)    nxt_st=nxt_st+1;
            2:if(write_done)    nxt_st=nxt_st+1;
            3:if(write_done)    nxt_st=nxt_st+1;
            4:if(write_done)    nxt_st=nxt_st+1;
            5:if(write_done)    nxt_st=nxt_st+1;
            6:if(write_done)    nxt_st=nxt_st+1;
            7:if(write_done)    nxt_st=nxt_st+1;
            8:if(write_done)    nxt_st=nxt_st+1;
            9:if(write_done)    nxt_st=nxt_st+1;
            10:if(write_done)    nxt_st=nxt_st+1;
            11:nxt_st=11;
            default:nxt_st=0;
        endcase
    end
    
    /*always@(posedge clk)
        if(reset)         write_start<=0;
        else if(cur_st>0) write_start<=1;*/
     
    always@(*) begin
        if(reset) begin
            set_pos_x=0;
            set_pos_y=0;
            write_data=0;
            write_start=0;
        end
        else begin
            case(cur_st)
                2: begin
                    set_pos_x=30;
                    set_pos_y=3;
                    write_data=H;
                    write_start=1;
                end
                3: begin
                    set_pos_x=36;
                    set_pos_y=3;
                    write_data=E;
                end
                4: begin
                    set_pos_x=42;
                    set_pos_y=3;
                    write_data=L;
                end
                5: begin
                    set_pos_x=48;
                    set_pos_y=3;
                    write_data=L;
                end
                6: begin
                    set_pos_x=54;
                    set_pos_y=3;
                    write_data=O;
                end
                7: begin
                    set_pos_x=60;
                    set_pos_y=4;
                    write_data=F;
                end
				8: begin
                    set_pos_x=66;
                    set_pos_y=4;
                    write_data=P;
                end    
				9: begin
                    set_pos_x=72;
                    set_pos_y=4;
                    write_data=G;
                end    
				10: begin
                    set_pos_x=78;
                    set_pos_y=4;
                    write_data=A;
                end                                              
                default: begin
                    set_pos_x=90;
                    set_pos_y=3;
                    write_data=X;
                    write_start=0;
                end
            endcase
        end
    end

    // clear_start
    always@(*)
        if(reset) clear_start=0;
        else if(cur_st==1) clear_start=1;
        else clear_start=0;
    
    // dc_in
    always@(*)
        if(reset)   dc_in=0;
        else if(cur_st==0)  dc_in=dc_init;
        else if(cur_st==1)  dc_in=dc_clear;
        else if(cur_st==7 | cur_st==8 | cur_st==9 | cur_st==10 | cur_st==2 | cur_st==3 | cur_st==4 | cur_st==5 | cur_st==6 )  dc_in=dc_write;
        else if(cur_st==11)  dc_in=0;
        else dc_in=0;
    
    // spi_data_out
    always@(*)
        if(reset)   spi_data_out=0;
        else if(cur_st==0)  spi_data_out=spi_data_init;
        else if(cur_st==1)  spi_data_out=spi_data_clear;
        else if(cur_st==7 | cur_st==8 | cur_st==9 | cur_st==10 | cur_st==2 | cur_st==3 | cur_st==4 | cur_st==5 | cur_st==6)  spi_data_out=spi_data_write;
        else if(cur_st==11)  spi_data_out=0;
        else spi_data_out=write_data;
    
    // spi_send
    always@(*)
        if(reset) spi_send=0;
        else if(cur_st==0) spi_send=spi_send_init;
        else if(cur_st==1) spi_send=spi_send_clear;
        else if(cur_st==7 | cur_st==8 | cur_st==9 | cur_st==10 | cur_st==2 | cur_st==3 | cur_st==4 | cur_st==5 | cur_st==6) spi_send=spi_send_write;
        else if(cur_st==11) spi_send=0;
    
endmodule
    