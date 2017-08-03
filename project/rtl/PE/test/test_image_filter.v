`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module test_image_filter;

    function integer clog2;
        input integer value;
            begin
                value = value - 1;
                for (clog2=0;value>0;clog2=clog2+1)
                    value = value >> 1;
            end
    endfunction
    
    reg clk, fast_clk;
    reg rst;
    
    
    parameter BITWIDTH = 8;
    parameter ROWS = 6;
    parameter COLS = 6;
    parameter FAST_CLK = 20;
    parameter CLK = 2*BITWIDTH*FAST_CLK;
    
    wire fclk;
    reg [2:0] mod;
    wire [BITWIDTH-1:0] data_out;
    reg data_in_valid;
    wire [clog2(COLS):0] col;
    wire [clog2(ROWS):0] row;
    reg [clog2(COLS):0] x;
    reg [clog2(ROWS):0] y;
    reg [BITWIDTH-1:0] syn_data_out;
    reg [BITWIDTH-1:0] data[0:COLS*ROWS-1];
    reg [clog2((COLS-2)*(ROWS-2)):0] waddr; 
    reg [clog2(COLS*ROWS):0] raddr;
    reg [BITWIDTH-1:0] WRITE_RAM[0:(COLS-2)*(ROWS-2)-1];
        
    initial begin
        clk <= 0; fast_clk <= 0; mod <= 0; data_in_valid <= 0;
        $readmemh("rom.mem", data);
        rst <= 1; #40 rst <= 0; #2000 rst <= 1;
        #2000 mod <= 3'b001;
        #3000 data_in_valid <= 1;
    end
    always  #(FAST_CLK/2) fast_clk <= ~fast_clk;
    always  #(CLK/2) clk <= ~clk;
    not(fclk, fast_clk);
    
    always @ (posedge clk or negedge rst) begin
        if (!rst) raddr <= 0;
        else if (process_enable) begin
            raddr <= raddr + 1'b1;
            if (raddr == COLS*ROWS -1)
                raddr <= 0;
        end
    end
 
    image_filter #(.BITWIDTH(BITWIDTH),.COLS(COLS),.ROWS(ROWS)) Image_fiter (
        .clk(clk), 
        .fclk(fclk), 
        .rst(rst), 
        .data_in_valid(data_in_valid), 
        .mod(mod), 
        .data_in(data[raddr]), 
        .data_out_valid(filter_out_valid), 
        .process_enable(process_enable), 
        .data_out(data_out),
        .x(col),
        .y(row));
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            x <= 0; y <= 0;
        end else begin
            x <= col; y <= row;
        end
    end
    wire data_out_valid;
    assign data_out_valid = (x >= 2 && y >= 2) ? 1:0;
    always @ (filter_out_valid) begin
        if (filter_out_valid) syn_data_out <= data_out;
    end
        
    always @ (posedge clk or negedge rst) begin
        if (!rst) waddr <= 0;
        else if (data_out_valid) begin
            waddr <= waddr + 1'b1;
            if (waddr == (COLS-2)*(ROWS-2)-1)
                waddr <= 0;
        end
    end
    integer j;
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            for (j=0;j<(COLS-2)*(ROWS-2);j=j+1)
                WRITE_RAM[j] <= 0;
        end
        if (data_out_valid)
            WRITE_RAM[waddr] <= syn_data_out;
    end
endmodule
