% Echo hiding Watermarking ---------- Detection
disp('Detection for Kernel 2');
eval_signal = wavread('wmed_signal2')';  
NN = length(eval_signal);
N_frame = 4096;
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

% Read key
fid = fopen('key.dat','r');
key = fscanf(fid,'%d\n')';
fclose(fid);

% Echo kernels
% the first digit for key 1
delta11 = 100;
delta10 = 110;
% for key 0
delta01 = 120;
delta00 = 130;

step = fix(N_frame*(1-overlap));

pointer = 1;
for i = 1 : NB
    temp = eval_signal( pointer : (pointer+N_frame-1) );

    % auto-cepstrum 
    c1 = real(ifft(log(fft(temp).^2)));
    if key(i) == 1
        if (c1(delta11+1)-c1(delta11+5)) > (c1(delta10+1)-c1(delta10+5))
            Wbr1(i) = 1;
        else
            Wbr1(i) = 0;
        end
    else
        if (c1(delta01+1)-c1(delta01+5)) > (c1(delta00+1)-c1(delta00+5))
            Wbr1(i) = 1;
        else
            Wbr1(i) = 0;
        end
    end    
    pointer = pointer + step;
end

if ifrep
    count = 1;
    for i = 1 : NL
        temp = sum(Wbr1(count:count+repetitive_coding-1))/repetitive_coding;
        if temp>=0.5
            We1(i) = 1;
        else
            We1(i) = 0;
        end
        count = count + repetitive_coding;
    end
else
    We1 = Wbr1;
end

BER = sum(abs(We1-Wo(1:NL)))/NL*100;
fprintf('BER = %.2f%\n',BER);
fprintf('\n');