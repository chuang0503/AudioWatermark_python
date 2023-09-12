N_frame   = 512;                % size of one frame
Fs        = 44100;              % Sampling frequency
min_freq  = 100;


% The following parameters are provided by Parameter_embedding.dat
% filename = 'bass_half';         % The host signal
N_block   = 27;                 % The total number of pattern blocks
period    = [1537,216577;268801,398849];
Nb_period = [13,14]; % The number of blocks for each period
N_wm      = 105;                % The length of the original watermark

N_G = 32;                       % The number of Gammatone filterbank channels
N_s = 28;                       % The number of subbands ( NB: changeable )  

N_bit     = 4;                  % The number of bits embedded in every block
N_em      = 108;                % The length of the embedding watermark 
N_u       = 10;                 % The number of units per block 
tiles_w   = 30;                 % The number of tiles assigned to each watermark bit
N_tiles   = N_s * N_u;          % The number of tiles per pattern block
N_wtiles  = N_bit * tiles_w;    % The total number of tiles for watermark bits per pattern block   
tiles_s   = N_tiles - N_wtiles; % The number of tiles for embedding sync bit per pattern block
