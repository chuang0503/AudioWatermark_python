%   Define the `global' variables used.

FS           = 44100;
FFT_SIZE     = 512;
N_SUBBAND    = 32;
% Flags for tonal analysis
NOT_EXAMINED = 0;
TONAL        = 1;
NON_TONAL    = 2;
IRRELEVANT   = 3;

MIN_POWER = -200;

% Indices used in tables like the threshold table
% or in the list of tonal and non-tonal components.
INDEX = 1;
BARK  = 2;
SPL   = 2;
ATH   = 3;

% % For converting sample indices to frequency
% X_LABEL  = (1:FFT_SIZE/2) * FS/FFT_SIZE;  

Isrepetitive_coding = 0;          % For denoting repetitive coding
Isencryption = 0;                 % For image encryption