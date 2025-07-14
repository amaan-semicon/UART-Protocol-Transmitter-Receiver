`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 17:49:32
// Design Name: 
// Module Name: baud_rate_generator
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

module baud_rate_generator #(parameter BITS = 16 )(
input clk,
input reset_n,
input enable,
input [BITS-1:0] FINAL_VALUE,
output  done

    );
  reg [BITS-1:0] q_present,q_next;
  
//present-state
 always@(posedge clk or negedge reset_n)
    if(~reset_n)
        q_present <= 1'b0;
    else if(enable)
        q_present <= q_next;
    else
        q_present <= q_present;
//next-state-logic
    assign done = (q_present == FINAL_VALUE);
 always@(*) begin
    if(done)
        q_next = 1'b0;
    else
        q_next = q_present + 1'b1 ;
        end
    
endmodule
