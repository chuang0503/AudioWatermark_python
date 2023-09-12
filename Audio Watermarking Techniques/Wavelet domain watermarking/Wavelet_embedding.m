% Wavelet Domain Watermarking ---------- Embedding
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
Wo = randi(1,[1, NL]);
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
wbase = 'db4';   % wavelet_basis
wlevel = 3;       % wavelet level
alpha = 0.01;

wmed_signal = [];
count = 1;        % count the frames embedded
pointer = 1;
prev = zeros(1,N_frame);
for i = 1 : NB
    frame = host_signal( pointer : (pointer+N_frame-1) );
    % Perform multi-level 1-D wavelet decomposition at level 3
    [C,L] = wavedec(frame,wlevel,wbase);
    % Compute the approximation and detail coefficients from decomposition
    cA3 = appcoef(C,L,wbase,wlevel);    % coefficients for approximation at level 3
    cD3 = detcoef(C,L,3);               % coefficients for details at level 3
    cD2 = detcoef(C,L,2);               % coefficients for details at level 2
    cD1 = detcoef(C,L,1);               % coefficients for details at level 1
    % According to watermark bits, modify cA3
    if Wb(count) == 1
        cA3 = cA3 - mean(cA3) + alpha;
    else
        cA3 = cA3 - mean(cA3) - alpha;
    end
    % Reconstruct
    Cm = [cA3,cD3,cD2,cD1];
    wm_frame = waverec(Cm,L,wbase);
    wm_frame = wm_frame .* hann(N_frame)';  
    wmed_signal = [wmed_signal,prev(step1+1:N_frame)+wm_frame(1:step2),wm_frame(step2+1:step1)];
    prev = wm_frame;
    count = count + 1;
    pointer = pointer + step1;
end
wmed_signal = [wmed_signal,host_signal(length(wmed_signal)+1:N)];
wavwrite(wmed_signal, Fs, 'wmed_signal.wav');