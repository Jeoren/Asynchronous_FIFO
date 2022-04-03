//async.fifo by Shaoxiong on 2022_4_2
//fifo motto: never write when its full
//            never read  when its empty

module ASYNC_FIFO #(
    parameter RAM_WIDTH = 8,                    //width of the RAM
    parameter RAM_DEPTH = 256                   //depth of the RAM
)(
    input                               rst_n                   ,
        
    input                               write_clk               ,
    input                               write_en                ,
    input           [RAM_WIDTH  -1:0]   write_data              ,
            
    input                               read_clk                ,
    input                               read_en                 ,
    output  reg     [RAM_WIDTH  -1:0]   read_data               ,
            
    output  wire                        fifo_empty              ,
    output  wire                        fifo_full   
);

    parameter       ADDR_WIDTH =$clog2(RAM_DEPTH)               ;    //address width == log2 (RAM_DEPTH)

    reg             [ADDR_WIDTH   :0]   write_pointer           ;
    wire            [ADDR_WIDTH -1:0]   write_addr              ;
    reg             [ADDR_WIDTH   :0]   read_pointer            ;
    wire            [ADDR_WIDTH -1:0]   read_addr               ;
        
    wire                                write_en_ram            ;
    wire                                read_en_ram             ;
            
    wire            [ADDR_WIDTH   :0]   write_pointer_gray      ;
    wire            [ADDR_WIDTH   :0]   read_pointer_gray       ;

    reg             [ADDR_WIDTH   :0]   write_pointer_gray_d    ; 
    reg             [ADDR_WIDTH   :0]   write_pointer_gray_d_d  ;
    reg             [ADDR_WIDTH   :0]   read_pointer_gray_d     ; 
    reg             [ADDR_WIDTH   :0]   read_pointer_gray_d_d   ;


    //RAM instantiation, dual-port <=> read & write 
        DUAL_PORT_RAM #(
            .RAM_WIDTH  (RAM_WIDTH  ),
            .RAM_DEPTH  (RAM_DEPTH  )
        ) RAM (
            .write_clk  (write_clk  ),
            .write_en   (write_en   ),
            .write_addr (write_addr ),
            .write_data (write_data ),
            .read_clk   (read_clk   ),
            .read_en    (read_en    ),
            .read_addr  (read_addr  ),
            .read_data  (read_data  )
        );

//==============================================================
//1. Create read/write adress of RAM
//==============================================================
assign write_addr = write_pointer[ADDR_WIDTH-1 :0];   //write_addr is 1bit less than its pointer
assign read_addr  = read_pointer [ADDR_WIDTH-1 :0];   //read_addr  is 1bit less than its pointer

//==============================================================
//2. Create read_enable/write_enable for RAM
//==============================================================
assign write_en_ram = write_en && !fifo_full;   
assign read_en_ram  = read_en  && !fifo_empty;

//==============================================================
//3. pointer increments for read and write operations
//==============================================================
always @(posedge write_clk or negedge rst_n) begin
    if (!rst_n)
        write_pointer <= 'd0;
    else 
        if (write_en && !fifo_full) 
            write_pointer <= write_pointer + 1'b1;
        else                            
            write_pointer <= write_pointer;
end

always @(posedge read_clk or negedge rst_n) begin
    if (!rst_n)
        read_pointer <= 'd0;
    else 
        if (read_en && !fifo_empty) 
            read_pointer <= read_pointer + 1'b1;
        else                            
            read_pointer <= read_pointer;
end

//==============================================================
//4.Create read/write gray code address from pointers
//==============================================================
assign write_pointer_gray = write_pointer ^ (write_pointer>>1);
assign read_pointer_gray  = read_pointer  ^ (read_pointer >>1);

//==============================================================
//5. Delay 2 cycles for CROSS DOMAIN read/write gray codes  
//==============================================================
always @(posedge read_clk or negedge rst_n) begin
    if (!rst_n) begin
        write_pointer_gray_d   <= 'd0;
        write_pointer_gray_d_d <= 'd0;
    end
    else begin
        write_pointer_gray_d   <= write_pointer_gray;
        write_pointer_gray_d_d <= write_pointer_gray_d;
    end
end

always @(posedge write_clk or negedge rst_n) begin
    if (!rst_n) begin
        read_pointer_gray_d   <= 'd0;
        read_pointer_gray_d_d <= 'd0;
    end
    else begin
        read_pointer_gray_d   <= read_pointer_gray;
        read_pointer_gray_d_d <= read_pointer_gray_d;
    end
end

//==============================================================
//6.Create flags when FIFO is full/empty
//==============================================================
assign fifo_empty = read_pointer_gray == write_pointer_gray_d_d;
assign fifo_full  = write_pointer_gray == {~read_pointer_gray_d_d[ADDR_WIDTH :ADDR_WIDTH-1], read_pointer_gray_d_d[ADDR_WIDTH-2:0]};


endmodule//end

//keynote here:
//fifo empty ==> read_gray== write_gray_d_d
//fifo full ==> write_gray== {2 inverted MSB of read_gray_d_d && rest of the codes are the SAME!}
// example:
// write_gray = 1_101,  read_gray_d_d = 0_001  ==> fifo is full !!
// Why? details check paper <Simulation and Synthesis Techniques for Asynchronous FIFO Design> by C.Cummings