`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2023 09:11:46 PM
// Design Name: 
// Module Name: nxmfir
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




module nxmfir #(parameter N=2, M=3 , winI=2, winF=10, wcofi=1, wcoff=15, woutI=2, woutF=10, LML = 4, Nsrl =1 )(input NCLK, RST, EN, start, input [winI+winF-1:0] in, output [woutI+woutF-1:0] out);
//N means no of taps present  in one clock-cycle
//M is no of clock-cyckes needed
//N x M = total number of tap
//LML= lenght of address(count)
//Nsrl= no of srl16 needed
wire CLK;
assign CLK = NCLK;

genvar i,j;

reg signed [wcofi+wcoff-1:0] H [0:N-1];
reg [wcofi+wcoff-1:0] ROM [0: N*M - 1]; 
initial begin $readmemb("C:/Users/rgankidi4464/Desktop/memfile/tap64.txt", ROM); 

 ROM[0] = 16'hd7ac;//h_char =['d7ac' 'e464' 'ae68' '5198' '1b9c' '2854'];
 ROM[1] = 16'he464;
 ROM[2] = 16'hae68;
 ROM[3] = 16'h5198;
 ROM[4] = 16'h1b9c;
 ROM[5] = 16'h2854;

end


wire [wcofi+wcoff-1:0] subROM [0: M-1][0:N - 1];

generate
for (i =0; i<N; i=i+1) begin: brm
    for (j=0; j<M ; j=j+1) begin : sub
        assign subROM [j][i]= ROM [j+i*M];
    end
always @(posedge CLK) begin
	if(RST) H[i] <= 0;
	//else memOut <= H [address];
	else H[i] <= subROM [count][i];
end
end
endgenerate

reg [LML-1:0] count;

always @ (posedge ~CLK) begin
    if (RST|start) begin
        count <= 0;
    end
    else begin
        if (EN &(~start) ) begin//& (~start)
            count <= count + 1;
        end
        else begin
            count <= count;
        end
    end
end

wire [winI+winF-1:0] in_d [N-1:0];
wire [winI+winF-1:0] inw [N-1:0];
assign inw[0]= in ;

wire signed [winI+wcofi+winF+wcoff-1:0] mulout [N-1:0] ;
wire signed [winI+wcofi+winF+wcoff+N-2:0] addout [N-1:0] ;

localparam  WM= winI+wcofi+winF+wcoff-1;

assign addout[0] = { {(N-1){mulout[0][WM]}} ,mulout[0]};

wire [LML-1:0] addres;  
assign addres = ( ~(start | EN))? M-1 : count;

//genvar i;
generate
    for (i=0;i<N;i=i+1) begin: tap
        
        delayline #( M, winI+winF , LML, Nsrl) Sinst1 ( CLK, start, (start | ~(start | EN))? M-1 : count, inw[i], in_d [i] );//(start)? M-1 ://(start | ~(start | EN))? M-1 :
        //ROM #(wcofi+wcoff, LML, (N*M) ) r1 ( CLK, RST,count+i*M , H[i] ); 
        mulfix  #( winI, winF, wcofi, wcoff, winI+wcofi, winF+wcoff) mul0 ( in_d[i], (start | ~(start | EN)) ? 0 :H[i], mulout[i] , OVF);//H[count+i*M]
        
        if (i>0) begin
            assign inw[i] = in_d [i-1];
            addfix  #( winI+wcofi, winF+wcoff, winI+wcofi+N-1, winF+wcoff, winI+wcofi+N-1, winF+wcoff) add111 (mulout[i], addout[i-1], addout[i], OVF);
        end
    end
endgenerate


wire signed [winI+wcofi+winF+wcoff+N-1+M-1-1:0] Aout;
reg signed [winI+wcofi+winF+wcoff+N-1+M-1-1:0] QAout;

addfix  #( winI+wcofi+N-1,winF+wcoff, winI+wcofi+N-1+M-1, winF+wcoff, winI+wcofi+N-1+M-1, winF+wcoff) add111 ((start) ? 0 : addout [N-1], QAout, Aout, OVF);

always @ (posedge ~CLK) begin
    if (RST|start) begin
        QAout <= 0;
    end
    else begin
        if (EN & (~start)) begin
            QAout <= Aout;
        end
        else begin
            QAout <= QAout;
        end
    end
end

assign out = { QAout[winI+wcofi+winF+wcoff+N-1+M-1-1], QAout[winF+wcoff-2+woutI:winF+wcoff-woutF]};

endmodule



/*module ROM #(parameter WL=16, AWL=4, N=3,M=2) (input CLK, RST,input [AWL-1:0] address, output reg [WL-1:0] memOut [N-1:0]); 
reg [WL-1:0] ROM [0: N*M - 1]; 
initial $readmemb("C:/Users/rgankidi4464/Desktop/memfile/tap64.txt", ROM); 
//wire signed [WL-1:0] H [0: DEPTH - 1];

//assign H[0] = 16'hd7ac;//h_char =['d7ac' 'e464' 'ae68' '5198' '1b9c' '2854'];//count+i*M ~=H[i]
//assign H[1] = 16'he464;
//assign H[2] = 16'hae68;
//assign H[3] = 16'h5198;
//assign H[4] = 16'h1b9c;
//assign H[5] = 16'h2854;
genvar i;
generate
for (i =0; i<N; i=i+1) begin 
always @(posedge CLK) begin

	if(RST) memOut[i] <= 0;
	//else memOut <= H [address];
	else memOut[i] <= ROM [address+i*M];
end
end
endgenerate
endmodule*/

