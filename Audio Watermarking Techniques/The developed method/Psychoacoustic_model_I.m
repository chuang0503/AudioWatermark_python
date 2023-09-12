function  magnitude =Psychoacoustic_model_I(x,fs)
% Calculate inaudible amount in frequency domain as amplitude of the watermark signal,
% implemented by Psychoacoustic Model I.
% x: Input frame, with 512 points
% fs: Sampling frequency (44100Hz)
% Reference:
% [21]	ISO/IEC 11172-3, Information Technology - Coding of Moving Picture and Associated Audio
%       for Digital Storage Media Up To About 1.5Mbit/s, British Standard. BSI, London, 1993.
% [22]	F.A.P. Petitcolas, MPEG for Matlab, 2003.
%       www.petitcolas.net/fabien/software/mpeg

global delta;
Common;

% Load tables.
[TH, Map, LTq] = Table_absolute_threshold(1, fs, 128); % Threshold in quiet
CB = Table_critical_band_boundaries(1, fs);

% Step 1: Calculation of the power spectrum
[X, delta] = Power_Spectrum(x);

% Step 2: Identification of tonal and non-tonal maskers
[Flags, Tonal_list, Non_tonal_list] = Find_tonal_and_nontonal_components(X, TH, Map, CB);

% Step 3: Decimation of the invalid tonal and non-tonal maskers
[Flags, Tonal_list, Non_tonal_list] = Decimation(X, Tonal_list, Non_tonal_list, Flags, TH, Map);

% Step 4: Calculation of individual masking thresholds
[LTt, LTn] = Individual_masking_thresholds(X, Tonal_list, Non_tonal_list, TH, Map);

% Step 5: Calculation of global masking threshold
LTg = Global_masking_threshold(LTq, LTt, LTn);

% Step 6: Determination of the minimum masking threshold
LTmin = Minimum_masking_threshold(LTg, Map);

% Step 7: Determination of magnitude of watermark signal

% Minimum masking threshold acts as the magnitude of watermark signal directly.
count = 1;
Subband_size = FFT_SIZE / 2 / N_SUBBAND;
for n = 1 : N_SUBBAND          % For each subband
    for j = 1 : Subband_size   % Spread over the whole subband
        LTminfreq_dB( count ) = LTmin(n);
        count = count + 1;
    end
end
factor = 100;
for i = 1: FFT_SIZE/2
    magnitude(i) = 10^( ( LTminfreq_dB(i) - delta)/20 ) * factor;
end
return;
