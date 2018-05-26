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


module oled_clear(
    input clk,
    input reset,
    input send_done,
    input clear_start, // 模块开启信号
    output reg spi_send,
    output reg[7:0] spi_data,
    output clear_done,
    output dc
);

    assign dc=(cur_st==4)?1:0; // 只有状态4是数据
    assign clear_done=(cur_st==6)?1:0;
    //assign spi_send=(cur_st==1 | 2 | 3 | 4)?1:0; //之后有模块解释这条语句
    
    // 状态变量
    reg [3:0]cur_st=0,nxt_st=0;
    // 状态切换
    always@(posedge clk or posedge reset)
        if(reset)
            cur_st<=0;
        else if(cur_st==1 | cur_st==2 | cur_st==3 | cur_st==4) begin  
            if(send_done)  
                cur_st<=nxt_st;
        end
        else 
            cur_st<=nxt_st;
    // 状态转换
    always@(*) begin
        nxt_st=cur_st;
        case(cur_st)
            0:begin if(clear_start)  nxt_st=cur_st+1; end
            1:begin nxt_st=cur_st+1; end
            2:begin nxt_st=cur_st+1; end
            3:begin nxt_st=cur_st+1; end
            4:begin nxt_st=cur_st+1; end  
            5:if(x_tmp==127 && y_tmp==7) begin nxt_st=6;         end
              else begin nxt_st=1;   end  
            6:begin nxt_st=0;        end
            default:begin nxt_st=0;  end
        endcase
    end
    
    // 命令
    wire [7:0] Set_pos_0= 8'hb0 | y_tmp, // 设置页坐标
               Set_pos_1= (x_tmp[7:4] & 4'hf) | 8'h10, // 设置列坐标高四位
               Set_pos_2= (x_tmp[3:0] & 4'hf) | 8'h00; // 设置列坐标低四位

    always@(*) begin
        if(reset) begin
            spi_data=0;
            spi_send=0;
        end
        else begin 
            case(cur_st)
                0:begin spi_data = 0;         spi_send=0;    end 
                1:begin spi_data = Set_pos_0; spi_send=1;    end // 设置页坐标
                2:begin spi_data = Set_pos_1; spi_send=1;    end // 设置列坐标高四位
                3:begin spi_data = Set_pos_2; spi_send=1;    end // 设置列坐标低四位
                4:begin spi_data = 0;         spi_send=1;    end // 写入0，就是清零，所以dc是1
                5:spi_send=0;
            endcase
        end
    end

    reg [7:0]x_tmp=0,y_tmp=0; // y是页坐标，x是列坐标
    reg [47:0]write_data_tmp=0; // 有什么用呢。。
    reg [3:0]count=0;

    always@(posedge clk or posedge reset)
        if(reset) begin
            x_tmp<=0;
            y_tmp<=0;
            count<=0;            
            write_data_tmp<=0;
        end
        else case(cur_st)
            0:begin
                x_tmp<=0;
                y_tmp<=0;
                count<=0;
            end
            5:begin // 每次状态循环记一次数
                //if(x_tmp>122) y_tmp<=y_tmp+1;
                if(x_tmp==127) begin // 之前是if(x_tmp==130) begin
                    y_tmp<=y_tmp+1;
                    x_tmp<=0;
                end
                else
                    x_tmp<=x_tmp+1;
            end
        endcase

endmodule
