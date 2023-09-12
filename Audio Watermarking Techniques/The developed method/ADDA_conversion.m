% function [SP, SSw_m] = ADDA_conversion(Sw,SSw)
% Calculate the quantity of shifting points after AD/DA conversion
% Sw:  the watermarked signal
% SSw: the signal after attack and inverse of the attack

clear;
clc;

Sw = wavread('wmed_signal');
SSw = wavread('wmed_addatemp');

N_Sw = length(Sw);
N_SSw = length(SSw);

% (1) Padding zeros to SSw(t)
temp_SSw = [SSw, zeros( 1,(N_Sw-N_SSw) )]; 

% (2) Calculate the cross-correlation between Sw(t) and SSw(t)
Rww = xcov(Sw,temp_SSw);

% (3) Find the location of the maximum
Lmax = find( Rww == max(Rww) );

% (4) Get the amount of shifting points
SP = N_SSw - Lmax;

SSw_e = SSw( (SP + 1):N_SSw ); % effective parts

% Finally get SSw_m(t) as the result after AD/DA conversion
SSw_m = SSw_e(1:N_Sw);

wavwrite(SSw_m, 44100, 'wmed_adda');
