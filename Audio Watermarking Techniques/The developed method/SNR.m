function output = SNR(s1,s2)
% Calculate SNR between two signals, s1 and s2, 

output = 10*log10(sum(s1.^2)/sum((s2-s1).^2));

return;