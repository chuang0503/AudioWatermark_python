clear;
clc;

% % convert times file to pitchh file
% times=wavread('wmed_times_10');
% times_m=resample(times,1000,1111);
% wavwrite(times_m,44100,'wmed_times_1010m');

old=wavread('wmed_times10');
new=resample(old,10,11);
wavwrite(new,44100,'wmed_times10m');

% old=wavread('wmed_times4');
% new=resample(old,100,104);
% wavwrite(new,44100,'wmed_times4m');

% % convert timef file to pitchl file
% timef=wavread('wmed_timef_5');
% timef_m=resample(timef,105,100);
% wavwrite(timef_m,44100,'wmed_timef_5m');

% old=wavread('wmed_timef10');
% new=resample(old,11,10);
% wavwrite(new,44100,'wmed_timef10m');