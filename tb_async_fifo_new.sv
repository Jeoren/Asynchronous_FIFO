`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/4/2 10:30:49
// Design Name: 
// Module Name: async_fifo_tb
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


module tb_async_fifo;
    
    reg                               rst_n;
                                
    reg                               wr_clk;
    reg                               wr_en;
    reg           [15:0]              data_in;
    wire                              full;
                
    reg                               rd_clk;
    reg                               rd_en;
    wire          [15:0]              data_out;
    wire                              empty;
    
    parameter  RAM_WIDTH = 8;
    parameter  RAM_DEPTH = 256;
    
    ASYNC_FIFO #(
        .RAM_WIDTH(RAM_WIDTH),
        .RAM_DEPTH(RAM_DEPTH),
    ) async_fifo_inst (
        .rst_n      (rst_n  ),
        .write_clk  (wr_clk ),
        .write_en   (wr_en  ),
        .write_data (data_in),
        .read_clk   (rd_clk ),
        .read_en    (rd_en  ),
        .read_data  (data_out),
        .fifo_empty (empty  ),
        .fifo_full  (full   )
    );
    
    initial wr_clk = 0;
    always#10 wr_clk = ~wr_clk;
    
    initial rd_clk = 0;
    always#30 rd_clk = ~rd_clk;
    
    always@(posedge wr_clk or negedge rst_n)begin
        if(!rst_n)
            data_in <= 'd0;
        else if(wr_en)
            data_in <= data_in + 1'b1;
        else
            data_in <= data_in;
    end
    
    initial begin
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        #200;
        rst_n = 1;
        wr_en = 1;
        #20000;
        wr_en = 0;
        rd_en = 1;
        #20000;
        rd_en = 0;
        $stop; 
    end
    
endmodule
