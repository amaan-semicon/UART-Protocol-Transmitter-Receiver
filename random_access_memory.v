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
#(parameter Width = 8, Depth = 16)(
  input clk,
  input wr_enable,                              // Should become high when you want to write
  input [$clog2(Depth) - 1 : 0] wr_address,     // Write address
  input [Width - 1 :0] wr_data,                 // Data to be written
  input [$clog2(Depth) - 1:0] rd_address,       // Read address
  output reg [Width - 1:0] rd_data              // Read data
);

  reg [Width - 1:0] mem [0:Depth - 1];          // Declare memory block

  // Write logic
  always @(posedge clk) begin
    if (wr_enable)
      mem[wr_address] <= wr_data;
  end

  // Read logic (synchronous read, 1-cycle latency)
  always @(posedge clk) begin
    rd_data <= mem[rd_address];
  end

endmodule
