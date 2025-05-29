clear
close all

SIGNED = 1;
mathRules = fimath('OverflowAction', 'Wrap', ...
                   'RoundingMethod', 'Floor');

%%
port_list = instrfindall;
    if(~isempty(port_list))
        fclose(port_list) 
    end



 load('Neural_Signal_Sample.mat')

x_fi = fi(neural_signal', SIGNED, 32, 10,mathRules);

LOOP_INPUTS = numel(x_fi);% total lenght 
looplim = 512;% elemets in loop limit to 512
 loopleft=LOOP_INPUTS; % left over elements to send
 varloop=0; % vareable 
 var=0;
 minized_output1 = [];


%Find open serial ports and close them
while (loopleft>0)
     if (loopleft > looplim ) % varloop = min (looplim, loopleft)
         varloop = looplim ;
     else 
         varloop=loopleft;
     end
	loopleft=loopleft-looplim;

    

    %Define the serial port of the minized device
    device = serial('COM4', 'BaudRate', 115200, 'InputBufferSize', 65536);
    %device = serial('COM4', 'BaudRate', 115200);
    
    
    %Make the values char array
    
    expected_bytes = varloop * 8;
    
    data_in = [];
    data_in = [x_fi(1+var:varloop+var) zeros(1, looplim - varloop)]; 
    %filling gap to make multiple of 512 elements 
    
    %Convert them to character vectors
    data_char = [];
    data_char = vec2char(data_in);
    % input sent is sign extended to 32 bit filling extra 16 bits with sign
    % where module only takes first 16 bits
    
    %Open the device
    fopen(device);
    
    %Send the data to the device
    writechar2device(device, data_char);
    
    %
    %Check if there are bytes available in the read buffer
    while(device.BytesAvailable < expected_bytes)
    end
    %bytesAvail = device.BytesAvailable;
    
    
    %Read the data as chars
    hex_digits = char(fread(device, expected_bytes))';
    %hex_digits = char(fread(device, bytesAvail))';
    %Here we simply reshape into 8xnumel(data_in) and then transpose it so that
    %we end up at numel(data_in) number of rows and  m  m
    %hex_digits = reshape(hex_digits, [8,numel(data_in)])';%%%%%%%%%%%%%%made change in hex2fi.m
    %hex_digits = reshape(hex_digits, 8,[])';
    hex_digits = reshape(hex_digits, [8,varloop])';
    N = size(hex_digits, 1);
    fiValues1 = fi(zeros(1, N), SIGNED, 12, 10);
    
    
    for k = 1 : N
		bin_str = dec2bin(hex2dec(hex_digits(k, :)), 32);
         
        bin_str1 = bin_str(end-(12)+1:end);
        bin_str2 = bin_str(end-2*(12)+1:end-(12));
        
        temp_fi1 = fiValues1(k);
        temp_fi1.bin = bin_str1;
        fiValues1(k) = temp_fi1;
        
        
        
    end
    
    
    %%Converting the hex digits to a value
    %%minized_output = [minized_output hex2fi(hex_digits, 32, 14, 1)];
    minized_output1 = [minized_output1  fiValues1];% fir using DFF
    
      

    var = var+ varloop; % count variable 
    
    port_list = instrfindall;
    if(~isempty(port_list))
        fclose(port_list) 
    end
end

%%


load('Neural_Signal_Sample.mat')
h_char =['d7ac' 'e464' 'ae68' '5198' '1b9c' '2854'];
h_char = reshape(h_char, 4,[])';
h = hex2fi(h_char,  16, 15, 1)';%%%%%%%%%%%%%%made change in hex2fi.m

x_fi= fi(neural_signal, 1, 12, 10,mathRules);


fout =fi(zeros (1,max(size(x_fi))), 1, 12, 10,mathRules) ;
x_fi1= [zeros(5,1) ;x_fi];
for i = 1: (max(size(x_fi1))-5)
    fout(i)=flip(h)'*x_fi1(i:i+5);
end


figure();

subplot(2,1,1);
plot (x_fi)
hold on ;
plot (minized_output1,"k")

hold on ;
plot (fout,"g")
title('Matlab fixed-point approximated to WL=12,WF=10 VS Minizedoutput using DFF VS Minizedoutput using SRL16');

subplot(2,1,2);
plot (minized_output1-fout,"b")
title('Error between Matlab fixed-point approximated to WL=12,WF=10 VS Minizedoutput using DFF');



