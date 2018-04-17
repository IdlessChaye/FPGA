module stop_watch_test(
    input clk,
    input go,clr,
    output[3:0] en0,en1,
    output[7:0] sseg0,sseg1 
    );
    wire[3:0] d7,d6,d5,d4,d3,d2,d1,d0;
    scan_hex_led_disp scan_hex_led_disp_unit0 (
        .clk(clk),.reset(1'b0),
        .hex3(d3),.hex2(d2),.hex1(d1),.hex0(d0),
        .dp(4'b0100),.en(en0),.sseg(sseg0)
    );
    scan_hex_led_disp scan_hex_led_disp_unit1 (
        .clk(clk),.reset(1'b0),
        .hex3(d7),.hex2(d6),.hex1(d5),.hex0(d4),
        .dp(4'b0101),.en(en1),.sseg(sseg1)
    );
    stop_watch stop_watch_unit (
        .clk(clk),
        .go(go),.clr(clr),
        .d7(d7),.d6(d6),.d5(d5),.d4(d4),.d3(d3),.d2(d2),.d1(d1),.d0(d0)
    );
endmodule 
/* `timescale 1ns / 1ns
module stop_watch_tb ();
    reg clk;
    reg go,clr;

    wire[3:0] d7,d6,d5,d4,d3,d2,d1,d0;

    wire[3:0] en0,en1; // enable
    wire[7:0] sseg0,sseg1;

    initial begin
        clk = 0;
        clr = 1;
        go = 1;
    end

    always begin 
        # 10 clk = ~clk;
    end

    stop_watch stop_watch_unit(
        .clk(clk),.clr(clr),.go(go),
        .d7(d7),.d6(d6),.d5(d5),.d4(d4),.d3(d3),.d2(d2),.d1(d1),.d0(d0)
    );
endmodule*/