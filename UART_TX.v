`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 23:19:14
// Design Name: 
// Module Name: UART_TX
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


module UART_TX #(parameter DBIT = 8, SB_TICK = 16)(
  input clk,
  input reset,
  input tx_start,
  input s_tick,
  input [DBIT-1:0] tx_din,
  output reg tx_done_tick,
  output tx
);
  localparam idle = 0, start = 1, data = 2, stop = 3;
  reg [1:0] state_reg, state_next;
  reg [3:0] s_reg, s_next;
  reg [$clog2(DBIT)-1:0] n_reg, n_next;
  reg [DBIT-1:0] b_reg, b_next;
  reg tx_reg, tx_next;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state_reg <= idle; s_reg <= 0; n_reg <= 0; b_reg <= 0; tx_reg <= 1;
    end else begin
      state_reg <= state_next; s_reg <= s_next; n_reg <= n_next;
      b_reg <= b_next; tx_reg <= tx_next;
    end
  end

  always @(*) begin
    state_next = state_reg; s_next = s_reg; n_next = n_reg; b_next = b_reg;
    tx_next = tx_reg; tx_done_tick = 1'b0;
    case (state_reg)
      idle:  if (tx_start) begin tx_next = 0; s_next = 0; b_next = tx_din; state_next = start; end
      start: if (s_tick) begin
                if (s_reg == 15) begin s_next = 0; n_next = 0; state_next = data; end
                else s_next = s_reg + 1;
             end
      data:  begin tx_next = b_reg[0];
              if (s_tick) begin
                if (s_reg == 15) begin
                  s_next = 0; b_next = {1'b0, b_reg[DBIT-1:1]};
                  if (n_reg == DBIT-1) state_next = stop;
                  else n_next = n_reg + 1;
                end else s_next = s_reg + 1;
              end
            end
      stop:  begin tx_next = 1;
              if (s_tick) begin
                if (s_reg == SB_TICK - 1) begin tx_done_tick = 1'b1; state_next = idle; end
                else s_next = s_reg + 1;
              end
            end
      default: state_next = idle;
    endcase
  end

  assign tx = tx_reg;
endmodule
