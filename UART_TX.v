`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Amaan Sami
// 
// Create Date: 12.07.2025
// Design Name: UART Transmitter
// Module Name: uart_tx
// Project Name: UART Protocol Implementation
// Target Devices: 
// Tool Versions: 
// Description: UART Transmitter with FSM and FIFO data input
// 
//////////////////////////////////////////////////////////////////////////////////

module UART_TX
#(
    parameter DBIT = 8,        // Number of data bits
    parameter SB_TICK = 16     // Ticks for 1 stop bit (16x baud rate)
)
(
    input clk,
    input reset_n,
    input tx_start,                         // Trigger to start transmission
    input s_tick,                           // Tick at 16x baud rate
    input [DBIT - 1 : 0] tx_din,            // Data input from FIFO
    output reg tx_done_tick,                // Done signal after stop bit
    output tx                               // Serial output line
);

    // Parameterized counter widths
    localparam S_COUNTER_WIDTH = $clog2(SB_TICK);
    localparam N_COUNTER_WIDTH = $clog2(DBIT);

    // FSM States
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    // Registers
    reg [1:0] state_reg, state_next;
    reg [S_COUNTER_WIDTH - 1:0] s_reg, s_next;
    reg [N_COUNTER_WIDTH - 1:0] n_reg, n_next;
    reg [DBIT - 1:0] b_reg, b_next;
    reg tx_reg, tx_next;

    // Sequential logic (state & data registers) or present state logic
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            state_reg <= IDLE;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
            tx_reg    <= 1'b1; // Line idle state is high
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
            tx_reg    <= tx_next;
        end
    end

    // Combinational logic (next state and output)
    always @(*) begin
        // Default assignments
        state_next    = state_reg;
        s_next        = s_reg;
        n_next        = n_reg;
        b_next        = b_reg;
        tx_next       = tx_reg;
        tx_done_tick  = 1'b0;

        case (state_reg)
            IDLE: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    s_next     = 0;
                    b_next     = tx_din;
                    state_next = START;
                end
            end

            START: begin
                tx_next = 1'b0; // Send start bit
                if (s_tick) begin
                    if (s_reg == SB_TICK - 1) begin
                        s_next     = 0;
                        n_next     = 0;
                        state_next = DATA;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = b_reg[0]; // Send LSB first
                if (s_tick) begin
                    if (s_reg == SB_TICK - 1) begin
                        s_next = 0;
                        b_next = {1'b0, b_reg[DBIT - 1:1]}; // Shift right with 0-fill
                        if (n_reg == DBIT - 1) begin
                            state_next = STOP;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1; // Stop bit
                if (s_tick) begin
                    if (s_reg == SB_TICK - 1) begin
                        tx_done_tick = 1'b1;
                        state_next   = IDLE;
                        s_next       = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            default: state_next = IDLE;
        endcase
    end

    // Output assignment
    assign tx = tx_reg;

endmodule
