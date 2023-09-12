% Echo hiding Watermarking ---------- Embedding
Fs = 44100;
[FileName,PathName] = uigetfile('*.wav','Select the host signal');
host_signal = wavread(fullfile(PathName,FileName))';
N = length(host_signal);
N_frame = 4096;

overlap = 1/2;
step1 = N_frame*(1-overlap);
step2 = N_frame*overlap;
NB = fix((N-N_frame*overlap)/step1);

ifrep = 1;
if ifrep
    repetitive_coding = 3;
    NL = floor(NB/repetitive_coding);
    NB = NL * repetitive_coding;
else
    NL = NB;
end

% Generate the original watermark
Wo = randi(1, [1,NL]);
fid = fopen('Wo.dat','w');
fprintf(fid,'%d\n',Wo);
fclose(fid);
fid = fopen('Wo.dat','r'); 
Wo = fscanf(fid,'%d\n');
fclose(fid);
Wo = Wo';

% Generate the embedded watermark
if ifrep
    Wb = [];
    for i = 1 : NL
        for j = 1 : repetitive_coding
            Wb = [Wb,Wo(i)];
        end
    end
else
    Wb = Wo;
end

% Generate PN sequences as key
keyL = randi(1,[1,NL]);

if ifrep
    key = [];
    for i = 1 : NL
        for j = 1 : repetitive_coding
            key = [key, keyL(i)];
        end
    end
else
    key = keyL;
end
fid = fopen('key.dat','w');
fprintf(fid,'%d\n',key);
fclose(fid);

% Echo kernels
% the first digit for key 1
delta11 = 100;
delta10 = 110;
% for key 0
delta01 = 120;
delta00 = 130;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Embed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Embedding');
% Skipping silence and overlapping
alpha = 0.2;
pointer = 1;
wmed_signal1 = [];
wmed_signal2 = [];
wmed_signal3 = [];
prev1 = zeros(1,N_frame);
prev2 = zeros(1,N_frame);
prev3 = zeros(1,N_frame);

de = 4; % for negative echo

for i = 1 : NB
    temp = host_signal( pointer : (pointer+N_frame-1) );
    if key(i) == 1
        if Wb(i) == 1
            delta = delta11;
        else
            delta = delta10;
        end
    else
        if Wb(i) == 1
            delta = delta01;
        else
            delta = delta00;
        end
    end
   
    echop = alpha * [zeros(1,delta),temp(1:N_frame-delta)];
    echon = - alpha * [zeros(1,delta+de),temp(1:N_frame-delta-de)];
    echof = alpha * [temp(delta+1:end), zeros(1,delta)]; % forward echo

    % positive single
    echoed_frame1 = temp + echop;
    % positive + negative
    echoed_frame2 = temp + echop + echon;  
    % backward + forward
    echoed_frame3 = temp + echop + echof;
    
    echoed_frame1 = echoed_frame1(1:N_frame).* hann(N_frame)';
    wmed_signal1 = [wmed_signal1,prev1(step1+1:N_frame)+echoed_frame1(1:step2),echoed_frame1(step2+1:step1)];
    prev1 = echoed_frame1;
    
    echoed_frame2 = echoed_frame2(1:N_frame).* hann(N_frame)';
    wmed_signal2 = [wmed_signal2,prev2(step1+1:N_frame)+echoed_frame2(1:step2),echoed_frame2(step2+1:step1)];
    prev2 = echoed_frame2;
    
    echoed_frame3 = echoed_frame3(1:N_frame).* hann(N_frame)';
    wmed_signal3 = [wmed_signal3,prev3(step1+1:N_frame)+echoed_frame3(1:step2),echoed_frame3(step2+1:step1)];
    prev3 = echoed_frame3;
    
    pointer = pointer + step1;
end
wmed_signal1 = [wmed_signal1,host_signal(length(wmed_signal1)+1:N)];
wavwrite(wmed_signal1, Fs, 'wmed_signal1.wav');

wmed_signal2 = [wmed_signal2,host_signal(length(wmed_signal2)+1:N)];
wavwrite(wmed_signal2, Fs, 'wmed_signal2.wav');

wmed_signal3 = [wmed_signal3,host_signal(length(wmed_signal3)+1:N)];
wavwrite(wmed_signal3, Fs, 'wmed_signal3.wav');