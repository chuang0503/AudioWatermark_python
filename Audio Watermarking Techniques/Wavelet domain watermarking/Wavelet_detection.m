% Wavelet Domain Watermarking 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Detection');
eval_signal = wavread('wmed_signal')';   

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

wbase = 'db4';  % wavelet_basis
wlevel = 3;      % wavelet level
step = fix(N_frame*(1-overlap));
TH = 0;    % detection threshold
pointer = 1;
We = [];
for i = 1 : NB
    wmed_frame = eval_signal( pointer : (pointer+N_frame-1) );
    % Perform multi-level 1-D wavelet decomposition at level 3 of host_signal using 'db4' or 'haar'. 
    [wmed_C,L] = wavedec(wmed_frame,wlevel,wbase);   
    % get coefficients for approximation at level 3
    cA3 = appcoef(wmed_C,L,wbase,wlevel);    
    thres(i) = sum(cA3);     % The sign is same to 'mean'
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

BER = sum(abs(We-Wo(1:NL)))/NL*100;
fprintf('BER = %.2f%\n',BER);
fprintf('\n');