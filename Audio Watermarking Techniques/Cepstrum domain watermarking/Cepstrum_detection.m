% Cesptrum Domain Watermarking ------- Detection
disp('Detection');

eval_signal = wavread('wmed_signal')';  % 
NN = length(eval_signal);
N_frame = 2048;
overlap = 1/2;
NB = fix((NN-N_frame*overlap)/(N_frame*(1-overlap)));

ifrep = 1;
if ifrep
    repetitive_coding = 3;
    NL = floor(NB/repetitive_coding);
    NB = NL * repetitive_coding;
else
    NL = NB;
end

% Read watermark
fid = fopen('Wo.dat','r');
Wo = fscanf(fid,'%d\n');
fclose(fid);
Wo = Wo';

step = fix(N_frame*(1-overlap));
TH = 2.5;    % detection threshold 3.8 for 0.001 and nr=5
pointer = 1;
We = [];
for i = 1 : NB
    wmed_x = eval_signal( pointer : (pointer+N_frame-1) );
    [wmed_c,nd] = cceps(wmed_x);
    thres(i) = sum(wmed_c);     
    if thres(i) > TH
        Wbr(i) = 1;
    else
        Wbr(i) = 0;
    end
    pointer = pointer + step;
end

if ifrep
    count = 1;
    for i = 1 : NL
        temp = sum(Wbr(count:count+repetitive_coding-1))/repetitive_coding;
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
BER = sum(abs(We-Wo(1:NL)))/NL*100;
fprintf('BER = %.2f%\n',BER);
fprintf('\n');