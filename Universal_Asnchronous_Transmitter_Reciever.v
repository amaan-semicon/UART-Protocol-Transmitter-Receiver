`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025
// Design Name: 
// Module Name: Universal_Asnchronous_Transmitter_Reciever
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top-level UART integrating FIFO, TX, RX, and Baud Generator
// 
//////////////////////////////////////////////////////////////////////////////////

module Universal_Asnchronous_Transmitter_Reciever #(
  parameter DBIT = 8,
  parameter SB_TICK = 16,
  parameter FIFO_DEPTH = 16
)(
  input clk,
  input reset_n,

  // Receiver interface
  output [DBIT - 1:0] r_data,
  input rd_uart,
  output rx_empty,
  input rx,

  // Transmitter interface
  input [DBIT - 1:0] w_data,
  input wr_uart,
  output tx_full,
  output tx,

  // Baud rate generator config
  input [10:0] TIMER_FINAL_VALUE
);

  //================ Baud Rate Generator =================//
  wire tick;
  baud_rate_generator #( .BITS(11) ) timer (
    .clk(clk),
    .reset_n(reset_n),     // Assuming module uses active-high reset internally
    .enable(1'b1),
    .FINAL_VALUE(TIMER_FINAL_VALUE),
    .done(tick)
  );

  //================ UART Receiver + FIFO =================//
  wire rx_done_tick;
  wire [DBIT-1:0] rx_dout;

  UART_RX #(
    .DBIT(DBIT),
    .SB_TICK(SB_TICK)
  ) receiver (
    .clk(clk),
    .reset_n(reset_n),
    .rx(rx),
    .s_tick(tick),
    .rx_done_tick(rx_done_tick),
    .rx_dout(rx_dout)
  );

  FIFO #(
    .FIFO_WIDTH(DBIT),
    .FIFO_DEPTH(FIFO_DEPTH)
  ) fifo_rx (
    .clk(clk),
    .reset_n(reset_n),
    .wr_en(rx_done_tick),
    .data_in(rx_dout),
    .FIFO_FULL(),         // Not needed in receive path
    .rd_en(rd_uart),
    .data_out(r_data),
    .FIFO_EMPTY(rx_empty),
    .DATA_COUNT()
  );

  //================ UART Transmitter + FIFO =================//
  wire tx_fifo_empty;
  wire tx_done_tick;
  wire [DBIT-1:0] tx_din;

  UART_TX #(
    .DBIT(DBIT),
    .SB_TICK(SB_TICK)
  ) transmitter (
    .clk(clk),
    .reset_n(reset_n),
    .tx_start(~tx_fifo_empty),
    .s_tick(tick),
    .tx_din(tx_din),
    .tx_done_tick(tx_done_tick),
    .tx(tx)
  );

  FIFO #(
    .FIFO_WIDTH(DBIT),
    .FIFO_DEPTH(FIFO_DEPTH)
  ) fifo_tx (
    .clk(clk),
    .reset_n(reset_n),
    .wr_en(wr_uart),
    .data_in(w_data),
    .FIFO_FULL(tx_full),
    .rd_en(tx_done_tick),
    .data_out(tx_din),
    .FIFO_EMPTY(tx_fifo_empty),
    .DATA_COUNT()
  );

endmodule
