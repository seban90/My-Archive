`timescale 1ns / 1ps

module test_mul_signed;
function integer clog2;
        input integer value;
        begin
        value = value - 1;
        for (clog2=0;value > 0;clog2=clog2+1)
            value = value >> 1;
        end
   endfunction
   
    reg clk, rst, fast_clk;
    localparam FAST_CLK = 10; 
    localparam CLK = 2*8*FAST_CLK;
    parameter BITWIDTH = 8;
    
    reg re;
    
    reg signed [BITWIDTH-1:0] din1[0:2<<BITWIDTH];
    reg signed [BITWIDTH-1:0] din2[0:2<<BITWIDTH];
    wire signed [2*BITWIDTH-1:0] dout;
    reg [clog2(2<<BITWIDTH):0] raddr1, raddr2;
    
    always @ (posedge clk or negedge rst) begin
        if(!rst) begin 
            raddr1 <= 0;
            raddr2 <= 0;
        end
        else begin
            re <= 1;
            if (raddr1 == 2<<BITWIDTH) begin
                raddr1 <= 0;
                if (raddr2 == 2<<BITWIDTH) $finish;//raddr2 <= 0;
                else raddr2 <= raddr2 + 1'b1;
            end
            else raddr1 <= raddr1 + 1'b1;
        end
    end
    integer i;
    initial begin
        
        for (i=0;i<(2<<BITWIDTH);i=i+1) begin: TEST
            din1[i] = (1 << BITWIDTH-1) + i;
            din2[i] = (1 << BITWIDTH-1) + i; 
        end
        
    end
    
    initial begin
        clk = 0; fast_clk = 0; rst = 1;
        #40 rst = 0;
        #200 rst = 1;
    end
    
    always #(CLK/2) clk = ~clk;
    always #(FAST_CLK/2) fast_clk = ~fast_clk;
    
    always @ (data_out_valid) begin
        if (data_out_valid) begin
            $display("a: %d, b: %d, result: %d at addr1: %d, addr2: %d", din1[raddr1-1], din2[raddr2], dout ,raddr1-1, raddr2); 
            if (dout != din1[raddr1-1] * din2[raddr2]) begin
                $display ("Error at Addr1: %d, Addr2,%d", raddr1, raddr2);
                $finish;
            end
            else $display("OK");
        end
    end
    wire fclk;
    assign fclk = ~fast_clk;
    wire [clog2(2*BITWIDTH)+1:0] last_count; 
    reg [clog2(2*BITWIDTH)+1:0] last_count2;
    always @(posedge fclk or negedge rst) begin
        if (!rst) last_count2 <= 0;
        else last_count2 <= last_count;
    end
 
    metronome_signed #(BITWIDTH) metro (
        fclk, rst, re, data_in_valid, out_valid, last_count
    );
    signed_multiplier #(BITWIDTH) inst0(
        .clk(fclk), 
        .rst(rst), 
        .data_in_valid(data_in_valid), 
        .a(din1[raddr1]), 
        .b(din2[raddr2]),
        .metronome_data_out_valid(out_valid),
        .last_count(last_count2), 
        .data_out_valid(data_out_valid),
        .dout(dout)
    );
   
endmodule
