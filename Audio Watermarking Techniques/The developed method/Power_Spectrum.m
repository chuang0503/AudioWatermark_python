function [X, delta]  = Power_spectrum(frame)
%   Step 1: Calculation of the power spectrum.
%   1. Apply hanning window h(n);
%   2. Calculate the power spectrum by FFT.
%   3. Normalize to 96dB.

Common;

X = [];

N = length(frame);
% Pad zeros if samples are insufficient.
if N ~= FFT_SIZE  
    frame = [frame; zeros(1,FFT_SIZE-N)];
end

% Hanning window
h = sqrt(8/3) * hanning(512, 'periodic');
 
% Power density spectrum
X = max(20 * log10(abs(fft(frame .* h'))/ FFT_SIZE), MIN_POWER);

% Normalization
delta = 96 - max(X);
X = X + delta;