`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2023 02:47:14 AM
// Design Name: 
// Module Name: testfir
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



module testfir();

reg signed [11:0] matin [0:3999];
reg signed [31:0] matin1 [0:7][0:7];

initial $readmemb("C:/Users/rgankidi4464/Desktop/memfile/tap64.txt",matin1);

reg CLK, RST, EN, start;
reg signed [11:0] in; 
reg write_EN;

wire signed [11:0] out1;
wire signed [11:0] out2;

//reg signed [11:0] out;// for d buging 

localparam N = 3;
localparam M = 2;
localparam LML = ($clog2(M/16 + ( (M % 16)? 1 : 0))) + 4;
localparam Nsrl = M/16 + ( (M % 16)? 1 : 0);

nxmfir #(3, 2, 2, 10, 1, 15, 2, 10,   LML , Nsrl ) f1 (CLK, RST, EN, start, in , out1);// N=3, M=2(M= cycles) (taps=NXM =6)

nxmfir #(2, 3, 2, 10, 1, 15, 2, 10,   LML , Nsrl ) f2 (CLK, RST, EN, start, in , out2);// N=2, M=3(M= cycles) (taps=NXM=6)
 wire [3:0] count;
 assign count = f1.count;
 
  wire signed [3:0] s0;
 assign s0=f1.tap[0].Sinst1.s;
 wire signed [15:0] h0; 
 assign h0=f1.tap[0].mul0.in2;
 wire signed [11:0] DLout0; 
 assign DLout0=f1.tap[0].Sinst1.out;
 wire signed [3:0] s1; 
 assign s1=f1.tap[1].Sinst1.s;
 wire signed [15:0] h1; 
 assign h1=f1.tap[1].mul0.in2;
  wire signed [11:0] DLout1; 
 assign DLout1=f1.tap[1].Sinst1.out;
  wire signed [3:0] s2; 
 assign s2=f1.tap[2].Sinst1.s;
 wire signed [15:0] h2; 
 assign h2=f1.tap[2].mul0.in2;
  wire signed [11:0] DLout2; 
 assign DLout2=f1.tap[2].Sinst1.out;
 
initial CLK = 0;
always #5 CLK=~CLK;

integer i;
integer fileID;

initial begin

write_EN=0;
RST =1;
EN =0;
start=0;
in=0;
#10;
start=1;
RST =0;
#10;
start=0;
EN =1;
#5;
$readmemb("C:/Users/rgankidi4464/Desktop/memfile/Neural_Signal_Sample.txt",matin);
fileID = $fopen("C:/Users/rgankidi4464/Desktop/memfile/nxmfirwrite.txt", "w");
EN =1;
//#5;
#90;
//#2;
for (i=0; i<4000; i=i+1) begin
        
        //RST =1;
        EN =0;
        
        start=0;//start act as reset in fir2 which is time multiplexing mac unit
        
        #9;
        in <= matin[i];//input
        #1;
        start=1;
        EN =1;
        RST =0;
        #10;
        start=0;
        EN =1;
        
        #19;// Wait for some simulation time 6 clocks
        write_EN=1;
        $fwrite(fileID,"%h",out1);
        #10;
        $fwrite(fileID,"%h\n",out2);
        #1;
        write_EN=0;
        //out=out1;
        
       
       
end
$fclose(fileID);


#90;
 $finish;

end 

endmodule
