function dydt = Write_Eqns(Type)

% Write_eqns:
%
% This function will take an optional input of model, and returns all the
% differential equations. If model is input, then it will run Modeln and
% then put all equations equal to zero.
%
% See also: Modeln, write_final_eqn
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

% If model exists, run the relevant Modeln

if ~exist('Type', 'var')
    Type = 'Plot';
end

global Vars IVs K eqns constants catalysts n multiples unit K_unit K_units;

units = strings(size(K));
units(:) = K_unit;

Ks = equiv(K, units, unit, K_units);

% Create a string of all differential equations
dydt = strings(n, 1);
m1 = size(eqns, 2);

% Cycle through every term in the ODE
for i = 1:m1
    % Consider the ith term
    b = eqns{i};
    
    n1 = size(b{1}, 2);
    n2 = size(b{2}, 2);
    
    % Define which k value we are working with
    dum1 = num2str(Ks(b{3}(1), 1));
    
    % Multiply by any variables in the term
    for j = 1:n1
        dum1 = strcat(dum1, " * ", Vars(b{1}(j)));
    end
    
    % If a catalyst is involved, multiply by such variable
    if ismember(i, catalysts{1})
        a1 = catalysts{2}(catalysts{1} == i);
        
        a2 = a1{1};

        dum1a = "";

        dum1a = Vars(a1{1}(1));

        for k1 = 2:size(a1{1}, 2)
            dum1a = strcat(dum1a, " * ", Vars(a1{1}(k1)));
        end
            
        if size(a1, 1) ~= 1
            dum1a = strcat("(", dum1a);
            
            for k = 2:size(a1, 1)
                dum1a = strcat(dum1a, " + ", Vars(a1{k}(1)));

                for k1 = 2:size(a1{k}, 1)
                    dum1a = strcat(dum1a, " * ", Vars(a1{k}(k1)));
                end
            end
            
            dum1a = strcat(dum1a, ")");
        end
        
        dum1 = strcat(dum1, " * ", dum1a);
    end
    
    % Repeat for the reverse reaction
    dum2 = num2str(Ks(b{3}(1), 2));
    
    for k = 1:n2
        dum2 = strcat(dum2, " * ", Vars(b{2}(k)));
    end
    
    if ismember(- i, catalysts{1})        
        a1 = catalysts{2}(catalysts{1} == -i);
        
        a2 = a1{1};

        dum2a = "";

        dum2a = Vars(a1{1}(1));

        for k1 = 2:size(a1{1}, 2)
            dum2a = strcat(dum2a, " * ", Vars(a1{1}(k1)));
        end
            
        if size(a1, 1) ~= 1
            dum2a = strcat("(", dum2a);
            
            for k = 2:size(a1, 1)
                dum2a = strcat(dum2a, " + ", Vars(a1{k}(1)));

                for k1 = 2:size(a1{k}, 1)
                    dum2a = strcat(dum2a, " * ", Vars(a1{k}(k1)));
                end
            end
            
            dum2a = strcat(dum2a, ")");
        end
        
        dum2 = strcat(dum2, " * ", dum2a);
    end

    % Check, in both directions, if the term should be multiplied, as it is
    % more likely to occur due to there being multiple possibilities
    mult = multiples{2}(multiples{1} == i);
    
    if ~isempty(mult)
        dum1 = strcat(num2str(mult), " * ", dum1);
    end
    
    mult = multiples{2}(multiples{1} == -i);
        
    if ~isempty(mult)
        dum2 = strcat(num2str(mult), " * ", dum2);
    end

    % For every element in the start of the reaction, add what happens in
    % the reverse reaction and take away what happens in the forward
    % reaction
    for j = 1:n1
        h = b{1}(j);
        dydt(h) = strcat(dydt(h), " - ", dum1, " + ", dum2);
    end
    
    % Repeat for the reverse action, with signs swapped
    for k = 1:n2
        h = b{2}(k);
        dydt(h) = strcat(dydt(h), " + ", dum1, " - ", dum2);
    end
end

% If variable has no terms, set variable equal to its initial value for all
% time. Otherwise set either var' = to the differential equation, or set it
% equal to zero
for i = 1:n
    if Type == "Solve"
        dydt(i) = strcat("diff(", Vars(i), ") == ", dydt(i));
    elseif dydt(i) == ""
        dydt(i) = strcat(Vars(i), " == ", num2str(IVs(i)));
    elseif Type == "Stable"
        dydt(i) = strcat(dydt(i), " == 0");
    else
        dydt(i) = strcat(Vars(i), "' = ", dydt(i));
    end
end

% If any variables are assumed to be constant, set the variable equal to
% its intial value for all time
for g = 1:length(constants)
    h = constants(g);
    if Type == "Solve"
        dydt(h) = strcat("diff(", Vars(h), ") == 0");
    else
        dydt(h) = strcat(Vars(h), " == ", num2str(IVs(h)));
    end
end

% Create the final equation from the fact that there are limited amounts of
% some variables
if Type ~= "Solve"
    final_eqn = Write_Final_Eqn("Matlab");

    dydt = [dydt; final_eqn];
end

end