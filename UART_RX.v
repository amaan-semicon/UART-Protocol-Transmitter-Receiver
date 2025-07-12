`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.07.2025 13:28:19
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: UART Receiver using FSM and oversampling
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module UART_RX 
#(
    parameter DBIT = 8,                 // # of data bits
    parameter SB_TICK = 16             // # of ticks for stop bit (usually 16 for 1x baud)
)
(
    input clk,
    input reset_n,
    input rx,
    input s_tick,                      // tick at 16x baud rate
    output reg rx_done_tick,          // signal asserted when full byte received
    output wire [DBIT-1:0] rx_dout    // output data
);

    // internal parameterized widths
    localparam S_COUNTER_WIDTH = $clog2(SB_TICK);    // e.g., 4 for 16 ticks
    localparam N_COUNTER_WIDTH = $clog2(DBIT);       // e.g., 3 for 8 bits

    // FSM States
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    // State registers and working registers
    reg [1:0] state_reg, state_next;
    reg [S_COUNTER_WIDTH-1:0] s_reg, s_next;         // Tick counter (0 to SB_TICK-1)
    reg [N_COUNTER_WIDTH-1:0] n_reg, n_next;         // Bit counter (0 to DBIT-1)
    reg [DBIT-1:0] b_reg, b_next;                    // Data shift register

    // FSM state register
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state_reg <= IDLE;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
        end
    end

    // FSM next-state logic
    always @(*) begin
        // default values
        state_next   = state_reg;
        s_next       = s_reg;
        n_next       = n_reg;
        b_next       = b_reg;
        rx_done_tick = 1'b0;

        case (state_reg)
            IDLE: begin
                if (~rx) begin                    // start bit detected (rx goes low)
                    s_next     = 0;
                    state_next = START;
                end
            end

            START: begin
                if (s_tick) begin
                    if (s_reg == (SB_TICK/2 - 1)) begin
                        s_next     = 0;
                        n_next     = 0;
                        state_next = DATA;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        s_next = 0;
                        b_next = {rx, b_reg[DBIT-1:1]}; // LSB first shift
                        if (n_reg == (DBIT - 1)) begin
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
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        rx_done_tick = 1'b1;
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

    // Output data assignment
    assign rx_dout = b_reg;

endmodule
