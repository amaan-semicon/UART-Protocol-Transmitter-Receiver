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
  parameter FIFO_DEPTH = 16
)(
  input clk,
  input reset_n,

  // Write
  input wr_en,
  input [FIFO_WIDTH - 1 : 0] data_in,
  output FIFO_FULL,

  // Read
  input rd_en,
  output [FIFO_WIDTH - 1 : 0] data_out,
  output FIFO_EMPTY,

  // Status
  output [ $clog2(FIFO_DEPTH): 0 ] DATA_COUNT
);

  // Internal signals
  wire data_in_valid, data_out_valid;
  reg wr_en_internal;
  reg [$clog2(FIFO_DEPTH):0] DATA_COUNT_internal;
  reg [$clog2(FIFO_DEPTH)-1:0] wr_pointer;
  reg [$clog2(FIFO_DEPTH)-1:0] rd_pointer;

  assign data_in_valid = wr_en & ~FIFO_FULL;
  assign data_out_valid = rd_en & ~FIFO_EMPTY;
  assign DATA_COUNT = DATA_COUNT_internal;
  assign FIFO_FULL  = (DATA_COUNT_internal == FIFO_DEPTH) ? 1'b1 : 1'b0;
  assign FIFO_EMPTY = (DATA_COUNT_internal == 0) ? 1'b1 : 1'b0;

  // Write enable latch
  always @(posedge clk) begin
    if (~reset_n) 
    begin
      wr_en_internal <= 1'b0;
    end 
    else if (data_in_valid) 
    begin
      wr_en_internal <= 1'b1;
    end 
    else 
    begin
      wr_en_internal <= 1'b0;
    end
  end

  // Data counter
  always @(posedge clk) begin
    if (~reset_n) begin
      DATA_COUNT_internal <= 0;
    end 
    else if (data_in_valid & ~data_out_valid) 
    begin
      DATA_COUNT_internal <= DATA_COUNT_internal + 1'b1;
    end 
    else if (~data_in_valid & data_out_valid) 
    begin
      DATA_COUNT_internal <= DATA_COUNT_internal - 1'b1;
    end
  end

  // Write pointer
  always @(posedge clk) begin
    if (~reset_n) 
    begin
      wr_pointer <= 0;
    end 
    else if (data_in_valid) 
    begin
      wr_pointer <= wr_pointer + 1'b1;
    end
  end

  // Read pointer
  always @(posedge clk) begin
    if (~reset_n) 
    begin
      rd_pointer <= 0;
    end 
    else if (data_out_valid) 
    begin
      rd_pointer <= rd_pointer + 1'b1;
    end
  end

  // Instantiate memory
  random_access_memory #(
    .WIDTH_MEM(FIFO_WIDTH),
    .DEPTH_MEM(FIFO_DEPTH)
  ) fifo_mem (
    .clk(clk),
    .wr_enable(wr_en_internal),
    .wr_address(wr_pointer),
    .wr_data(data_in),
    .rd_enable(rd_en),
    .rd_address(rd_pointer),
    .rd_data(data_out)
  );

endmodule
