function sign = Sign_expander(MA_column, factor, subbands)
% Determine the signs by stretching MA_column

Parameter_embedding;

temp_sign = factor * MA_column; 
sign = ones(1, N_frame/2); 

% Expander from temp_sign(1:N_s) to sign(1:N_frame/2)  
for i = 1 : N_s
    for j = subbands(2*i-1) : subbands(2*i)
        sign(j) = temp_sign(i);
    end
end

return;