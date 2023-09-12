% Detecting the watermark from the received signal
% The received signal is probably not the initial watermarked signal, but being attacked.
% On the whole, we call the input signal as the evaluating signal.
% It is the normal detection algorithm, for all kinds of attacks except PITS and TPPS.
% Or you can specify the value of 'threshold' and use the program for PITS and TPPS.
%
close;
clear all;
clc;

global filename;
global pathname;

tic; % timer

Parameter_detection;
% for pattern block synchronization

threshold = fix(Nu_frames * 0.7); % Except PITS and TPPS

% fprintf('***********************************************************\n');
% fprintf('******************** Detection starts! ********************\n');
% fprintf('***********************************************************\n');

% Read the evaluating signal
[filename,pathname] = uigetfile('*.wav','Select the signal that you just chose to be evaluated.');  
eval_signal = wavread(fullfile(pathname,filename))';

% Preparation
fid = fopen('Positions.dat','r');
Positions = fscanf(fid,'%4d\n');
fclose(fid);

fid = fopen('PNs.dat','r');
PNs = fscanf(fid,'%4d\n');
fclose(fid);

fid = fopen('subbands.dat','r');
subbands = fscanf(fid,'%4d\n');
fclose(fid);

% Work on the configuration of MB and MPR
% For watermark bit
% Locate the slots for each watermark bit and find their PNs
count = 1;
for i = 1 : N_bit
    for j = 1 : tiles_w
        P_wm(i,j) = Positions(count);
        PNs_wm(i,j) = PNs(count);
        count = count + 1;
    end
end

% For synchronization bit
% Locate the slots for sync bit and also fill in the corresonding PN in each position
temp_sync = zeros( N_s, N_u );
for i = 1 : tiles_s
    row    = ceil( Positions(count)/N_u  );
    column =  rem( Positions(count), N_u );
    if column == 0
        column = column + N_u;
    end
    temp_sync(row,column) = PNs(count);
    count = count + 1;
end

m = 1;
for i = 1 : N_u
    n = 1;
    for j = 1 : N_s
        if temp_sync(j,i) ~= 0
            % Each row of P_sync includes the positions of slots for sync bit per unit
            P_sync(m,n) = j;
            % The corresponding PNs
            PNs_sync(m,n) = temp_sync(j,i);
            n = n + 1;
        end
    end
    % Each number of N_sync denotes for the number of slots for sync bits per unit
    N_sync(m) = length(find(P_sync(i,:)));
    m = m + 1;
end

% Detection starts.
halfsize = N_frame/2;
d_sync = [];
for nb = 1 : length(Q_period)
    %     fprintf('\n****** The %dth period starts. ******\n', nb);
    index = 1;          % for the first time
    flag  = 1;
    i = 1;              % for counting the frame
    j = 0;              % for counting the unit
    k = 1;              % for counting the pattern block
    p = period(nb,1);   % pointer
    m = 0;              % for counting the frames per period
    Pt_f = [];
    while flag == 1
        % Process frame by frame
        if index == 1   % the first frame is special
            temp  = eval_signal( p : p+N_frame-1);
            index = 0;
            frame = temp;
        else
            temp  = eval_signal( p+halfsize : p+N_frame-1 );
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
        
        % Windowing & DFT
        FD_frame = [];    % initialise
        FD_frame = abs( fft(frame.*hanning(N_frame)') );
        
        %         % Frequency alignment for PITS and TPPS
        %         FD_temp = FD_frame;
        %         FD_frame = [];
        %         % factor is larger  than 1 in case of times and pitchh
        %         %           smaller than 1 in case of timef and pitchl
        %         index = fix((1:N_frame)/0.9);  % fix toward zero
        %         index = round((1:N_frame)/1.1);  % Round to nearest integer
        
        %         % pitchh and times
        %         counter1 = 1;
        %         counter2 = 1;
        %         counter3 = 1;
        %         while counter1 <= (N_frame-1)
        %             if index(counter1) ~= index(counter1+1)
        %                 FD_frame(counter2) = FD_temp(counter1);
        %                 counter1 = counter1 + 1;
        %                 counter2 = counter2 + 1;
        %             else
        %                 while index(counter1) == index(counter1+1)
        %                     counter1 = counter1 + 1;
        %                     counter3 = counter3 + 1;
        %                     if counter1 >= N_frame
        %                         break;
        %                     end
        %                 end
        %                 FD_frame(counter2) = sum( FD_temp(counter1-counter3+1:counter1) )/counter3;
        %                 counter2 = counter2 + 1;
        %                 counter1 = counter1 + 1;
        %                 counter3 = 1;
        %             end
        %         end
        %
        %         % pitchl and timef
        %         FD_frame = interp1(index,FD_temp,1:index(N_frame)); % default: linear (actully it is the mean.)
        
        FD_frame = FD_frame(1:halfsize);
        
        % Normalization by the average
        factor = 0;
        for count = 1 : halfsize
            factor = factor + FD_frame(count) ;
        end
        factor = factor/halfsize;
        
        if factor ~= 0
            m = m + 1;
            
            % Calculate the logarithmic magnitude
            % NB: If there are zeros in FD_frame, warning will occur.
            Pt_f(m,:) = 20 * log10(FD_frame);
            Pt_f(m,:) = Pt_f(m,:)-mean(Pt_f(m,:));
            
            % Per unit
            if i >= N_bit
                i = 0;
                j = j+1;
            end
            i = i + 1;
            p = p + halfsize;
        else
            p = p + N_frame;
        end
        
        % Per pattern block
        if j >= N_u
            %             fprintf('The %dth pattern block has finished. \n', k);
            j = 0;
            k = k + 1;
            % Per period
            if k > Q_period(nb)
                %                 disp('Finish calculating Pt,f!');
                break;
            end
        end
    end
    
    dPt_f = [];
    [rP, cP] = size(Pt_f);
    % Calculate dt_f for amplifying the effect of modulus operator
    for i = 1 : rP
        if i <= rP - 2
            dPt_f(:,i) = [Pt_f(i,:) - Pt_f(i+2,:)]';
        else
            dPt_f(:,i) = Pt_f(i,:)';
        end
    end
    %     disp('Finish calculating dPt,f!');
    
    % Calculate the magnitude of tiles
    [rdP, cdP] = size(dPt_f);
    Qt_b = zeros(N_s, cdP);
    for i = 1 : N_s
        for j = subbands(2*i-1) : subbands(2*i)   % fl : fh
            Qt_b(i,:) = Qt_b(i,:) + dPt_f(j,:);
        end
        Qt_b(i,:)= Qt_b(i,:)/( subbands(2*i)-subbands(2*i-1)+1 );
    end
    %     disp('Finish calculating Qt,b!');
    [Qr, Qc] = size(Qt_b);
    
    %     % Pattern block synchronization
    %     disp('Pattern block synchronization begins!');
    flag_s = 0;
    count_s = 1;
    misalign = [];             % the amount of misalignment
    m_position = [];           % the position where misalignment happens
    n = 1;
    while n <= Nb_period(nb)
        %         fprintf('The %dth pattern block starts. \n', n);
        count = 1;
        for m = 1 : N_u        % Per unit
            for i = 1 : N_bit  % Per watermark bit
                aver_Q = 0.0;
                p = 1;
                q = 1;
                for j = 1 : N_u
                    for k = 1 : N_sync(j)
                        row = P_sync(j,k);
                        column = p + i - 1 + ( m-1 ) * 4 + (n-1) * (4*N_u);
                        if flag_s
                            column = column - sum(misalign);
                            %                             column = column + sum(misalign);  % for positive PITS
                        end
                        if column < 1 || column > Qc            % If exceed the dimension, take zero.
                            Qtb = 0;
                        else
                            Qtb = Qt_b(row,column);
                        end
                        aver_Q = aver_Q + Qtb;
                        Qt_b_temp(q) = Qtb;
                        PNs_sync_temp(q) = PNs_sync(j,k);
                        q = q + 1;
                    end
                    p = p + 4;
                end
                aver_Q = aver_Q/tiles_s;
                temp1 = 0.0;
                temp2 = 0.0;
                for r = 1 : tiles_s
                    temp1 = temp1 + PNs_sync_temp(r) * Qt_b_temp(r) ;
                end
                if sum(Qt_b_temp.^2)==0
                    Sd(count) = 0;
                else
                    Sd(count) = temp1/(sqrt(sum(PNs_sync_temp.^2))*sqrt(sum(Qt_b_temp.^2)));
                end
                count = count + 1;
            end
        end
        Sd_max(nb,n) = max(Sd);
        sum_Sd(nb,n) = sum(abs(Sd));
        d_sync(nb,n) = find( Sd==max(Sd) );            % the maximum sychronization strength
        % For cropping, the starting frame becomes the (Nu_frames - d_sync(nb,n) + 1)th frame
        % For zeros inserting, don't care.
        if d_sync(nb,n) >= threshold                   % cropping occurs
            flag_s = 1;
            misalign(count_s) = Nu_frames - d_sync(nb,n) + 1;
            m_position(count_s) = n;
            count_s = count_s + 1;
            n = n - 1 ;                                % repeat for this block untill meet the requirement
        end
        n = n + 1;
    end
    
    % Try to find out where the croppings occur from m_position[]
    % So only keep the transitions and put in temp_tmp[]
    temp_tmp = [];
    count1 = 1;                                        % a temporary counter
    for i = 1 : length(m_position)
        if i == 1
            temp_tmp(count1) = m_position(i);
            count1 = count1 + 1;
        else
            if m_position(i) ~= temp_tmp(count1-1)
                temp_tmp(count1) = m_position(i);
                count1 = count1 + 1;
            end
        end
    end
    
    % Accumulate the misalignment of one position
    count1 = 1;
    count2 = 1;
    temp_ma = [];
    temp_mp = [];
    i = 1;
    while i <= length(m_position)
        if m_position(i) == temp_tmp(count1)
            temp_ma(count2) = misalign(i);
            count2 = count2 + 1;
        else
            count2 = 1;
            temp_mp(count1) = sum(temp_ma);
            temp_ma = [];
            count1 = count1 + 1;
            i = i - 1;
        end
        i = i + 1;
    end
    temp_mp(count1) = sum(temp_ma);
    misalign = [];
    misalign = temp_mp;
    
    m_position = [];
    m_position = temp_tmp;
    N_mp = length(m_position);
    
    % Initialise
    flag_s = 0;
    count_s = 1;
    i = 1;
    
    % Bit detection
    while i <= ( Nb_period(nb))                        % process every bit
        if count_s <= N_mp
            if i == m_position(count_s)
                flag_s = 1;
                count_s = count_s + 1;
            end
        end
        for j = 1 : N_bit
            aver_Q = 0.0;
            for k = 1 : tiles_w                        % find all the tiles assigned to one bit
                row = ceil(P_wm(j,k)/N_u);
                column_temp = rem( P_wm(j,k) , N_u );
                if column_temp == 0
                    column_temp = column_temp + N_u;
                end
                column = (i-1)*N_u*4 + (column_temp-1)*4 + d_sync(nb,i);
                if flag_s
                    column = column - sum(misalign(1:count_s-1));
                    %                     column = column + sum(misalign(1:count_s-1));
                end
                if column < 1 || column > Qc
                    Qtb = 0;
                else
                    Qtb = Qt_b(row,column);
                end
                aver_Q = aver_Q + Qtb;
                Qt_b_temp(k) = Qtb;
            end
            aver_Q = aver_Q/tiles_w;
            temp1 = 0.0;
            temp2 = 0.0;
            for k = 1 : tiles_w
                temp1 = temp1 + PNs_wm(j,k)*Qt_b_temp(k);
            end
            G(nb,(i-1)*4+j) = temp1/(sqrt(sum(PNs_wm(j,:).^2))*sqrt(sum(Qt_b_temp.^2)));
            if G(nb,(i-1)*4+j) < 0
                Bit_temp(nb,(i-1)*4+j) = 0;
            else
                Bit_temp(nb,(i-1)*4+j) = 1;
            end
        end
        i = i + 1;
    end
end

% Combine all the recovered bits
Bit = [];
for i = 1 : length(Nb_period)
    Bit = [Bit,Bit_temp(i,1:Nb_period(i)*4)];
end

% For some redundant bits probably were added in the embedding,
% we only take the first N_em bits
Wbe = Bit(1:N_em);
disp('Bit detection has finished');
% fid = fopen('Wbe.dat','w');
% fprintf(fid,'%d\n',Wbe);
% fclose(fid);

% ROCBR
fid = fopen('Wb.dat','r');                             % the embedding watermark
Wb = fscanf(fid,'%d\n')';
fclose(fid);

if Wbe == Wb
    fprintf('\nROCBR = 0\n\n');
else
    diff = Wbe - Wb;
    ROCBR = sum(abs(diff))/N_em*100;
    fprintf(filename);
    fprintf('\nROCBR = %.2f\n\n',ROCBR);
end

% ROCLR
We = Wbe;
if Isrepetitive_coding
    tri_count = 1;
    for i = 1 : 3 : N_em
        aver = ( Wbe(i)+Wbe(i+1)+Wbe(i+2) )/3;
        if aver > 0.5
            We(tri_count) = 1;
        else
            We(tri_count) = 0;
        end
        tri_count = tri_count + 1;
    end
end

if Isencryption
    fid = fopen('key_encryption.dat','r');
    key_encryption = fscanf(fid,'%d\n');
    fclose(fid);
    for i = 1 : N_em
        temp_encryption(key_encryption(i)) = We(i);
    end
    We = [];
    We = temp_encryption;
end
fid = fopen('We.dat','w');
fprintf(fid,'%d\n',We);
fclose(fid);

fid = fopen('Wo.dat','r');                             % the original watermark
Wo = fscanf(fid,'%d\n')';
fclose(fid);
if We(1:N_wm) == Wo
    fprintf('\nROCLR = 0\n\n');
else
    diff = We(1:N_wm) - Wo;
    ROCLR = sum(abs(diff))/N_wm*100;
    fprintf('\nROCLR = %.2f\n\n',ROCLR);
end

% Reconstruct the coded image
recovered_coded_image = Array_to_image(We(1:N_wm));
figure;
imshow(~recovered_coded_image); % title(filename);
