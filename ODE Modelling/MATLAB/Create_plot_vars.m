function new_Vars = Create_plot_vars(Vars)

% Create_plot_vars:
%
% This function takes a cell of variables and returns them in a formal
% written approach, so when they are plotted they look nice. Separate
% variables must have a '_' between them i.e. LLRR wouldn't change but
% LL_RR would change to L_{2}R_{2}
%
% See also:
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

% Create a cell of the new variables, the size of the incoming variables
new_Vars = cell(size(Vars, 1), 1);

% For each variable
for i = 1:size(Vars, 1)   
    % Find all occurences of '_' in the variable
    v = [0, strfind(Vars{i}, '_'), size(Vars{i}, 2) + 1];
    
    % Create a cell for each part of the word between '_''s.
    dum = cell(2, size(v, 2) - 1);
    % Set the newword to be emtpty at first
    new_Vars{i} = '';
    
    % For each part of the word
    for j = 1:size(v, 2) - 1
        % Let p be half, or just under half the length of the word,
        % depending if the word is an odd or even length
        p = floor((v(j + 1) - v(j) - 1)/2);
        k = 1;
        
        while k <= p
            % Let a equal the amount of times the word of length k occurs
            a = length(strfind(Vars{i}(v(j) + 1:v(j + 1) - 1), Vars{i}(v(j) + 1:v(j) + k)));
            
            % If the word is repeated throughout the whole word, then this
            % is the repeated word
            if a * k == v(j + 1) - v(j) - 1
                dum{1, j} = Vars{i}(v(j) + 1:v(j) + k);
                dum{2, j} = a;
                k = p + 2;
            else
                k = k + 1;
            end
        end
 
        % If k == p + 1 no repeated word occurs, so set the word to it solo
        if k == p + 1
            dum{1, j} = Vars{i}(v(j) + 1:v(j + 1) - 1);
            dum{2, j} = 1;
        end
        
        % For every word, if a number occurs, change it to subscript of
        % said number. Now rejoin all shorter words to the bigger word
        for k = 1:size(dum{1, j}, 2)
            if ~isnan(str2double(dum{1, j}(k)))
                new_Vars{i} = strcat(new_Vars{i}, '_{', num2str(dum{1, j}(k)), '}');
            else
                new_Vars{i} = strcat(new_Vars{i}, dum{1, j}(k));
            end
        end
        
        % If word occurs more than once, create an indicy of how many times
        % the word occurs
        if dum{2, j} > 1
            new_Vars{i} = strcat(new_Vars{i}, '^{', num2str(dum{2, j}), '}');
        end
    end
end

