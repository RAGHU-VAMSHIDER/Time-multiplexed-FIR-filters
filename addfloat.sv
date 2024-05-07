`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2023 06:21:22 PM
// Design Name: 
// Module Name: addfloat
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


//  copied from textbook
function integer cLog2;
    input [31:0] value;
    integer i;
      i = value;
    for (cLog2=0; i>0; cLog2=cLog2+1) i = i >> 1;
endfunction

module addfloat#(parameter WE = 8, WM = 23 ,SAT=1 ) (input op, input [WE+WM:0] in1, input [WE+WM:0] in2, output logic [WE+WM:0] out, output ovf, output uvf);

wire na1,na2; 
assign na1 = (&in1 [WE+WM-1:WM])&(|in1 [WM-1:0]) ;//not a number flag
assign na2 = (&in2 [WE+WM-1:WM])&(|in2 [WM-1:0]) ;//not a number flag


wire signed [WE+1:0] e1;
assign e1 = {{2'b00},in1 [WE+WM-1:WM]} ;
wire signed [WM+1:0] m01;
assign m01 = {{1'b0}, {|e1}, {in1 [WM-1:0]}};

wire signed [WM+1:0] m1;
assign m1 = (in1[WE+WM])? -m01 : m01; // chosing 2's comp of given in1 mantisa   if sign bit of in1  = 1


wire signed [WE+1:0] e2;
assign e2 = {{2'b00},in2 [WE+WM-1:WM]} ;
wire signed [WM+1:0] m02;
assign m02 = {{1'b0}, {|e2}, {in2 [WM-1:0]}};

wire signed [WM+1:0] m2;
assign m2 = (in2[WE+WM])? -m02 : m02;

// chosing 2's comp of given in2 mantisa   if xor (sign bit of in2 , op) 

wire signed [WE+1:0] diffe;
assign diffe = e1-e2;
wire signed [WE+1:0] ndiffe;
assign ndiffe = -diffe;

wire signed [WE+1:0] fe0;
assign fe0 = (diffe[WE+1])? e2 : e1 ;


wire signed [WM+1:0] temp01;
bShifter #( .WL( WM+2 )) bar1 ( .din(m1), .dir(1), .logicalArith(1), .pos(ndiffe[cLog2(WM+1)-1:0]), .dout(temp01)) ;//shifting by diffrence in e using bshift
wire signed [WM+1:0] temp02;
bShifter #( .WL( WM+2 )) bar2 ( .din(m2), .dir(1), .logicalArith(1), .pos(diffe[cLog2(WM+1)-1:0]), .dout(temp02)) ;// shifting by diffrence in e  using bshift

wire signed [WM+1:0] temp1;
assign temp1 = (diffe <= WM+1)?  temp01 : { WM+2{m1[WM+1] }};
wire signed [WM+1:0] temp2;
assign temp2 = (ndiffe <= WM+1)?  temp02 : { WM+2{m2[WM+1] }};

wire signed [WM+1:0] sm1;
wire signed [WM+1:0] sm2;

assign sm1 = (diffe[WE+1])? temp1 : m1 ; // e1<e2 sm1= shifted of in1  (temp1) or m1
assign sm2 = (diffe[WE+1])? m2 : temp2 ;// e1>e2 sm2= shifted of in2  (temp2) or m2

wire signed [WM+2:0] paddout0;
assign paddout0 =  {sm1[WM+1],sm1} + {sm2[WM+1],sm2}; 
wire signed [WM+2:0] naddout0;
assign naddout0 =  {sm1[WM+1],sm1} - {sm2[WM+1],sm2}; 

wire signed [WM+2:0] addout0;
//assign addout0 = {{(WM+2){op}} & naddout0} | {{(WM+2){~op}} & paddout0} ;
assign addout0 = (op)? naddout0 : paddout0;

wire signed [WM+2:0] addout;
assign addout = (addout0[WM+2])? -addout0 : addout0;

wire signed [WE+1:0] fe1;
assign fe1 = fe0 + addout[WM+1];

wire  [WM+2:0] saddout0;
assign  saddout0 = (addout[WM+1]) ? addout >> 1 :  addout ;

wire [cLog2(WM+1)-1:0] posi;

position #( .WL(WM+1) ) pos1 ( .in(saddout0[WM:0]) ,  .pos(posi) );// finding first "1" position to shift and normilazing 

wire  [WM:0] saddout;
bShifter #( .WL( WM+1 )) bar3 ( .din(saddout0[WM:0]), .dir(0), .logicalArith(1), .pos(posi), .dout(saddout)) ;// normilazing using bshift


wire signed [WE+1:0] fe;
assign fe = (|saddout0)? fe1 - posi : 0;

assign  uvf= ~|fe; //uvf = (fe [WE+1] | (~|fe)) ;
assign ovf = fe [WE];
//assign out = { {addout0[WM+2]}, {fe[WE-1:0]} , {saddout[WM-1:0]} };

generate
always @* begin 
    if ( (na1 == 1)|(na2 == 1)  ) begin
        out = {(WE+WM+1){1'b1}};
    end
    else begin 
        if ( uvf == 0 ) begin
            if ( ovf == 0 ) out = { {addout0[WM+2]}, {fe[WE-1:0]} , {saddout[WM-1:0]} };
            else  out = (SAT==0)? { {addout0[WM+2]}, {WE{1'b1}} , {WM{1'b0}} } : { {addout0[WM+2]}, {(WE-1){1'b1}}, {1'b0}, {WM{1'b1}} } ;//if sat=0 +- infinity case or largest number
        end
        else begin
            out  = (SAT==0)? { {addout0[WM+2]}, {WE{1'b0}}, {saddout[WM-1:0]}} : { {addout0[WM+2]}, {(WE-1){1'b0}}, {1'b1}, {WM{1'b0}} } ;//if sat=0  0 case or smalest number
        end
    end
end 
endgenerate

endmodule



module position #(parameter WL = 8) (input [WL-1:0] in, output signed [cLog2(WL):0] pos);
wire [cLog2(WL)-1:0] varb [WL:0];
assign varb[0]=WL-1;
genvar i;
generate
assign pos = (in[WL-1])? 0 : varb[WL-2] ;
for (i = 1 ; i<WL-1 ; i=i+1) begin 
     assign varb[i] = (in[i])? WL-1-i : varb[i-1];
end
endgenerate
  
endmodule


//  copied from textbook
module bShifter #(parameter WL = 8) 
(input signed [WL-1:0] din,
input dir, // direction of shift, 0 to the left and 1 to the right
input logicalArith, //defines logical (0) or arithmetic shift (1) 
input [cLog2(WL)-1:0] pos,
output signed [WL-1:0] dout); // output signal
wire [WL-1:0] d[cLog2(WL)-1:0];//output of intermediate steps
genvar i;
generate
    for (i=0; i<cLog2 (WL); i=i+1) begin
        if (i==0) shStage #(.WL (WL)) STG1 (.din (din), .shift (pos[i]), .dir(dir),. logicalArith (logicalArith),.pos(2**i), .dout (d[i]));
        else shStage #(.WL (WL)) STGi (.din(d[i-1]),.shift (pos[i]),.dir(dir),.logicalArith (logicalArith),.pos(2**i),.dout (d[i]));
    end
endgenerate
assign dout= d[cLog2(WL)-1];
// Ceiling of the log base 2 function, which is required as the number of address bits begin endmodule

endmodule

module shStage #(parameter WL = 8)
(input signed [WL-1:0] din,
input shift, // shift-1 shift and shift=0 no shift 
input dir, // direction of shift, 0 to the left and 1 to the right 
input logicalArith, //defines logical (0) or arithmetic shift (1)
input [cLog2 (WL)-1:0] pos,
output reg signed [WL-1:0] dout); // output signal
always @*
if (~shift) dout = din;
else begin
case ({dir, logicalArith})
2'b00: dout = din << pos;
2'b01: dout = din <<< pos;
2'b10: dout = din >> pos;
default: dout= din >>> pos;
endcase
end
endmodule




