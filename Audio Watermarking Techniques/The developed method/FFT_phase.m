function Phase = FFT_phase(frame)

Parameter_embedding;

% window = hanning(N_frame, 'periodic')';
window = sqrt(8/3) * hanning(N_frame, 'periodic')';  % better than without sqrt(8/3)on the aspect of SNR
Phase = angle( fft(frame .* window) );

return;