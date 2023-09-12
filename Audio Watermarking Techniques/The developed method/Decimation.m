function [DFlags, DTonal_list, DNon_tonal_list] = Decimation(X, Tonal_list, Non_tonal_list, Flags, TH, Map)
%   Step 3: Decimation of the invalid tonal and non-tonal maskers
%   1. Components below the threshold in quiet are removed.
%   2. Tonal components within a distance less than 0.5Bark are disposed.
Common;

DFlags = Flags; % Flags after decimation

% Components are not considered if lower than the absolute threshold of hearing found in TH(:, ATH).
% For non-tonal components
DNon_tonal_list = [];
Dnt = [];
DntSPL = [];
count = 1;
if not(isempty(Non_tonal_list))
    for i = 1:length(Non_tonal_list(:, 1))
        k = Non_tonal_list(i, INDEX);
        if (Non_tonal_list(i, SPL) < TH(Map(k), ATH))
            DFlags(k) = IRRELEVANT;
            Dnt(count) = k;
            DntSPL(count) = Non_tonal_list(i, SPL);
            count = count + 1;
        else
            DNon_tonal_list = [DNon_tonal_list; Non_tonal_list(i, :)];
        end
    end
end

% For tonal components 
count = 1;
Dt = [];
DtSPL = [];
DTonal_list = [];
if not(isempty(Tonal_list))
    for i = 1:length(Tonal_list(:, 1))
        k = Tonal_list(i, INDEX);
        if (Tonal_list(i, SPL) < TH(Map(k), ATH))
            DFlags(k) = IRRELEVANT;
            Dt(count) = k;
            DtSPL(count) = Tonal_list(i, SPL); 
            count = count + 1;    
	    else
		    DTonal_list = [DTonal_list; Tonal_list(i, :)];
	    end
    end
end

% Eliminate tonal components that are less than 0.5 Bark from a neighbouring component.
if not(isempty(DTonal_list))
    i = 1;
    while (i < length(DTonal_list(:, 1)))
        k      = DTonal_list(i, INDEX);
        k_next = DTonal_list(i + 1, INDEX);
        if (TH(Map(k_next), BARK) - TH(Map(k), BARK) < 0.5)
            Dt(count) = k_next;
            DtSPL(count) = DTonal_list(i+1, SPL); 
            count = count + 1; 
            if (DTonal_list(i, SPL) < DTonal_list(i + 1, SPL))
                DTonal_list = DTonal_list([1:i - 1, ...
                        i + 1:length(DTonal_list(:, 1))], :);
                DFlags(k) = IRRELEVANT;
            else
                DTonal_list = DTonal_list([1:i, ...
                       i + 2:length(DTonal_list(:, 1))], :);
                DFlags(k_next) = IRRELEVANT;
            end
        else
            i = i + 1;
        end
    end
end