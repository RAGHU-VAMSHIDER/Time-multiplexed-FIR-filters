`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2023 11:28:13 AM
// Design Name: 
// Module Name: mulfix
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




`define RQWI   ( WI1+WI2 )
`define RQWF   ( WF1+WF2 )

module mulfix  #(parameter WI1=4, WF1=4, WI2=4, WF2=4, WI0=8, WF0=8)( input signed [WI1+WF1-1:0] in1, input signed [WI2+WF2-1:0] in2, output signed [WI0+WF0-1:0] out, output OVF);
generate

wire signed [`RQWI+`RQWF-1:0] temp;




assign temp = in1 * in2;

assign out = {{( WI0 > `RQWI ? WI0-`RQWI+1 : 1 ){temp[`RQWI+`RQWF-1]}},temp[( WI0 > `RQWI ? `RQWI+`RQWF-2  : WI0+`RQWF-2 ):`RQWF],temp[`RQWF-1:( WF0 > `RQWF ? 0 :`RQWF-WF0)],{( WF0 > `RQWF ? WF0-`RQWF : 0 ){1'b0}}};



if ( WI0 >= `RQWI) 
    begin 
    assign OVF=1'b0;
    end 
else  
    begin
    assign OVF = ~((&temp[`RQWI+`RQWF-1:WI0+`RQWF-1])||(~(|temp[`RQWI+`RQWF-1:WI0+`RQWF-1]))) ;
    end
endgenerate

endmodule

