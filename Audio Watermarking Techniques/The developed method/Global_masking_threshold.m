function  LTg = Global_masking_threshold(LTq, LTt, LTn)
%   Step 5: Calculation of global masking threshold
%   Sum all individual masking theshold and the threshold in quiet.

Common;

if not(isempty(LTt))
    m = length(LTt(:, 1));
end
n = length(LTn(:, 1)); % Actually non-tonal list won't be empty anyway.
   
% As mentioned above, only a subset of the samples are considered for the calculation of the
% global masking threshold, see Table_absolute_threshold.m.
for i = 1 : length(LTq(:, 1))
    % Threshold in quiet
    temp = 10^(LTq(i) / 10); 
    % Tonal components' contribution
    if not(isempty(LTt))
        for j = 1 : m
            temp = temp + 10^(LTt(j, i) / 10);
        end
    end
    % Nontonal components' contribution
    for j = 1 : n
        temp = temp + 10^(LTn(j, i) / 10);
    end
    LTg(i) = 10 * log10(temp);
end
