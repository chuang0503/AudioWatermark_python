% Pre-process for both embedding and detection
% If for embedding:
% 1. Find the embedding periods
% 2. Determine some other parameters for embedding and write in Parameter_embedding.dat 
% 3. Calculate the number of characters possible to be embedded 
%    and determine the original watermark Wo based on the input.
% If for detection:
% 1. Determine the detection periods
% 2. Determine some other parameters for detection and write in Parameter_detection.dat 
% Note that the attacked signals for detection must be generated first.

close;
clear;
clc;

% Load files
k = menu('Please select action','Embedding','Detection');
if k == 1                            
    [filename,pathname] = uigetfile('*.wav','Select the host signal');
    input_signal = wavread(fullfile(pathname,filename))';
else
    ks = menu('Please choose','No attacks','Noise addition','Resampling',...
              'Requantization', 'Amplitude scaling', 'Lowpass filtering','DA/AD conversion',...
              'Echo addition', 'Reverberation', 'Data compression',...
              'Random samples cropping','Zeros inserting','Jittering',...
              'Pitch-invariant time stretching','Tempo-preserved pitch shifting');
   
    if ks == 2
        disp('Noise addition');
        kss = menu('Please choose','40dB','36dB','30dB');
        if kss == 1
            disp('40dB');
            filename = 'wmed_40dB';
        elseif kss == 2
            disp('36dB');
            filename = 'wmed_36dB';
        else
            disp('30dB');
            filename = 'wmed_30dB';
        end
    elseif ks == 3
        disp('Resampling');
        filename = 'wmed_resampling';
    elseif ks == 4
        disp('Requantization');
        filename = 'wmed_requantization';
    elseif ks == 5
        disp('Amplitude scaling');
        kss = menu('Please choose','Ampp','Ampn');
        if kss == 1
            disp('Ampp');
            filename = 'wmed_ampp';
        else
            disp('Ampn');
            filename = 'wmed_ampn';
        end
    elseif ks == 6
        disp('Lowpass filtering');
        kss = menu('Please choose','8kHz','6kHz','4kHz');
        if kss == 1
            disp('8kHz');
            filename = 'wmed_8kHz';
        elseif kss == 2
            disp('6kHz');
            filename = 'wmed_6kHz';
        else
            disp('4kHz');
            filename = 'wmed_4kHz';
        end
    elseif ks == 7
        disp('DA/AD conversion');
        filename = 'wmed_adda';
    elseif ks == 8
        disp('Echo addition');
        filename = 'wmed_echo';
    elseif ks == 9
        disp('Reverberation');
        filename = 'wmed_reverb';
    elseif ks == 10
        disp('Data compression');
        kss = menu('Please choose','96kps','64kps','48kps');
        if kss == 1
            disp('96kps');
            filename = 'wmed_96';
        elseif kss == 2
            disp('64kps');
            filename = 'wmed_64';
        else
            disp('48kps');
            filename = 'wmed_48';
        end
    elseif ks == 11
        disp('Random samples cropping');
        filename = 'wmed_cropping';
    elseif ks == 12
        disp('Zeros inserting');
        filename = 'wmed_inserting';
    elseif ks == 13
        disp('Jittering');
        filename = 'wmed_jittering';
    elseif ks == 14
        disp('Pitch-invariant time stretching');
        kss = menu('Please choose','Faster tempo','Slower tempo');
        if kss == 1
            disp('Faster tempo');
            filename = 'wmed_timef10';
        else
            disp('Slower tempo');
            filename = 'wmed_times10m';
        end
    elseif ks == 15
        disp('Tempo-preserved pitch shifting');
        kss = menu('Please choose','Higher pitch','Lower pitch');
        if kss == 1
            disp('Higher pitch');
            filename = 'wmed_pitchh10';
        else
            disp('Lower pitch');
            filename = 'wmed_pitchl10';
        end
    else
        disp('No attacks');
        filename = 'wmed_signal';
    end

    input_signal = wavread(filename)';
end

N = length(input_signal);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Find the embedding periods
%    STEP 1: All silence and non-silence parts are identified. 
N_frame = 512; % 512/44.1=11.6ms
pointer = 1;
flag = 1;      % represent the energy status of the previous frame 
count = 1;     % represent the order of blocks
while (pointer+N_frame-1)  <= N
    temp = input_signal( pointer : pointer+N_frame-1);
    if sum(temp.^2) > 0.1    % power
        if count == 1           % in case of the first frame 
            block(count) = pointer;
            count = count + 1;
            flag = 0;
        else
            if flag 
                block(count) = pointer;
                flag = 0;
                count = count + 1;
            end
        end
    else
        if flag == 0
            block(count) = pointer;
            flag = 1;
            count = count + 1; 
        end
    end
    pointer = pointer + N_frame;
end
if mod(length(block),2) ~= 0    % It is non-silence part ain the end of signal.
    block(count) = N;
end

if (N-pointer) < 0 
    disp('It reaches the end.');
else
    fprintf('%d points are left.\n',N-pointer+1);
end

%    STEP 2: Get the final valid periods
len_edge = length(block);
count = 1;
for i = 1 : 2 : len_edge
    if ( block(i+1)-block(i) > 1e5 ) % as a valid data period
        edge(count,1) = block(i);
        edge(count,2) = block(i+1);
        count = count + 1;
    end
end

[rows,columns] = size(edge);
edge(:,3) = zeros(rows,1); 
for i = 1 : (rows-1)
    if edge(i+1,1)-edge(i,2) > 5000  % as a valid silence part
        edge(i+1,3) = 1;             % as a flag for silence
    end
end

period(1) = edge(1,1); % the first starting point
count = 2; 
flag = find(edge(:,3));
EfficientBlocks = length(flag) + 1; 
for i = 1 : (EfficientBlocks - 1)
    period(count)   = edge(flag(i)-1,2);
    period(count+1) = edge(flag(i),1);
    count = count + 2;
end

if mod(length(period),2) ~= 0
    period(count) = edge(rows,2);
end
% Actually the starting points of periods are more important then the ending points.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Determine some other parameters for embedding and write in Parameter_embedding.dat 
% Define in advance
Isrepetitive_coding = 0;          % For denoting repetitive coding
Isencryption = 0;                 % For image encryption
N_u = 10;                         % The number of units per pattern block
tile_size  = N_frame * 2;         % The length of normal tiles except the first tile
block_size = N_u * tile_size;     % The length of each blcok
% The length of the first block should be increased by N_frame/2. 

count = 1;
N_period = length(period)/2;      % Number of periods
for i = 1 : 2 : length(period)
    % The number of pattern blocks in each period
    Nb_period(count) = fix( (period(i+1) - period(i))/block_size ) - 1; 
    % In the detection, one more block is necessary
    count = count + 1;
end

N_block = sum(Nb_period);         % The number of blocks totally

% For detection, one more block is compulsory.
if k == 2
    Nb_period = Nb_period + 1;   
end

% Sometimes Qt_b matrix will be amplified, such as positive time stretching.
% Determine the maximum number of pattern blocks in every period, just in case.
count = 1;
for i = 1 : ( N_period - 1 ) 
    Nmax_period(i)  = edge(i+1,1) - edge(i,1);
    Nbmax_period(i) = fix( Nmax_period(i)/block_size );
end
Nmax_period(i+1)  = length(input_signal) - edge(i+1,1);
Nbmax_period(i+1) = fix( Nmax_period(i+1)/block_size );

if N_period == 1
    Nbmax_period = N_block;
end
% Determine the number of characters possible to be embedded
N_bit = 4;                        % The number of bits embedded per block
% Without repetitive coding
N_wm = N_block * N_bit;           % The length of original watermark
N_em = N_wm;                      % The length of the embedding watermark

if Isrepetitive_coding
    % Tri-repetitive coding
    N_wm = fix(N_block * N_bit/3); 
    N_em = 3 * N_wm;
end

% Write in .dat file
if k == 1                            
    fid = fopen('Para_embedding.dat','w'); 
else
    fid = fopen('Para_detection.dat','w'); 
end

fprintf(fid,'%c',filename);
fprintf(fid,'''.\n');
fprintf(fid,'The edges of the periods are ');
fprintf(fid,'%d\t',period);
fprintf(fid,'.\n');
fprintf(fid,'\nThe maximum number of blocks in every period are ');
fprintf(fid,'%d\t',Nbmax_period);
fprintf(fid,'.\n');
fprintf(fid,'For each period, there are ');
fprintf(fid,'%d\t',Nb_period);
fprintf(fid,'blocks available.\n');
if k == 1
    fprintf(fid,'The length of the host signal is %d.\n',length(input_signal));
    fprintf(fid,'In total, there are %d blocks available.\n',N_block);
    fprintf(fid,'The maximum length of the origianl watermark is %d.\n',N_wm); 
    fprintf(fid,'The maximum length of the embedding watermark is %d.\n',N_em); 
end
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Calculate the number of characters possible to be embedded 
%    and determine the original watermark Wo based on the input.
% ONLY FOR EMBEDDING
if k == 1
    letter_row = 7;              
    letter_column = 5; 
    letter_size = letter_row * letter_column;  % Each letter is represented as a 7 by 5 matix.
    N_letter = fix(N_wm / letter_size);        % The maximum number of characters 
    flag1 = 1;
    flag2 = 0;
    while flag1
        fprintf('Please input your watermark in CAPITAL letters from A to Z (<=%d letters)!\n',N_letter);
        watermark_letter = input('','s');
        if length(watermark_letter) > N_letter
            disp('The length of your watermark exceeds the maximum length!');
            reply = input('Continue or not? [Y/N]\n','s');
            if reply ~= 'Y' 
                flag1 = 0;
                disp('Sorry, you haven''t determined the watermark to be embedded.');
            end
        else
            for i = 1 : length(watermark_letter)
                temp = double(watermark_letter(i));
                if temp > 90 || temp < 65      % char(65)=A, char(90)=Z
                    disp('Unrecognized letters exist!');
                    reply = input('Continue or not? [Y/N]\n','s');
                    if reply ~= 'Y'
                        flag1 = 0; 
                        disp('Sorry, you haven''t determined the watermark to be embedded.');
                        break;
                    else
                        flag1 = 1;
                        break;
                    end
                end
                j = i;
            end
            if j == length(watermark_letter)
                flag1 = 0;
                flag2 = 1;
                fprintf('Your watermark is ');
                disp(watermark_letter);
            end
        end
    end
    if flag2
        alphabet = Prprob;                    % Database for the letters
        N_L  = length(watermark_letter);      % The number of letters in the watermark 
        N_wm = N_L * letter_size;             % The length of watermark
        Wo   = [];                            % The original watermark 
        temp = [];
        for i = 1 : N_L
            % Convert the string to its equivalent numeric codes.
            letter(i) = double(watermark_letter(i));  
            % Find the letter in alphabet list
            temp(:,i) = alphabet(:,letter(i) - 64);
            Wo = [Wo, temp(:,i)'];            % One-dimensiaonl array       
        end
        coded_image = Array_to_image(Wo);     % the coded-image watermark
        figure;
        imshow(coded_image); 
       
        fid = fopen('Wo.dat','w');
        fprintf(fid,'%d\n',Wo);
        fclose(fid);
        Wb = Wo;
        
        if Isencryption
            key_encryption = randperm(N_wm);
            for i = 1 : N_wm
                encrypted_Wo(i) = Wo(key_encryption(i));
            end
            Wb = encrypted_Wo;
            fid = fopen('key_encryption.dat','w');
            fprintf(fid,'%d\n',key_encryption);
            fclose(fid);   
        end
        
        if Isrepetitive_coding
            temp = Wb;
            Wb = [];
            N_em = N_wm * 3;
            for i = 1 : N_wm
                Wb = [Wb,temp(i),temp(i),temp(i)];
            end
        end 
        temp = mod( length(Wb), N_bit );       % The length of We should be multiple of N_bit.
        if temp ~= 0   
            Wb = [Wb, zeros(1,N_bit-temp)];
        end
        N_em = length(Wb);
        fid = fopen('Wb.dat','w');
        fprintf(fid,'%d\n',Wb);
        fclose(fid);
        
        % Determine the number of bits embedded in each period
        N_block = N_em/N_bit;
        
        aver_Nb_period = fix(N_block/N_period);
        Nb_period = [];
        for i = 1 : (N_period-1)               % Here, special for our audio signals 
            Nb_period(i) = aver_Nb_period;
        end
        Nb_period(i+1) = N_block - i*aver_Nb_period; 
        if N_period == 1
            Nb_period = N_block;
        end
        fid = fopen('Para_embedding.dat','a');
        fprintf(fid,'\nThe length of the origianl watermark is %d.\n', N_wm);
        fprintf(fid,'The length of the embedding watermark is %d.\n', N_em);
        fprintf(fid,'Totally %d pattern blocks are required.\n', N_block);
        fprintf(fid,'For each period, ');
        fprintf(fid,'%d\t ',Nb_period);
        fprintf(fid,'blocks are used for embedding.\n');
        fclose(fid);
    end
end
 
figure;
plot(input_signal); hold on;
for i = 1 : length(period)
    line([period(i),period(i)],[-1,1],'Color','r');
end
    
    