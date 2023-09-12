function enhanced_image = Coded_image_enhancement(We)

[alphabet,targets] = Prprob;
net = NN;

enhanced_image = [];
% Each letter is represented as a 7 by 5 matix.
letter_row = 7;              
letter_column = 5; 
letter_size = letter_row * letter_column;  

N_We = length(We);
if mod(N_We, letter_size) ~= 0
    error('Worng length');
end

N_character = N_We/letter_size;
for  i = 1 : N_character
    point = (i-1)*letter_size + 1;
    temp(i,:) = We(point : point+letter_size-1);
end

enhanced_array = [];
for i = 1 : N_character
    A1 = sim(net,temp(i,:)'); 
    A2 = compet(A1);     
    answer = find(compet(A2) == 1);
    enhanced_array = [ enhanced_array, alphabet(:,answer)' ];
end

enhanced_image = Array_to_image(enhanced_array);
figure;
imshow(~enhanced_image);

return;