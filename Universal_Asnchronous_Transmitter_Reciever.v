`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 17:48:53
// Design Name: 
// Module Name: Universal_Asnchronous_Transmitter_Reciever
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


//================ UART Top-Level Module ==================
module Universal_Asnchronous_Transmitter_Reciever #(
  parameter data_bits = 8,
  parameter stop_bit_tick = 16
)(
  input clk,
  input reset,

  // Receiver interface
  output [data_bits - 1:0] r_data,
  input rd_uart,
  output rx_empty,
  input rx,

  // Transmitter interface
  input [data_bits - 1 : 0] w_data,
  input wr_uart,
  output tx_full,
  output tx,

  // Baud rate generator config
  input [10:0] TIMER_FINAL_VALUE
);

  wire tick;
  wire rx_done_tick;
  wire tx_done_tick;
  wire tx_fifo_empty;
  wire [data_bits - 1:0] rx_dout;
  wire [data_bits - 1:0] tx_din;

  assign tx_start = ~tx_fifo_empty;

  // Baud rate generator (16x oversampling)
  baud_rate_generator #(.BITS(11)) baud_gen (
    .clk(clk),
    .reset(reset),
    .enable(1'b1),
    .FINAL_VALUE(TIMER_FINAL_VALUE),
    .done(tick)
  );

  // UART Receiver
  UART_RX #(.DBIT(data_bits), .SB_TICK(stop_bit_tick)) rx_inst (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .s_tick(tick),
    .rx_done_tick(rx_done_tick),
    .rx_dout(rx_dout)
  );

  // RX FIFO
  FIFO #(.FIFO_WIDTH(data_bits), .FIFO_DEPTH(1024)) fifo_rx (
    .clk(clk),
    .reset(reset),
    .fifo_wr_enable(rx_done_tick),
    .fifo_wr_data(rx_dout),
    .fifo_full(), // not used
    .fifo_rd_enable(rd_uart),
    .fifo_rd_data(r_data),
    .fifo_empty(rx_empty),
    .fifo_data_count()
  );

  // UART Transmitter
  UART_TX #(.DBIT(data_bits), .SB_TICK(stop_bit_tick)) tx_inst (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .s_tick(tick),
    .tx_din(tx_din),
    .tx_done_tick(tx_done_tick),
    .tx(tx)
  );

  // TX FIFO
  FIFO #(.FIFO_WIDTH(data_bits), .FIFO_DEPTH(1024)) fifo_tx (
    .clk(clk),
    .reset(reset),
    .fifo_wr_enable(wr_uart),
    .fifo_wr_data(w_data),
    .fifo_full(tx_full),
    .fifo_rd_enable(tx_done_tick),
    .fifo_rd_data(tx_din),
    .fifo_empty(tx_fifo_empty),
    .fifo_data_count()
  );

endmodule
