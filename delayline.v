`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2023 09:27:51 PM
// Design Name: 
// Module Name: delayline
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



//`define  LMLv  ( (clog2(M/16 + ( (M % 16)? 1 : 0))) + 4 )

module delayline #(parameter M=2, WL=14, LML=4, Nsrl = 1) (input CLK,  EN, input [LML-1:0] s, input [WL-1:0] in, output [WL-1:0] out );

//parameter LML = $clog2(M);
//parameter Nsrl = M/16 + ( (M % 16)? 1 : 0) ; 
//parameter LML =(clog2(M/16 + ( (M % 16)? 1 : 0))) + 4;


wire [WL-1:0] srlout [Nsrl-1:0] ;
wire [WL-1:0] srlin [Nsrl-1:0] ;

assign  srlin[0] = in;

genvar j;
genvar i;
generate
for (j=0;j<Nsrl;j=j+1) begin: srl 
    for (i=0;i<WL;i=i+1) begin: srlloop
        SRL16E #( .INIT(16'h0000)) SRL16E_inst (
           .Q(srlout[j][i]),       // SRL data output
           .A0(s[0]),     // Select[0] input
           .A1(s[1]),     // Select[1] input
           .A2(s[2]),     // Select[2] input
           .A3(s[3]),     // Select[3] input
           .CE(EN),     // Clock enable input
           .CLK(CLK),   // Clock input
           .D(srlin[j][i])        // SRL data input
        );
    end
    if (j>0)  assign  srlin[j] = srlout[j-1];
end
endgenerate



//assign   out = srlout[Nsrl-1];
assign   out = (M>16) ? srlout[s[LML-1:4]] : srlout[0] ;

endmodule
