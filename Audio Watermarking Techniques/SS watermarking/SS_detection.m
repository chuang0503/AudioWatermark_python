% Spread spectrum detection
% Load the watermarked file
host_signal = wavread(fullfile(PathName,FileName))';
eval_signal = wavread('wmed_signal')'; 

No = length(host_signal);
N_frame = 4096;   % size of frame
overlap = 0; 
NN = N_frame*(1-overlap);
NB = floor(No/NN);

ifrep = 1;
if ifrep
    repetitive_coding = 3;
    NL = floor(NB/repetitive_coding);
    NB = NL * repetitive_coding;
else
    NL = NB;
end

% Read the watermark
fid = fopen('Wo.dat','r'); 
Wo = fscanf(fid,'%d\n');
fclose(fid);
Wo = Wo';

fid = fopen('PRS.dat','r'); 
rr = fscanf(fid, '%f\n', N_frame);
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Extraction %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Detection');

pointer = 1;
for i = 1 : NB
    frame = eval_signal(pointer:(pointer+N_frame-1))-host_signal(pointer:(pointer+N_frame-1));
    comp = xcorr(frame, rr);
    maxp = find( comp(1,:)==max(abs(comp(1,:))) );
    if comp(1,maxp)>=0
        Wbr(i) = 1;
    else
        Wbr(i) = 0;
    end
    pointer = pointer + NN;
end
 
if ifrep
    count = 1;
    for i = 1 : NL
        temp = (Wbr(count)+Wbr(count+1)+Wbr(count+2))/3;
        if temp>=0.5
            We(i) = 1;
        else
            We(i) = 0;
        end
        count = count + repetitive_coding;
    end
else
    We = Wbr;
end

% ROCLR
BER = sum(abs(We-Wo))/NL*100;
fprintf('BER = %.2f%\n',BER);
fprintf('\n');