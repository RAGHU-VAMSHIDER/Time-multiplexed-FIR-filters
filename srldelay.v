`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2023 09:21:37 PM
// Design Name: 
// Module Name: srldelay
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


module srldelay #(parameter WL=12) (input CLK, EN, input [3:0] s, input [WL-1:0] in, output [WL-1:0] out);

genvar i;
generate 
    for (i=0;i<WL;i=i+1) begin: srlloop
        SRL16E #( .INIT(16'h0000)) SRL16E_inst (
           .Q(out[i]),       // SRL data output
           .A0(s[0]),     // Select[0] input
           .A1(s[1]),     // Select[1] input
           .A2(s[2]),     // Select[2] input
           .A3(s[3]),     // Select[3] input
           .CE(EN),     // Clock enable input
           .CLK(CLK),   // Clock input
           .D(in[i])        // SRL data input
        );
    end
endgenerate

endmodule

