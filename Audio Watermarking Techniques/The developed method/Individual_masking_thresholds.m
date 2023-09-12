function  [LTt, LTn] = Individual_masking_thresholds(X, Tonal_list, Non_tonal_list, TH, Map)
%   Step 4: Calculation of individual masking thresholds
%   1. Compute the masking function of tonal components and put in LTt()
%   2. Compute the masking function of nontonal components and put in LTn()
Common;

% Initialize
if isempty(Tonal_list)
   LTt = [];
else
   LTt = zeros(length(Tonal_list(:, 1)), length(TH(:, 1))) + MIN_POWER;
end
LTn = zeros(length(Non_tonal_list(:, 1)), length(TH(:, 1))) + MIN_POWER;

% Only a subset of the samples are considered for the calculation of the global masking threshold.
for i = 1:length(TH(:, 1))
    zi = TH(i, BARK);  % Critical band rate  
    % Compute the masking function of each tonal component
    if not(isempty(Tonal_list))
        for k = 1:length(Tonal_list(:, 1))
            j  = Tonal_list(k, INDEX);
	        zj = TH(Map(j), BARK); % Critical band rate of the masker
	        dz = zi - zj;          % Distance in Bark to the masker
	      
            % When distance to the masker exceeds the limits [-3,8] barks,
            % the masking fuction is no longer considered.
	        if (dz >= -3 & dz < 8)
                % Masking index
	            avtm = -1.525 - 0.275 * zj - 4.5;
	            % Masking function
	            if (-3 <= dz & dz < -1)
                    vf = 17 * (dz + 1) - (0.4 * X(j) + 6);
                elseif (-1 <= dz & dz < 0)
                    vf = (0.4 * X(j) + 6) * dz;
                elseif (0 <= dz & dz < 1)
                    vf = -17 * dz;
                elseif (1 <= dz & dz < 8)
                    vf = - (dz - 1) * (17 - 0.15 * X(j)) - 17;
                end 
                LTt(k, i) = Tonal_list(k, SPL) + avtm + vf;
            end
        end
   end
   
   
   % Compute the masking function of each nontonal component
   for k = 1:length(Non_tonal_list(:, 1))
       j  = Non_tonal_list(k, INDEX);
       zj = TH(Map(j), BARK); % Critical band rate of the masker
       dz = zi - zj;          % Distance in Bark to the masker
      
       if (dz >= -3 & dz < 8)       
           % Masking index
           avnm = -1.525 - 0.175 * zj - 0.5;
           % Masking function
           if (-3 <= dz & dz < -1)
               vf = 17 * (dz + 1) - (0.4 * X(j) + 6);
           elseif (-1 <= dz & dz < 0)
               vf = (0.4 * X(j) + 6) * dz;
           elseif (0 <= dz & dz < 1)
               vf = -17 * dz;
           elseif (1 <= dz & dz < 8)
               vf = - (dz - 1) * (17 - 0.15 * X(j)) - 17;
           end
           LTn(k, i) = Non_tonal_list(k, SPL) + avnm + vf;
       end
   end
end