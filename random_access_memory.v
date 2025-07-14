`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 17:46:35
// Design Name: 
// Module Name: random_access_memory
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


module random_access_memory
#(
    parameter WIDTH_MEM = 8,
    parameter DEPTH_MEM = 16
)
(
    input clk,

    // Write interface
    input wr_enable,
    input [($clog2(DEPTH_MEM))-1:0] wr_address,
    input [WIDTH_MEM-1:0] wr_data,

    // Read interface
    input rd_enable,
    input [($clog2(DEPTH_MEM))-1:0] rd_address,
    output reg [WIDTH_MEM-1:0] rd_data
);

    // Memory declaration: [word width] [address depth]
    reg [WIDTH_MEM-1:0] mem [0:DEPTH_MEM-1];

    // Write operation (synchronous)
    always @(posedge clk) begin
        if (wr_enable)
            mem[wr_address] <= wr_data;
    end

    // Read operation (synchronous, 1-cycle delay)
    always @(posedge clk) begin
        if (rd_enable)
            rd_data <= mem[rd_address];
    end

endmodule
