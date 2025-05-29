clear
clc
close all

mathRules = fimath('OverflowAction', 'Wrap', ...
                   'RoundingMethod', 'Floor');

load('Neural_Signal_Sample.mat')
h_char =['d7ac' 'e464' 'ae68' '5198' '1b9c' '2854'];
h_char = reshape(h_char, 4,[])';
h = hex2fi(h_char,  16, 15, 1)';

x=neural_signal;

x_fi= fi(neural_signal, 1, 12, 10,mathRules);

filout =filter(h,1,x_fi)';

x_fi1= [zeros(5,1) ;x_fi];
for i = 1: (max(size(x_fi1))-5)
    fout(i)=flip(h)'*x_fi1(i:i+5);
end

conout = conv(h,x_fi');


figure();

subplot(3,1,1);
plot (filout,"b")
hold on ;
plot (x,"r")
hold on ;
plot (fout,"g")
hold on ;
plot(conout(1:numel(x_fi)))
title('Input signal VS filtered output' );

subplot(3,1,2);
plot (filout-fout)
title('filter function vs  matrix multiplication h-(filter coff) and x-(input) in for loop');

subplot(3,1,3);
plot(filout-conout(1:numel(x_fi)))
title('filter function vs conv function ');

%%
cd C:\Users\rgankidi4464\Desktop\
cd memfile
%fid2=fopen("firwrite.txt","r");
fid2=fopen("nxmfirwrite.txt","r");

hex_digits= fscanf(fid2,"%s\n");
fclose(fid2);
cd C:\Users\rgankidi4464\Desktop\'Home Work'\system\

hex_digits = reshape(hex_digits, 3,[])';

vlogout = [];
vlogout = [vlogout hex2fi(hex_digits, 12, 10, 1)]; %%%%%%%%%%%%%%%%%%%%5%made change in hex2fi.m
vlogout = reshape(vlogout, 2,[])';



fout =fi(fout, 1, 12, 10,mathRules) ;% redusing to WL=12, WF=10 form

figure();
subplot(3,1,1);
plot (x_fi,"r")
hold on ;
plot (vlogout(:,1)',"b")
hold on ;
plot (vlogout(:,2)',"g")
title('Input signal VS Verilog-testbench');

subplot(3,1,2);
plot (fout-vlogout(:,1)')
title('Error between Matlab fixed-point approximated to WL=12,WF=10 VS Verilog-testbench using DFF');
subplot(3,1,3);
plot (fout-vlogout(:,2)')
title('Error between Matlab fixed-point approximated to WL=12,WF=10 VS Verilog-testbench using SRL16');

%%
figure();
subplot(2,1,1);
plot (filout-vlogout(:,1)')
subplot(2,1,2);
plot (filout-vlogout(:,2)')
