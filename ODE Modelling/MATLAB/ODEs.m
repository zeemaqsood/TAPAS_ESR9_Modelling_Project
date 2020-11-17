function dydt = ODEs(t, v)

% ODEs:
%
% This function will create the function necessary for ode15s. It will take
% the already assigned variables from the Modeln function, and find all
% ordinary differential equations
%
% See also: ode15s
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

global K Vars eqns multiples constants catalysts unit K_unit K_units;

units = strings(size(K));
units(:) = K_unit;

Ks = equiv(K, units, unit, K_units);

% let n be the number of variables and m the number of equations
n = size(Vars, 1);
m = size(eqns, 2);

% Let dydt be the output of the differential equations, one for each
% variable
dydt = zeros(n, 1);

% Cycle through equation
for i = 1:m
    
    % Consider the ith equation
    b = eqns{i};
    
    % Let n1 be the number of elements at the start of the reaction and n2
    % be the number of elements at the end of the equation
    n1 = size(b{1}, 2);
    n2 = size(b{2}, 2);
    
    % Define which k value we are working with
    dum1 = Ks(b{3}(1), 1);
    
    % Multiply by any variables in the start of the reaction
    for j = 1:n1
        dum1 = dum1 * v(b{1}(j));
    end
    
    % If a catlyst is involved, then multiply by the catalyst
    if ismember(i, catalysts{1})
        a1 = catalysts{2}(catalysts{1} == i);
        
        for k = 1:size(a1, 2)
            a2 = transpose(a1{k});
            
            dum1a = 0;
            
            for k1 = 1:size(a2, 1)
                dum1a = dum1a + v(a2(k1));
            end
            
            dum1 = dum1 * dum1a;
        end
    end
    
    % Repeat for the reverse reaction
    dum2 = Ks(b{3}(1), 2);
    
    for k = 1:n2
        dum2 = dum2 * v(b{2}(k));
    end
    
    if ismember(- i, catalysts{1})
        a = catalysts{2}(catalysts{1} == - i);
        
        for k = 1:size(a1, 2)
            a2 = transpose(a1{k});
            
            dum1a = 0;
            
            for k1 = 1:size(a2, 1)
                dum1a = dum1a + v(a2(k1));
            end
            
            dum2 = dum2 * dum1a;
        end
    end
    
    % Check, in both directions, if the term should be multiplied, as it is
    % more likely to occur due to there being multiple possibilities

    mult = multiples{2}(multiples{1} == i);
    
    if ~isempty(mult)
        dum1 = mult * dum1;
    end
    
    mult = multiples{2}(multiples{1} == -i);
        
    if ~isempty(mult)
        dum2 = mult * dum2;
    end
    
    % For every element in the start of the reaction, add what happens in
    % the reverse reaction and take away what happens in the forward
    % reaction
    for j = 1:n1
        h = b{1}(j);
        
        dydt(h) = dydt(h) - dum1 + dum2;
    end
    
    % Repeat for the reverse action, with signs swapped
    for k = 1:n2
        h = b{2}(k);
        
        dydt(h) = dydt(h) + dum1 - dum2;
    end
    
    % If any variables are assumed to be constant, change their
    % differential to zero
    for g = 1:length(constants)
        h = constants(g);
        dydt(h) = 0;
    end
end