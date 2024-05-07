`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2023 11:28:22 PM
// Design Name: 
// Module Name: addfix
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

`define RQWI   ( WI1 > WI2 ? (WI1+1) : (WI2+1) )
`define RQWF   ( WF1 > WF2 ? (WF1) : (WF2) )
module addfix  #(parameter WI1=2, WF1=2, WI2=2, WF2=2, WI0=4, WF0=4)( input signed [WI1+WF1-1:0] in1, input signed [WI2+WF2-1:0] in2, output signed [WI0+WF0-1:0] out, output OVF);
generate
wire [`RQWI+`RQWF-1:0] a;
wire [`RQWI+`RQWF-1:0] b;
wire [`RQWI+`RQWF-1:0] temp;


assign a ={{(`RQWI-WI1){in1[WI1+WF1-1]}},in1 ,{(`RQWF-WF1){1'b0}}};
assign b ={{(`RQWI-WI2){in2[WI2+WF2-1]}},in2 ,{(`RQWF-WF2){1'b0}}};

assign temp = a + b;

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
