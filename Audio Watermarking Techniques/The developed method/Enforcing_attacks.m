% Apply attacks on the watermarked signal (INPUT) and get the evaluating signal (OUTPUT). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'Noise addition':    (40dB)
% 'Resampling':        (22.05kHz)
% 'Lowpass filtering': (8kHz)
% 'Echo addition':     (0.3, 200ms)
% 'Data compression':  Compression II (96 kbps)
% 'Random samples cropping':  (2*1000) at 400000, 700000  
% 'Zeros inserting':          (2*1000) at 400000, 700000
% 'Jittering':                (5/20000)
% 'Pitch-invariant time stretching':  (±4%)   
% 'Tempo-preserved pitch shifting'):  (±4%)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close;
clear all;
clc;

% Load the watermarked signal.   
wmed_signal = wavread('wmed_signal')'; % An example 'INPUT'
N = length(wmed_signal); % length of the watermarked signal
eval_signal = [];        % the signal to be evaluated, 'OUTPUT'

Fs = 44100;

% Attacks
k = menu('Please choose','No attacks','Noise addition','Resampling',...
          'Lowpass filtering','Echo addition','Data compression',...
          'Random samples cropping','Zeros inserting','Jittering',...
          'Pitch-invariant time stretching','Tempo-preserved pitch shifting');
if k == 2  
    disp('Noise addtion');
    ks = menu('Noise SNR','40dB','36dB','30dB');
    if ks == 1  
        disp('40dB');
        snr = 40; % SNR in decibels
        eval_signal = awgn(wmed_signal,snr,'measured');       
        wavwrite(eval_signal,Fs,'wmed_40dB');
    elseif ks == 2
        disp('36dB');
        snr = 36; % SNR in decibels
        eval_signal = awgn(wmed_signal,snr,'measured');       
        wavwrite(eval_signal,Fs,'wmed_36dB');
    else
       disp('30dB');
        snr = 30; % SNR in decibels
        eval_signal = awgn(wmed_signal,snr,'measured');       
        wavwrite(eval_signal,Fs,'wmed_30dB');
    end 
elseif k == 3 
    disp('Resampling');
    % The whole procedure includes two parts, all implemented by Streambox Ripper
    % Attack: Downsampling to 22.05kHz or 11.025kHz (The default setting is 22.05kHz).
    % Inverse of the attack: Upsampling back to 44.1kHz. 
    % The evaluating signal is the file after attack and inverse of the attack.
    disp('Implemented by Streambox Ripper');   % create wmed_resampling.wav 
    disp('Please read the file directly'); 
elseif k == 4
    disp('Lowpass filtering');
    ks = menu('Four lowpass filters','8kHz','6kHz','4kHz');
    % 'wp=0.3pi,ws=0.4pi' is the default setting. 
    lp_name = 'Num8kHz.dat'; % 'Num34.dat';
    if ks == 1
        disp('8kHz');
        lp_name = 'Num8kHz.dat';
    elseif ks == 2
        disp('6kHz');
        lp_name = 'Num6kHz.dat';
    else
        disp('4kHz');
        lp_name = 'Num5kHz.dat';
    end
    fid = fopen(lp_name,'r');
    Num = fscanf(fid,'%f\n');
    fclose(fid);
    eval_signal = filtfilt(Num,1,wmed_signal); 
    if ks == 1
        wavwrite(eval_signal,Fs,'wmed_8kHz');
    elseif ks == 2
        wavwrite(eval_signal,Fs,'wmed_6kHz');
    else
        wavwrite(eval_signal,Fs,'wmed_5kHz');
    end 
elseif k == 5
    disp('Echo addition');
%     Am = input('Please input amplitude attanuation within [0,1]\n');
%     if ~isempty(Am)
%         if Am > 1 || Am < 0
%             warning('Am is wrong!');
%             break;
%         end
%     end
%     if isempty(Am)
%         disp(' The default value: 0.3');
%         Am = 0.3; % The default setting
%     end
%     
%     delay = input('Please input delay time in milisecond (ms)\n');
%     delay = fix( delay * Fs * 10^(-3) ); % converting from ms to points
%     if isempty(delay)
%         disp('The default value: 8820');
%         delay = 8820; % 4410/44100 = 100 ms
%     end
    Am = 0.3;
    delay = 8820;
    eval_signal = wmed_signal + Am * [zeros(1,delay),wmed_signal( 1:(N-delay) )];
    wavwrite(eval_signal,Fs,'wmed_echo');
elseif k == 6
    disp('Data compression');
    % The whole procedure includes two parts, all implemented by Streambox Ripper
    % Attack: Convert from .wav to .mp3 at a bit rate of 96kbps. (Fs remains).
    % Inverse of the attack: Back from .mp3 to .wav. 
    % The evaluating signal is the file after attack and inverse of the attack.
    disp('Implemented by Streambox Ripper');   % create wmed_resampling.wav 
    disp('Please read the evaluating file directly');  
    reply1 = input('Is ''wmed_mp3II.wav'' ready? [Y/N]\n','s');
    if reply1 == 'Y'  
        eval_signal = wavread('wmed_mp3II')';   
       
        reply2 = input('Do you want to know MP3 compression I? [Y/N]\n','s');
        if reply2 == 'Y'
            [SP,mp3I] = mp3_compression_I(wmed_signal,eval_signal);
            wavwrite(mp3I,44100,'wmed_mp3I');
        end
    end   
elseif k == 7  
    disp('Random samples cropping');
%     fprintf('The starting position for cropping is within [1,%d].\n', N);
%     cp = input('Please input the position\n');
%     if ~isempty(cp)
%         if cp > N || cp < 1
%             warning('The starting position for cropping is wrong!');
%             break;
%         end
%     end
%     if isempty(cp)
%         disp('The default value: 700001');
%         cp = 70001; % The default setting
%     end
%     points_limit = N - cp + 1;
%     fprintf('The number of samples to be cropped is within [1,%d].\n', points_limit);
%     cn = input('Please input the number\n');
%     if ~isempty(cn)
%         if cn > points_limit || cn < 1
%             warning('The number of samples to be cropped is wrong!');
%             break;
%         end
%     end
%     if isempty(cn)
%         disp('The default value: 1000');
%         cn = 1000; % The default setting
%     end
%     %% single cropping
% %     eval_signal = [wmed_signal(1:cp-1),wmed_signal(cp+cn:N)];
% 
%     %% Double cropping.  
%     eval_signal = [wmed_signal(1:400000),wmed_signal(401001:700000),...
%                    wmed_signal(701001:N)]; 
% %     eval_signal = [wmed_signal(1:100000),wmed_signal(101001:300000),...
% %                    wmed_signal(301001:N)]; 

% multiple cropping
    eval_signal = [wmed_signal(1:100000),wmed_signal(101101:150000),...
                   wmed_signal(151101:200000),wmed_signal(201101:250000),...
                   wmed_signal(251101:300000),wmed_signal(301101:350000),...
                   wmed_signal(351101:400000),wmed_signal(401101:500000),...                 
                   wmed_signal(501101:N)];
%   eval_signal = [wmed_signal(1:100000),...
%                  wmed_signal(101101:200000),...
%                  wmed_signal(201101:300000),...
%                  wmed_signal(301101:400000),...   
%                  wmed_signal(401101:450000),...
%                  wmed_signal(451101:500000),...
%                  wmed_signal(501101:600000),...
%                  wmed_signal(601101:700000),...               
%                  wmed_signal(701101:N)];
    wavwrite(eval_signal,Fs,'wmed_cropping');    
elseif k == 8  
    disp('Zeros inserting');
%     fprintf('The starting position for inserting zeros is within [1,%d].\n', N);
%     ip = input('Please input the position\n'); 
%     if ~isempty(ip)
%         if ip > N || ip < 1
%             warning('The starting position for inserting zeros is wrong!');
%             break;
%         end
%     end
%     if isempty(ip)
%         disp('The default value: 70001');
%         ip = 70001; % The default setting
%     end
%     
%     disp('The number of zerso to be inserted is unlimited.');
%     in = input('Please input the number\n');
%     if ~isempty(in)
%         if in > fix(N/100)
%             warning('Too many zeros!');
%             break;
%         end
%     end
%     if isempty(in)
%         disp('The default value: 1000');
%         in = 1000;    % The default setting
%     end
%     %% single inserting
% %     eval_signal = [wmed_signal(1:ip),zeros(1,in),wmed_signal(ip+1:N)];
% 
%     %% double inserting
%     eval_signal = [wmed_signal(1:400000),zeros(1,1000),...
%                    wmed_signal(400001:700000),zeros(1,1000),...
%                    wmed_signal(700001:N)]; 

    % multiple inserting
    eval_signal = [wmed_signal(1:100000), zeros(1,441),...
                   wmed_signal(100001:200000), zeros(1,441),...
                   wmed_signal(200001:300000), zeros(1,441),...
                   wmed_signal(300001:400000), zeros(1,441),...
                   wmed_signal(400001:N)];

%     eval_signal = [wmed_signal(1:100000), zeros(1,1100),...
%                    wmed_signal(100001:200000), zeros(1,1100),...
%                    wmed_signal(200001:300000), zeros(1,1100),...
%                    wmed_signal(300001:400000), zeros(1,1100),...
%                    wmed_signal(400001:450000), zeros(1,1100),...
%                    wmed_signal(450001:500000), zeros(1,1100),...
%                    wmed_signal(500001:600000), zeros(1,1100),...
%                    wmed_signal(600001:700000), zeros(1,1100),...
%                    wmed_signal(700001:N)];
    wavwrite(eval_signal,Fs,'wmed_inserting');
% 
%     % Combination of cropping and zeros inserting
%     reply = input('Do you want to know cropping & inserting? [Y/N]\n','s');
%     if reply == 'Y'  
%         CandI_signal = [wmed_signal(1:70000),zeros(1,120),wmed_signal(70121:N)];
%         wavwrite(CandI_signal,44100,'wmed_CandI');
%     end
%     
    
elseif k == 9 
    disp('Jittering');
%     fprintf('The hopping size is within [10000, %d].\n', fix(N/50));
%     hop = input('Please input the hopping size\n'); 
%     if ~isempty(hop)
%         if hop > fix(N/50) || hop < 10000         
%             warning('The hopping size is wrong!');
%             break;
%         end
%     end
%     if isempty(hop)
%         disp('The default value: 20000');
%         hop = 882; % The default setting
%     end
%     
%     fprintf('The number of samples cropped is within [5, 10].\n');
%     jitter = input('Please input the number\n'); 
%     if ~isempty(jitter)
%         if jitter > 10 || jitter < 5         
%             warning('The amount of cropping is wrong!');
%             break;
%         end
%     end
%     if isempty(jitter)
%         disp('The default value: 4');
%         jitter = 4; % The default setting
%     end
    hop = 882; 
    jitter = 4;
    for i = 1 : fix( N/(hop+jitter) )
        temp = wmed_signal( ((i-1)*hop+jitter+1) : i*hop );
        eval_signal = [ eval_signal, temp ];
    end
    eval_signal = [ eval_signal,wmed_signal( (i*hop+1) : N )];
    wavwrite(eval_signal,Fs,'wmed_jittering');      
elseif k == 10
    disp('Pitch-invariant time stretching');
    disp('Time stretching is limited within [-10%, +10%].');
    disp('Both positive and negative stretching will be taken into consideratioons.');
%     st_factor = input('Please input the streching factor, an integer between 1 and 10)\n'); 
%     if ~isempty(st_factor)
%         if st_factor > 10 || st_factor < 1 || fix(st_factor)~=st_factor
%             warning('The value of stretching factor is wrong!');
%             break;
%         end
%     end
%     if isempty(st_factor)
%         disp('The default value: 4');
%         st_factor = 4; % The default setting
%     end
    disp('Please read the files directly.'); 
    % 'wmed_times.wav': Slower tempo
    % 'wmed_timef.wav': Faster tempo
elseif k == 11
    disp('Tempo-preserved pitch shifting');
    disp('Pitch shifting is limited within [-10%, +10%].');
    disp('Both positive and negative shifting will be taken into consideratioons.');
%     sh_factor = input('Please input the shifting factor, an integer between 1 and 10)\n'); 
%     if ~isempty(sh_factor)
%         if sh_factor > 10 || sh_factor < 1 || fix(sh_factor)~=sh_factor
%             warning('The value of shifting factor is wrong!');
%             break;
%         end
%     end
%     if isempty(sh_factor)
%         disp('The default value: 4');
%         sh_factor = 4; % The default setting
%     end
    disp('Please read the evaluating files directly.');       
else 
    disp('No attacks');
end 
    