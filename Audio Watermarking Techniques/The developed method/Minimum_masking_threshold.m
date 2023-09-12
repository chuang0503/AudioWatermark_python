function  LTmin = Minimum_masking_threshold(LTg, Map)
% Step 6: Determination of the minimum masking threshold 
% 1. Take the minimum of global masking threshold for each subband and put in LTmin().
% 2. Spread the minimum value over its subband and get LTminfreq_dB().

Common;

Subband_size = FFT_SIZE / 2 / N_SUBBAND;
count = 1; % For plotting minimum masking threshold with FFT_SIZE/2 points

for n = 1 : N_SUBBAND % For each subband
    LTmin(n) = LTg(Map((n - 1) * Subband_size + 1));  
    for j = 2 : Subband_size
        if (LTg(Map((n - 1) * Subband_size + j)) < LTmin(n))
            LTmin(n) = LTg(Map((n - 1) * Subband_size + j));
        end
    end
end

return;