% Phase coding
function spoint = Phase_coding_embedding
% Load the host file
[FileName,PathName] = uigetfile('*.wav','Select the host signal');
host_signal = wavread(fullfile(PathName,FileName))';
N = length(host_signal);

N_frame = 2048;   % size of frame
N2 = N_frame/2 ;  % half of N_frame

% Generate the watermark
freq_slot = 64;
len_Wo = N2/freq_slot;

Wo = randi(1,[1,len_Wo]);
fid = fopen('Wo.dat','w');
fprintf(fid,'%d\n',Wo);
fclose(fid);

% Check the first frame, not absolute silence
spoint = 1;
while (spoint+N_frame-1)  <= N
    temp = host_signal( spoint : spoint+N_frame/32-1);
    if sum(temp.^2) > 1e-3
        break;
    else
        spoint = spoint + N_frame/32;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Embedding %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Embedding');

% STEP 1: Partition the host signal into N_seg segments, each with N_frame points
N_seg = fix((N-spoint)/N_frame);
pointer = spoint;
wmed_signal = [];    % the watermarked signal

for i = 1 : N_seg
%     fprintf('%d th frame\n',i);
    frame = host_signal( pointer : (pointer+N_frame-1) );
                
    % STEP 2: Calculate magnitude matrix A and phase matrix ?(Phai)
     amplitude = abs( fft(frame) );     % magnitude
     
    % STEP 3: Calculate phase difference matrix ?? (delta_Phai) 
    
     if i == 1 
        % STEP 4: Get the initial phase vector according to the watermark
        Wb_temp = zeros(1, len_Wo+1); % Wb(1) = 0; % DC component
        for j = 1 : len_Wo    
            if Wo(j) == 1
                Wb_temp(j+1) = pi/2;   % the initial phase vector
            else
                Wb_temp(j+1) = -pi/2;
            end
        end
        x = 1 : len_Wo+1;
        xi = 1 : 1/freq_slot: (len_Wo+1);
        Wb = interp1(x, Wb_temp, xi, 'spline');
        old_phase = angle( fft(frame) );       % phase
        new_phase = Wb(1:end-1);
    else
        % STEP 5: Construct the new phase difference matrix new_Phai
        old_phase = angle( fft(frame) );       % phase
        delta_Phai = old_phase - old_pre_phase;
        new_phase = new_pre_phase + delta_Phai(1:N2);
    end
    old_pre_phase = old_phase;
    new_pre_phase = new_phase;
        
    % STEP 6: Reconstruct frequency spectrum by using Euler's formula
    Fr_l = amplitude( 1:N2 ) .* cos( new_phase(1:N2) ) ;  % the first half of real part
    Fi_l = amplitude( 1:N2 ) .* sin( new_phase(1:N2) ) ;  % the first half of imaginary part
    Fr_h = [ 0, Fr_l(N2:-1:2) ] ;                         % the second half of real part
    Fi_h = - [ 0, Fi_l(N2:-1:2) ] ;                       % the second half of imaginary part
    Fr = [ Fr_l, Fr_h ] ;                                 % the real part
    Fi = [ Fi_l, Fi_h ] ;                                 % the imaginary part
    freq_frame = complex( Fr, Fi ) ;                      % reconstructed frame 
    
    % STEP 7: IFFT back to time domain and concatenate all the frames
    re_frame = real( ifft(freq_frame) ) ;             % IFFT back to time domain
    wmed_signal = [wmed_signal,re_frame];

    pointer = pointer + N_frame;
end
wmed_signal = [host_signal(1:spoint-1),wmed_signal];
wmed_signal = [wmed_signal,host_signal(length(wmed_signal)+1:N)];
wavwrite(wmed_signal,44100,'wmed_signal');
return