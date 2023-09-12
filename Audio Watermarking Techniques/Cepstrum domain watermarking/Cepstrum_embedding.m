% Cesptrum Domain Watermarking ---------- Embedding
Fs = 44100;
Nssnr = 256;  % for segmental SNR
[FileName,PathName] = uigetfile('*.wav','Select the host signal');
host_signal = wavread(fullfile(PathName,FileName))';
N = length(host_signal);
N_frame = 2048;

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

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Embed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Embedding');
% Skipping silence and overlapping
alpha1 = 0.0015;
alpha2 = -0.0015;

wmed_signal = [];
count = 1;        % count the frames embedded
pointer = 1;
prev = zeros(1,N_frame);
for i = 1 : NB
    x = host_signal( pointer : (pointer+N_frame-1) );
    [c,nd] = cceps(x);
    m = mean(c);
    mc = c - m;
    if Wb(count) == 1
        mc = mc + alpha1;
    else
        mc = mc + alpha2;
    end   
    wm_x = icceps(mc,nd);
    wm_x = wm_x .* hann(N_frame)';
    wmed_signal = [wmed_signal,prev(step1+1:N_frame)+wm_x(1:step2),wm_x(step2+1:step1)];
    prev = wm_x;
    count = count + 1;
    pointer = pointer + step1;
end
wmed_signal = [wmed_signal,host_signal(length(wmed_signal)+1:N)];
wavwrite(wmed_signal, Fs, 'wmed_signal.wav');