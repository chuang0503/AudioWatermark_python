function image = Array_to_image(array)

image = [];
% Each letter is represented as a 7 by 5 matix.
letter_row = 7;              
letter_column = 5; 
letter_size = letter_row * letter_column;  

N_array = length(array);
if mod(N_array, letter_size) ~= 0
    error('Worng length');
end
margin = zeros(letter_row,1);   

N_character = N_array/letter_size;
for i = 1 : N_character
    letter = [];
    m = (i - 1) * letter_size + 1;
    for j = 1 : letter_row
        n_s = m + (j-1) * letter_column;
        n_e = n_s + letter_column - 1;
        letter(j,:) = array(n_s : n_e);
    end
    image = [ image, letter, margin];
end
image = [margin, image];
     
return;

