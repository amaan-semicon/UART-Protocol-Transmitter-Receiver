`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 17:47:38
// Design Name: 
// Module Name: FIFO
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


module FIFO #(
  parameter FIFO_WIDTH = 8,
  parameter FIFO_DEPTH = 8
)(
  input clk,
  input reset,
  input fifo_wr_enable,
  input [FIFO_WIDTH - 1:0] fifo_wr_data,
  output fifo_full,
  input fifo_rd_enable,
  output wire [FIFO_WIDTH - 1:0] fifo_rd_data,  // ✅ Must be wire, driven by memory
  output fifo_empty,
  output [$clog2(FIFO_DEPTH):0] fifo_data_count
);

  // Internal signals
  wire valid_fifo_wr;
  wire valid_fifo_rd;
  reg [$clog2(FIFO_DEPTH):0] dataCounter;
  reg [$clog2(FIFO_DEPTH) - 1:0] wr_pointer;
  reg [$clog2(FIFO_DEPTH) - 1:0] rd_pointer;

  // Write and Read enables
  assign valid_fifo_wr = fifo_wr_enable & ~fifo_full;
  assign valid_fifo_rd = fifo_rd_enable & ~fifo_empty;

  // Status outputs
  assign fifo_data_count = dataCounter;
  assign fifo_full  = (dataCounter == FIFO_DEPTH);
  assign fifo_empty = (dataCounter == 0);

  // Data counter logic
  always @(posedge clk) begin
    if (reset)
      dataCounter <= 0;
    else if (valid_fifo_wr & ~valid_fifo_rd)
      dataCounter <= dataCounter + 1;
    else if (valid_fifo_rd & ~valid_fifo_wr)
      dataCounter <= dataCounter - 1;
  end

  // Write pointer logic
  always @(posedge clk) begin
    if (reset)
      wr_pointer <= 0;
    else if (valid_fifo_wr)
      wr_pointer <= wr_pointer + 1;
  end

  // Read pointer logic
  always @(posedge clk) begin
    if (reset)
      rd_pointer <= 0;
    else if (valid_fifo_rd)
      rd_pointer <= rd_pointer + 1;
  end

  // Memory instantiation
  random_access_memory #(
    .Width(FIFO_WIDTH),
    .Depth(FIFO_DEPTH)
  ) fifo_mem (
    .clk(clk),
    .wr_enable(valid_fifo_wr),
    .wr_address(wr_pointer),
    .wr_data(fifo_wr_data),
    .rd_address(rd_pointer),
    .rd_data(fifo_rd_data)  // ✅ This is driven inside memory
  );

endmodule

