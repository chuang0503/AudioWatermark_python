function [Flags, Tonal_list, Non_tonal_list] = Find_tonal_and_nontonal_components(X, TH, Map, CB) 
%   Step 2: Identification of tonal and non-tonal maskers
%   Assume sampling frequency Fs = 44100Hz
%   1. Find local maxima and put in local_max_list()
%   2. Identify tonal components and put in Tonal_list().
%   3. Obtain nontonal components and put in Non_tonal_list().

Common;

% Check input parameters
if (length(X) ~= FFT_SIZE)
   error('Unexpected power density spectrum size.');
end

% List of flags for all the frequency lines (1 to FFT_SIZE / 2)
Flags = zeros(FFT_SIZE / 2, 1) + NOT_EXAMINED;

% Label the local maxima
local_max_list = [];
counter = 1;
for k = 2:FFT_SIZE / 2 -  1, 
   if (X(k) > X(k-1) & X(k) >= X(k+1) & k > 2 & k <= 250)
      local_max_list(counter, INDEX) = k;
      local_max_list(counter, SPL) = X(k);
      counter = counter + 1;
   end
end

% Indentify tonal components among local maxima which meet certain requirements.
Tonal_list = [];
counter = 1;
if not(isempty(local_max_list))
	for i = 1:length(local_max_list(:, 1))
	   k = local_max_list(i, INDEX);
	   is_tonal = 1;
	   
	   % Layer I
	   % Examine neighbouring frequencies
	   if (2 < k & k < 63)
	      J = [-2 2];
	   elseif (63 <= k & k < 127)
	      J = [-3 -2 2 3];
	   elseif (127 <= k & k < 250)
	      J = [-6:-2, 2:6];
	   else
	      is_tonal = 0;
	   end
	   
	   for j = J
	      is_tonal = is_tonal & (X(k) - X(k + j) >= 7);
	   end
	   
	   % If X(k) is actually a tonal component then the following are listed
	   %    - index number k of the spectral line
	   %    - sound pressure level
	   %    - set tonal flag
	   if is_tonal
	      Tonal_list(counter, INDEX) = k;
	      Tonal_list(counter, SPL) = 10 * log10(10^(X(k - 1) / 10) + ...
	         10^(X(k) / 10) + 10^(X(k + 1) / 10));
	      Flags(k) = TONAL;
	      for j = [J -1 1]
	         Flags(k + j) = IRRELEVANT;
	      end
	      counter = counter + 1;
	   end
   end

end

% Obtain 24 non-tonal components by summing up the powers of the remaining components
% ( referring to all components except tonal components) 
Non_tonal_list = [];
counter = 1;
for i = 1:length(CB(:, 1)) - 1
   % For each critical band, compute the power of non-tonal components
   power  = MIN_POWER; 
   weight = 0;       % Used to compute the geometric mean of the critical band
   for k = TH(CB(i), INDEX):TH(CB(i + 1), INDEX) - 1    % In each critical band
      if (Flags(k) == NOT_EXAMINED),
         power    = 10 * log10(10^(power / 10) + 10^(X(k) / 10));
         weight   = weight + 10^(X(k) / 10) * (TH(Map(k), BARK) - TH(CB(i), BARK)');
         Flags(k) = IRRELEVANT;
      end
   end
   
   % The index number for the non tonal component is the index nearest to the geometric mean of the critical band
   if (power <= MIN_POWER)
      index = round(mean(TH(CB(i), INDEX), TH(CB(i + 1), INDEX)));
   else
      index = TH(CB(i), INDEX) + round(weight / 10^(power / 10) * ...
         (TH(CB(i + 1), INDEX) - TH(CB(i), INDEX)));
   end
   if (index < 1)
      index = 1;
   end
   if (index > length(Flags))
      index = length(Flags);
   end
   if (Flags(index) == TONAL)
      index = index + 1;    % Two tonal components cannot be consecutive
   end
   
   % For each subband
   %   - index of the non-tonal component
   %   - sound pressure level of this component
   Non_tonal_list(i, INDEX) = index;
   Non_tonal_list(i, SPL) = power;
   Flags(index) = NON_TONAL;
end