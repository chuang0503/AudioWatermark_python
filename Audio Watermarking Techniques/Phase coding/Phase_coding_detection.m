function Phase_coding_detection(spoint)
% Load the watermarked file
eval_signal = wavread('wmed_signal')'; 

N_frame = 2048;   % size of frame
N2 = N_frame/2 ;  % half of N_frame

freq_slot = 64;
len_Wo = N2/freq_slot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Extraction %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Detection');
first_frame = eval_signal(spoint:N_frame+spoint-1);
dphase = angle( fft(first_frame) ); 
for i = 1 : len_Wo
    if dphase(i*freq_slot) >= 0
        We(i) = 1;
    else
        We(i) = 0;
    end
end

% Read the watermark
fid = fopen('Wo.dat','r'); % Make sure to embed the same watermark every time. 
Wo = fscanf(fid,'%d\n');
fclose(fid);
Wo = Wo';

% ROCBR
BER =  sum(abs(We-Wo))/len_Wo*100;
fprintf('BER = %.2f%\n',BER);
fprintf('\n');