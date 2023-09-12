% Embedding the watermark in the host signal
close;
clear;
clc;

global filename;
global pathname;

tic;

Parameter_embedding;

fprintf('***********************************************************\n');
fprintf('******************** Embedding starts! ********************\n');
fprintf('***********************************************************\n\n');

% Load the embedding watermark and divide into Bsub for each pattern block
fid = fopen('Wb.dat','r');
Wb = fscanf(fid,'%d\n')';
fclose(fid);

count = 1;
for i = 1 : N_block           % the number of pattern blocks
    for j = 1 : N_bit         % four bits per pattern block
        if Wb(count) < 1
            Wb(count) = -1;   % mapping 0 to -1
        end
        Bsub(i,j) = Wb(count);
        count = count + 1;
    end
end

% Specify the slots for embedding each watermark bit and sync bit, and their PNs 
% for creating bit matrix and pseudorandom matrix later
Positions = randperm(N_tiles);
fid = fopen('Positions.dat','w');                  
fprintf(fid,'%d\n',Positions);
fclose(fid);

PNs = randsrc(1,N_tiles); 
fid = fopen('PNs.dat','w');
fprintf(fid,'%d\n',PNs);
fclose(fid);

fid = fopen('GTF5.dat','r');                  
tmp_subbands = fscanf(fid,'%d\n');
fclose(fid);

% Select N_s out of Ng subbands and further randomise the order of embedding
GTF_index = randperm(N_G);

for i = 1 : N_s
    subbands(2*i-1) = tmp_subbands(2*GTF_index(i)-1);
    subbands(2*i)   = tmp_subbands(2*GTF_index(i));
end

fid = fopen('subbands.dat','w');                  
fprintf(fid,'%d\n',subbands);
fclose(fid);

% % For comparison, read Positions.dat, PNs.dat, subbands.dat directly
% fid = fopen('Positions.dat','r');                  
% Positions = fscanf(fid,'%d\n');
% fclose(fid);
% 
% fid = fopen('PNs.dat','r');                  
% PNs = fscanf(fid,'%d\n');
% fclose(fid);
% 
% fid = fopen('subbands.dat','r');                  
% subbands = fscanf(fid,'%d\n');
% fclose(fid);


% Read the host signal 
[filename,pathname] = uigetfile('*.wav','Select the host signal that you just chose.');  % The host signal
host_signal = wavread(fullfile(pathname,filename))';
halfsize = N_frame/2;
b_th = 1;                         % for counting Bsub
for n = 1 : length(Nb_period)
    index = 1;                    % for denoting the first frame
    flag  = 1;
    i = 1;                        % for counting the frame
    j = 0;                        % for counting the tile
    k = 1;                        % for counting the pattern block
    prev_wm = zeros(1,N_frame);   % The previous frame of watermark signal in the time domain
    m = period(n,1);              % The starting point of each period
    if n == 1
        if m ~= 1
            wmed_signal(1:m-1) = host_signal(1:m-1);
        end
    else
        wmed_signal = [wmed_signal, host_signal(length(wmed_signal)+1:m)];
    end
    % Array multiplication between bit matrix and pseudorandom matrix 
    MA = Bit_pseudorandom_matrix(Bsub(b_th,:),Positions,PNs);  % MA = MB.*MPR
    while flag == 1
        % Process the host signal frame by frame
        if index == 1                                          % the first frame
            temp = host_signal(m:m+N_frame-1);
            index = 0;
            frame = temp; 
        else                                                   % half overlapped frame
            temp = host_signal(m+halfsize:m+N_frame-1);
            if length(temp) == 0
                disp('Finish!');
                break;
            end
            if length(temp) ~= halfsize
                flag = 0;
                disp('Sample are insufficient and zeros will be padded!');
                temp = [temp, zeros(1,halfsize-length(temp))];
            end
            for count = 1 : halfsize
                frame(count) = frame(halfsize + count);
                frame(count + halfsize) = temp(count);
            end
        end  
        % Watermark each frame
        % (1) Magnitude -- from Psychoacoustic model I 
        % frequency masking
        magnitude = Psychoacoustic_model_I(frame,Fs);
        % temporal masking (ongoing...)
        % Temporal masking effects can be approximated by the envelope of the host audio. 
        % The envelope is modeled as a decaying exponential. 
    
        % (2) Phase -- from FFT analysis
        phase = FFT_phase(frame);
        
        % (3) Sign -- from MA and Ct 
        Ct = [+1 +1 -1 -1];                                        % Modulus operator
        sign = Sign_expander(MA(:,j+1), Ct(i), subbands);     
      
        % Construct the watermark signal in the frequency domain
        Fr_l = sign .* magnitude .* cos( phase(1:N_frame/2) );     % half of real part 
        Fi_l = sign .* magnitude .* sin( phase(1:N_frame/2) );     % half of imaginary part 
        Fr_h =   [0, Fr_l(N_frame/2 : -1 : 2)];                    % Conjugation symmetry       
        Fi_h = - [0, Fi_l(N_frame/2 : -1 : 2)];
        Fr = [Fr_l, Fr_h];                                       
        Fi = [Fi_l, Fi_h];
        wm_frequency = complex(Fr,Fi); 
        
        % Transfer to time domain
        wm_time = real(ifft(wm_frequency)); 
        
        % Windowing for smooth concatenation
        wm_time = wm_time.* hanning(N_frame)';
        
        % Concatenation
        wmed_signal(m:m+halfsize-1) = frame(1:halfsize) + prev_wm((halfsize+1):N_frame) + wm_time(1:halfsize);
        
        % Prepare for next frame
        prev_wm = wm_time; 
        
        % Index pointer
        m = m + halfsize;   
    
        % Per unit
        if i >= N_bit        
            i = 0;
            j = j+1; 
        end
        i = i+1; 
    
        % Per pattern block
        if j >= N_u
            fprintf('The %dth pattern block has finished. \n', k);
            j = 0;
            k = k+1;
            if k > Nb_period(n)
                fprintf('****** The %dth period has finished. ******\n\n', n);
                wmed_signal = [wmed_signal, frame(halfsize+1:N_frame) ];    
                break;
            else
                MA = Bit_pseudorandom_matrix( Bsub((b_th+k-1),:), Positions, PNs );
            end
        end 
    end
    b_th = b_th + Nb_period(n);
end
wmed_signal = [wmed_signal, host_signal(m+halfsize:length(host_signal))];
% Write as .wav file
wavwrite(wmed_signal,Fs,'wmed_signal.wav'); 
fprintf('Embedding has finished.\n');

toc;