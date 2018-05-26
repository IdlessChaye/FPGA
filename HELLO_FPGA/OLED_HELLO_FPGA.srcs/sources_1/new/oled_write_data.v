`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2016 10:53:53 PM
// Design Name: 
// Module Name: oled_write_data
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

// 几乎和oled_clear模块一样
module oled_write_data(
    input clk,
    input reset,
    input send_done,
    input [47:0]write_data,
    input [7:0]set_pos_x,
    input [7:0]set_pos_y,
    input write_start,
    output reg spi_send,
    output reg[7:0] spi_data,
    output dc,
    output write_done
);

    assign dc=(cur_st==4)?1:0; // 只有4状态传输数据
    assign write_done=(cur_st==6)?1:0;
    //assign spi_send=(cur_st==1 | 2 | 3 | 4)?1:0; // 之后模块解释此句

    reg [7:0]x_tmp,y_tmp;  
    wire [7:0]  Set_pos_0=8'hb0 | y_tmp,
                Set_pos_1= (x_tmp[7:4] & 4'hf) | 8'h10,
                Set_pos_2= (x_tmp[3:0] & 4'hf) | 8'h00;
    
    reg [47:0]write_data_tmp;
    reg [3:0]count;

    reg [3:0]cur_st,nxt_st;
    always@(posedge clk or posedge reset)
        if(reset)
            cur_st<=0;
        else if(cur_st==1 | cur_st==2 | cur_st==3 | cur_st==4 ) 
           begin if(send_done)  cur_st<=nxt_st; end
        else cur_st<=nxt_st;
    always@(*) begin
        nxt_st=cur_st;
        case(cur_st)
            0:begin if(write_start)  nxt_st=cur_st+1; end
            1:begin                  nxt_st=cur_st+1; end
            2:begin                  nxt_st=cur_st+1; end
            3:begin                  nxt_st=cur_st+1; end
            4:begin                  nxt_st=cur_st+1; end  
            5:if(count==5) nxt_st=6; else nxt_st=1;
            6:nxt_st=0; 
            default:nxt_st=0;
        endcase
    end
    
    always@(*)
        if(reset) begin
            spi_data=0;
            spi_send=0;
        end
        else begin 
            case(cur_st)
                0:begin spi_data = 0;                      spi_send=0;    end 
                1:begin spi_data = Set_pos_0;              spi_send=1;    end
                2:begin spi_data = Set_pos_1;              spi_send=1;    end
                3:begin spi_data = Set_pos_2;              spi_send=1;    end      
                4:begin spi_data = write_data_tmp[47:40];  spi_send=1;    end
                5:spi_send=0;
            endcase
        end

    always@(posedge clk or posedge reset)
        if(reset) begin
            x_tmp<=0;
            y_tmp<=0;
            write_data_tmp<=0;
            count<=0;
        end
        else begin 
            case(cur_st)
                0:begin
                    x_tmp<=set_pos_x;
                    y_tmp<=set_pos_y;
                    write_data_tmp<=write_data;
                    count<=0;
                  end
                5:begin // 从第4页开始从左到右每个字母扫六列
                    //if(x_tmp>122) y_tmp<=y_tmp+1;
                    x_tmp<=x_tmp+1;
                    write_data_tmp[47:8]<=write_data_tmp[39:0];
                    count<=count+1;
                  end
            endcase
        end
endmodule