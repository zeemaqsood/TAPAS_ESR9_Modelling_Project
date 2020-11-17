function [groups, start_vars] = Groups(Var)

% Groups:
% 
% This function group all available variables into groups of which the base
% elements are limited.
% 
% See also:
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

global eqns Vars constants;

% n is the number of Variables, m is the number of equations
n = size(Vars, 1);
m = size(eqns, 2);

% Let dum be an array of every reaction, having two rows where the top row
% is for the forward reactions, the bottom row is for the backward reactions
dum = [1:m; -1:-1:-m];
%transposing the matrix so that each row has a) forward, b) backward
%reaction instead of column-wise, as was so previously before transposition
dum = transpose(dum(:));

i = 1;

% Let unused be a cell where each element is the start of every reaction
unused = cell(2 * m, 2);
for k = dum
    %Equation to solve, specified as a symbolic expression or symbolic equation. 
    %The relation operator == defines symbolic equations. If eqn is a symbolic expression (without the right side), 
    %the solver assumes that the right side is 0, and solves the equation eqn == 0.
    b = eqns{abs(k)};
    if k > 0 % for forward reaction
        if size(b{1}, 2) >= 2 || (size(b{1}, 2) == 1 && size(b{2}, 2) == 1)
            unused{i, 1} = b{1}(~ismember(b{1}, constants));
            unused{i, 2} = b{2}(~ismember(b{2}, constants));
            
            i = i + 1;
        end
        
    else % for backward reaction
        if size(b{2}, 2) >= 2 || (size(b{1}, 2) == 1 && size(b{2}, 2) == 1)
            unused{i, 1} = b{2}(~ismember(b{2}, constants));
            unused{i, 2} = b{1}(~ismember(b{1}, constants));
            
            if size(b{2}, 2) >= 2 && any(~ismember(b{2}, constants))
                start_vars = start_vars(start_vars ~= b{1});
            end
            
            i = i + 1;
        end
    end
end

unused = unused(1:i - 1, :);

groups = num2cell(1:n);

if ~isempty(constants)
    groups{constants} = [];
end

for i = 1:size(unused, 1)
    a = unused(i, :);
        
    for j = 1:length(a{1})
        groups{a{1}(j)} = [groups{a{1}(j)}, a{2}];
    end
end

for i = 1:n
    j = 1;
    
    while j <= length(groups{i})
        groups{i} = unique([groups{i}, groups{groups{i}(j)}]);
        
        j = j + 1;
    end
end

start_vars = [];

for i = 1:n
    a = 1:n;
    
    if ~ismember(i, constants) && ~ismember(i, [groups{a(a ~= i)}])
        start_vars = [start_vars, i];
    end
end

a = 1:n;
a = a(~ismember(a, constants));

while any(~ismember(a, [groups{start_vars}]))
    c = a(~ismember(a, [groups{start_vars}]));
    start_vars = [start_vars, c(1)];
end

if exist('Var', 'var')
    groups = groups{Var};
else
    
    groups = groups(start_vars);
end
end