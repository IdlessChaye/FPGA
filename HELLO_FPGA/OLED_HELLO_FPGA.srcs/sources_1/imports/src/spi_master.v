// spi_send信号到了之后，要延迟一个sck周期才开始传送data
// init阶段spi_send一直有效
// 只要spi_data_out在spi_send之后的一个周期截止之前到，数据都能传送
// dc信号要保持有效，在spi_send之后一个周期截止之前开始保持都行
// 外向信号send_done只有FINISH阶段有效，控制oled_init执行
module spi_master
(
	output reg sck,         //1MHz clk
	//input mosi,  // mosi很迷。。没有相关代码。。还需要自己补上 ？？？
	output reg miso,  
	output reg cs,

	input rst,
	
	input spi_send,
	input[7:0] spi_data_out,
	output reg spi_send_done,
	input clk,
	
	input dc_in,
	output dc_out,
	output reg sck_reg
);

   // cs低时 dc_out为dc_in，平常为0
   assign dc_out= (!cs)?dc_in:0; 

   // 初始化
    initial begin sck=0;miso=0;cs=0;sck_reg=0;count=0;cur_st=0;nxt_st=0;reg_data=0;delay_count=0;end

   // DATA需要的count
   reg [3:0]count;

   //状态定义
   localparam IDLE=0,
   	      CS_L=1,
   	      DATA=2,
   	      FINISH=3;
   reg [4:0]cur_st,nxt_st;

   // 当spi_send为高时，载入spi_data_out
   reg [7:0] reg_data;
   //reg sck_reg;

   // 以下部分，内部分频，输出1MHz的sck_reg
   reg [31:0]delay_count;
   always@(posedge clk)
   if(~rst)
      delay_count<=0;
   else if(delay_count==50)
      delay_count<=0;
   else delay_count<=delay_count+1;
   
   always@(posedge clk)
   if(~rst) // rst始终为1，都不用看了
      sck_reg<=0;
   else if(delay_count==50)
      sck_reg<=!sck_reg;
   
   // sck 平常高电平
	always@(*)
	if(cs) sck=1; 
	else if(cur_st==FINISH) sck=1;
	else if(!cs) sck=sck_reg;
	else sck=1;
   
   // 状态切换
   always@(posedge sck_reg)
   if(~rst)
   	cur_st<=0;
   else cur_st<=nxt_st;
   
   // 状态转换
   always@(*)
   begin
   	nxt_st=cur_st;
   	case(cur_st)
   		IDLE:if(spi_send) nxt_st=CS_L;
   		CS_L:nxt_st=DATA;
   		DATA:if(count==7) nxt_st=FINISH;
   		FINISH:nxt_st=IDLE;
   	  default:nxt_st=IDLE;
   	endcase
   end
   // 状态切换：IDLE -> CS_L -> DATA八次 -> FINISH -> IDLE

   
   // spi_send_done 高有效
   always@(*)
   if(~rst)
      spi_send_done=0;
   else if(cur_st==FINISH)
      spi_send_done=1;
   else spi_send_done=0;

   // cs 低有效那为什么要初始化成0。。反正一个上升沿就1了
   always@(posedge sck_reg)
   	if(~rst) cs<=1;
   	else if(cur_st==CS_L) cs<=0;
   	else if(cur_st==DATA) cs<=0;
   	else cs<=1;
   
   // count DATA状态需要
   always@(posedge sck_reg)
   	if(~rst)
   		count<=0;
   	else if(cur_st==DATA)
   		count<=count+1;
   	else if(cur_st==IDLE | cur_st==FINISH)
   		count<=0;
   
   // spi_send spi_data_out载入 轮流miso输出
   always@(negedge sck_reg or negedge rst)
   	if(~rst)
   		miso<=0;	
   	else if(cur_st==DATA) 
   	begin
   		reg_data[7:1]<=reg_data[6:0];
   		miso<=reg_data[7];
      end
      else if(spi_send) // init阶段，不是DATA阶段就一直是这里
         reg_data<=spi_data_out; 
endmodule