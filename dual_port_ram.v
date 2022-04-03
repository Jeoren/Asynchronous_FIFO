//dual_port_ram.v by Shaoxiong on 2022_4_2
//Dual Port RAM module
//Dual Port ==> write & read ports

module DUAL_PORT_RAM # (
    parameter RAM_WIDTH = 8,    //width of the RAM
    parameter RAM_DEPTH = 256,  //depth of the RAM
    parameter ADDR_WIDTH = 8    //data address
)(
    input                               write_clk,
    input                               write_en,
    input           [ADDR_WIDTH-1:0]    write_addr,
    input           [RAM_WIDTH -1:0]    write_data,

    input                               read_clk,
    input                               read_en,
    input           [ADDR_WIDTH-1:0]    read_addr,
    output  reg     [RAM_WIDTH -1:0]    read_data     
);
//RAM define
reg [RAM_WIDTH -1:0] RAM [RAM_DEPTH -1:0];

always@ (posedge write_clk) begin
    if (write_en) begin
        RAM[write_addr] <= write_data;
    end
end

always@ (posedge read_clk) begin
    if (read_en) begin
        RAM[read_addr] <= read_data;
    end
end
endmodule//end
