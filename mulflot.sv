`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2023 11:57:19 PM
// Design Name: 
// Module Name: flot
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

module mulflot #(parameter WE = 8, WM = 23 ,SAT=0 ) (input [WE+WM:0] in1, input [WE+WM:0] in2, output logic [WE+WM:0] out, output ovf, output uvf);

wire na1,na2; 
assign na1 = (&in1 [WE+WM-1:WM])&(|in1 [WM-1:0]) ;//not a number flag
assign na2 = (&in2 [WE+WM-1:WM])&(|in2 [WM-1:0]) ;//not a number flag

wire signed [WE+1:0] e1;
assign e1 = {{2'b00},in1 [WE+WM-1:WM]} ;
wire [WM:0] m1;
assign m1 = {{|e1}, {in1 [WM-1:0]}};

wire signed [WE+1:0] e2;
assign e2 = {{2'b00},in2 [WE+WM-1:WM]} ;
wire [WM:0] m2;
assign m2 = {{|e2}, {in2 [WM-1:0]}};

wire [(2*WM)+1:0] mulout0;
assign mulout0 = m1 * m2 ;
wire  [(2*WM)+1:0] mulout;

assign  mulout = (mulout0[2*WM+1]) ? mulout0 >> 1 :  mulout0 ;



wire signed [WE+1:0] sume;
assign sume = e1+e2+{{3'b111},{(WE-2){1'b0}},1'b1}+mulout0[2*WM+1]; // e1+e2+(-bias)

assign uvf = (sume [WE+1] | (~|sume)) ;
assign ovf = sume [WE];

wire signed [WE+1:0] nsume;
assign nsume = -sume; 
wire  [(2*WM)+1:0] smulout;
wire  [(2*WM)+1:0] temp;



bShifter #( .WL( 2*WM+2 )) bar ( .din(mulout), .dir(1), .logicalArith(0), .pos(nsume[cLog2(2*WM+2)-1:0]+1), .dout(temp)) ;
assign smulout = (nsume <= WM+2) ? temp : 0;

generate
always @* begin 
    if ( (na1 == 1)|(na2 == 1)  ) begin
        out = {(WE+WM+1){1'b1}};
    end
    else begin 
        if ( uvf == 0 ) begin
            if ( ovf == 0 ) out = { {in1[WE+WM]^in2[WE+WM]}, {sume[WE-1:0]} , {mulout[2*WM-1:WM]} };
            else out = (SAT==0)? { {in1[WE+WM]^in2[WE+WM]}, {WE{1'b1}} , {WM{1'b0}} } : { {in1[WE+WM]^in2[WE+WM]}, {(WE-1){1'b1}}, {1'b0}, {WM{1'b1}} } ;//if sat=0 +- infinity case or largest number
        end
        else begin
            out  = (SAT==0)? { {in1[WE+WM]^in2[WE+WM]}, {WE{1'b0}}, {smulout[2*WM-1:WM]}} : { {in1[WE+WM]^in2[WE+WM]}, {(WE-1){1'b0}}, {1'b1}, {WM{1'b0}} } ;//if sat=0  0 case or smalest number
        end
    end
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
