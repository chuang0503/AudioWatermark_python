N_frame    = 512;                  % size of a frame
Fs         = 44100;                % sampling frequency

% The following parameters are provided by Parameter_detection.dat
% filename  = 'wmed_signal';  
period    = [1537,216577;268801,398849];
% filename  = 'wmed_40dB';           
% period    = [];
% filename  = 'wmed_36dB';           
% period    = [];
% filename  = 'wmed_30dB';           
% period    = [];
% filename  = 'wmed_resampling';    
% period    = [];
% filename  = 'wmed_requantization';
% period    = [];
% filename  = 'wmed_ampp';           
% period    = [];
% filename  = 'wmed_ampn';          
% period    = [];
% filename  = 'wmed_8kHz';    
% period    = [];
% filename  = 'wmed_6kHz';    
% period    = [];
% filename  = 'wmed_4kHz';    
% period    = [];
% filename   = 'wmed_adda';          
% period    = [];
% filename   = 'wmed_echo';          
% period    = [];
% filename   = 'wmed_reverb';        
% period    = [];
% filename   = 'wmed_96';   
% period    = [];
% filename   = 'wmed_64';      
% period    = [];
% filename   = 'wmed_48'; 
% period    = [];
% filename   = 'wmed_cropping';   
% period    = [];
% filename   = 'wmed_jittering';  
% period    = [];
% filename   = 'wmed_inserting';  
% period    = [];
% filename   = 'wmed_times4';      
% period    = [];
% filename   = 'wmed_times10';       
% period    = [];
% filename   = 'wmed_times10m';     
% period    = [];
% filename   = 'wmed_timef4';        
% period    = [];
% filename   = 'wmed_timef10';   
% period    = [];
% filename   = 'wmed_timef10m';  
% period = [];
% filename   = 'wmed_pitchh4';   
% period    = [];
% filename   = 'wmed_pitchh10';   
% period    = [];
% filename   = 'wmed_pitchl4'; 
% period    = [];
% filename   = 'wmed_pitchl10'; 
% period    = [];

N_block    = 27;                  % The total number of pattern blocks
Nb_period  = [13,14];  % The number of blocks for each period
Q_period   = [14,15];  % for calculating Qt_b
N_wm       = 105;                 % The length of the original watermark

N_G = 32;                          % The number of Gammatone filterbank channels
N_s = 28;                          % The number of subbands ( NB: changeable )   

N_bit = 4;                         % The number of bits embedded in every block
N_em  = 108;                       % The length of the embedding watermark
N_u   = 10;                        % The number of units per block 
block_size = N_u * 2 * N_frame;    % The length of one block
Nu_frames  = N_u * 4;              % The number of frames per block

tiles_w    = 30;  % The number of tiles assigned to each watermark bit
N_tiles    = N_s * N_u;            % The number of tiles per pattern block
N_wtiles   = N_bit * tiles_w;      % The total number of tiles for watermark bits per pattern block   
tiles_s    = N_tiles - N_wtiles;   % The number of tiles for embedding sync bit per pattern block

Isrepetitive_coding = 0;           % For denoting repetitive coding
Isencryption = 0;                  % For image encryption

