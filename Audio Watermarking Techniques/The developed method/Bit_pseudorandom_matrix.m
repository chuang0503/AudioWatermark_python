function MA = Bit_pseudorandom_matrix(Bsub,Positions,PNs)   
% For every pattern block, MA = MB.*MPR  

Parameter_embedding;

temp = zeros(1,N_tiles);

%  The first N_wtiles positions are used for embedding watermark bits. 
for i = 1 : N_wtiles      
    if i <= tiles_w                               % the first bit
        j = 1; 
        temp(Positions(i)) = PNs(i) * Bsub(j);
    elseif i <= ( 2*tiles_w )                     % the second bit
        j = 2;
        temp(Positions(i)) = PNs(i) * Bsub(j);
    elseif i <= ( 3*tiles_w )                     % the third bit
        j = 3;
        temp(Positions(i)) = PNs(i) * Bsub(j);
    else                                          % the fourth bit
        j = 4;
        temp(Positions(i)) = PNs(i) * Bsub(j);
    end
end

% The rest tiles are for embedding the sync bit.
for j = (i+1) : N_tiles              
    temp(Positions(j)) = PNs(j) * 1;         % Bs = 1
end

% Generate MA
k = 1;
for i = 1 : N_s
    for j = 1 : N_u
        MA(i,j) = temp(k); 
        k = k + 1 ;
    end
end 

return;