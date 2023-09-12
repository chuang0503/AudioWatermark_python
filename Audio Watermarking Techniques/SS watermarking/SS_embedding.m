% Spread spectrum
% Load the host file
global FileName;
global PathName;
[FileName,PathName] = uigetfile('*.wav','Select the host signal');
host_signal = wavread(fullfile(PathName,FileName))';
No = length(host_signal);

N_frame = 4096;   % size of frame

r = rand(1, N_frame) - 0.5;  % for bit 1
fid = fopen('PRS.dat','w');
fprintf(fid,'%f\n',r);
fclose(fid);

c = 0.03;  % control strength

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
fid = fopen('Wb.dat','w');
fprintf(fid,'%d\n',Wb);
fclose(fid);    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Embedding %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Embedding');

pointer = 1;
wmed_signal = [];    % the watermarked signal

wmed_signal = [];
for i = 1 : NB
    frame = host_signal( pointer : (pointer+N_frame-1) );
    alpha = c*max(abs(frame));
    if Wb(i)==1
        frame = alpha*r + frame;
    else
        frame = - alpha*r + frame;
    end
    wmed_signal = [wmed_signal,frame(1:NN)];
    pointer = pointer + NN;
end
wmed_signal = [wmed_signal,host_signal(length(wmed_signal)+1:No)];
wavwrite(wmed_signal,44100,'wmed_signal');
