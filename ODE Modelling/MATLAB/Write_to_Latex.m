function Write_to_Latex(model)

% write_to_latex:
%
% This function takes the input of a number, and will return, in the
% command window the differential equations which can be copy and pasted
% into latex.
%
% See also: Modeln, Write_final_latex_eqn
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1


% Evaluate the model as in the input
Models(model, 'N');

% Bring the necessary variable over from the Modeln function
global Plot_Vars IVs K eqns multiples constants catalysts n;

% Create an empty string for where the differential equations will be kept
dydt = strings(n, 1);

% m1 is the number of equations
m1 = size(eqns, 2);

% Cycle through every term in the ODE
for i = 1:m1
    % Consider the ith term
    b = eqns{i};
    
    n1 = size(b{1}, 2);
    n2 = size(b{2}, 2);
    
    % Define which k value we are working with. Work with kval as opposed
    % to k as later we use contains k_ which occurs more than just for k.
    dum1 = strcat('kval(', num2str(2 * b{3}(1)), ')');
    
    % Multiply by any variables in the term. Use val instead of variable
    % name, we will convert val to names later.
    for j = 1:n1
        dum1 = strcat(dum1, " * var(", num2str(b{1}(j)), ')');
    end
    
    % If a catalyst is involved in the forward reaction, multiply the term
    % by such catalyst
    if ismember(i, catalysts{1})
        
        a1 = catalysts{2}(catalysts{1} == i);
        
        a2 = a1{1};
                
        dum1a = strcat("var(", num2str(a2(1)), ")");
        
        for k1 = 2:size(a2, 1)
            dum1a = strcat(dum1a, " * var(", num2str(a2(k1)), ")");
        end
        
        if size(a1, 1) ~= 1
            dum1a = strcat("(", dum1a);
            
            for k = 2:size(a1, 1)
                dum1a = strcat(dum1a, " + var(", num2str(a1{k}(1)), ")");
                
                for k1 = 2:size(a1{k}, 1)
                    dum1a = strcat(dum1a, " * var(", num2str(a1{k}(k1)), ")");
                end
            end
            
            dum1a = strcat(dum1a, ")");
        end
        
        dum1 = strcat(dum1, " * ", dum1a);
    end


    % Repeat for the reverse reaction
    dum2 = strcat('kval(', num2str(2 * b{3}(1) - 1), ')');
    
    for k = 1:n2
        dum2 = strcat(dum2, " * var(", num2str(b{2}(k)), ')');
    end
        
    if ismember(-i, catalysts{1})        
        a1 = catalysts{2}(catalysts{1} == -i);
        
        a2 = a1{1};
                
        dum2a = strcat("var(", num2str(a2(1)), ")");
        
        for k1 = 2:size(a2, 1)
            dum2a = strcat(dum2a, " * var(", num2str(a2(k1)), ")");
        end
        
        if size(a1, 1) ~= 1
            dum2a = strcat("(", dum2a);
            
            for k = 2:size(a1, 1)
                dum2a = strcat(dum2a, " + var(", num2str(a1{k}(1)), ")");
                
                for k1 = 2:size(a1{k}, 1)
                    dum2a = strcat(dum2a, " * var(", num2str(a1{k}(k1)), ")");
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
    
    % Add the reverse reaction, dum2, and take away the forward reaction,
    % dum1
    for j = 1:n1
        h = b{1}(j);
        dydt(h) = strcat(dydt(h), " - ", dum1, " + ", dum2);
    end
    
    % Repeat for the reverse action, with reverse signs
    for k = 1:n2
        h = b{2}(k);
        dydt(h) = strcat(dydt(h), " + ", dum1, " - ", dum2);
    end
end

% Create var and kval to be sym variables so we can write them as inputs to
% the latex function
var = sym('var', [n, 1]);
IV = sym('IV', [n, 1]);
kval = sym('kval', [2 * size(K, 1), 1]);
dydt(dydt == "") = "0 * var(1)";

% Convert all differential equations to latex form and put them equal to
% d(var)/dt in latex form.
for i = 1:n
    dydt(i) = strcat("\frac{d", Plot_Vars{i}, "}{dt} = ", latex(eval(dydt(i))));
end

% If any variables are assumed to be constant, change their differential to
% zero. This means that the variables is always equal to its initial value.
% Convert the equation to latex form
for g = 1:length(constants)
    h = constants(g);
    dydt(h) = latex(eval(strcat('var(', num2str(h), ") == ", num2str(IVs(h)))));
end

% Create the extra equations formed by there being a limited supply of some
% variables in the system
final_eqn = Write_Final_Eqn("Latex");

% Convert these equations to latex form
for i = 1:size(final_eqn, 1)
    final_eqn(i) = latex(eval(final_eqn(i)));
end

dydt = [dydt; final_eqn];

% Comvert all variables to formal variables and kval's to k_'s.
for i = 1:size(dydt, 1)
    for j = 1:n
        % If the term still contains {var}_{j}, then replace it with the
        % correct variable name
        while contains(dydt(i), strcat('{var}_{', num2str(j),'}'))
            dydt(i) = strcat(extractBefore(dydt(i), strcat('{var}_{', num2str(j),'}')), '{', Plot_Vars{j}, '}', extractAfter(dydt(i), strcat('{var}_{', num2str(j),'}')));
        end
    end
    
    for j = 1:2 * size(K, 1)
        % If the term still contains kval_{j} then replace it with the
        % correct k_n. If j is even, n = j/2. If n is odd, n = - ceil(j/2).
        % This has been done as arrays do not allow negative indices
        while contains(dydt(i), strcat('{kval}_{', num2str(j),'}'))
            if j/2 == floor(j/2)
                j1 = j/2;
                dydt(i) = strcat(extractBefore(dydt(i), strcat('{kval}_{', num2str(j),'}')), '{k}_{', num2str(j1), '}', extractAfter(dydt(i), strcat('{kval}_{', num2str(j),'}')));
            else
                j1 = - ceil(j/2);
                dydt(i) = strcat(extractBefore(dydt(i), strcat('{kval}_{', num2str(j),'}')), '{k}_{', num2str(j1), '}', extractAfter(dydt(i), strcat('{kval}_{', num2str(j),'}')));
            end
        end
    end
    
    for j = 1:n
        % If the term still contains kval_{j} then replace it with the
        % correct k_n. If j is even, n = j/2. If n is odd, n = - ceil(j/2).
        % This has been done as arrays do not allow negative indices
        while contains(dydt(i), strcat('{IV}_{', num2str(j),'}'))
            dydt(i) = strcat(extractBefore(dydt(i), strcat('{IV}_{', num2str(j),'}')), "{", Plot_Vars{j}, "}_{IV}" , extractAfter(dydt(i), strcat('{IV}_{', num2str(j),'}')));
        end
    end
    
    % Between every variable, place a cdot to distinguish where one
    % variable ends and another begins
    while contains(dydt(i), '\,')
        dydt(i) = strcat(extractBefore(dydt(i), '\,'), '\cdot', extractAfter(dydt(i), '\,'));
    end
    
    % Any variables which are squared, cubed or any higher powers, place
    % brackets round the variable to indicate as such
    v = strfind(dydt(i), '}}^') + 3;
    
    for j = 1:size(v, 2)
        temp = char(dydt(i));
        b = strfind(temp(v(j):-1:1), "{todc") - 1;
        temp = temp(v(j) - b(1):v(j) - 2);
        dydt(i) = strcat(extractBefore(dydt(i), temp), "(", temp, ")", extractAfter(dydt(i), temp));
    end
end

% Display in command window what must be copied to Latex
for i = 1:size(dydt, 1)
    disp("\begin{equation}");
    disp(dydt(i));
    disp("\end{equation}");
end
end