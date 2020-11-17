function S = Steady_States(model, varargin)

% Steady_States:
%
% This function will return to steady state(s) of the model specified
%
% See also: Models, Write_eqns
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

if model ~= 0
    Models(model, 'N');
end

% Find the ODE's for the models
dydt = Write_Eqns("Stable");

global Vars units IVs;

n = size(Vars, 1);

for i = 1:n
    eval(strcat(Vars{i},' = sym(Vars{i})', ';'));
end

eqns = sym('eqns', [1, n + size(dydt, 1)]);

% All parameters must be positive as well
for i = 1:n
    eqns(2 * i - 1) = eval(dydt(i));
    eqns(2 * i) = eval(Vars{i}) >= 0;
end

for i = 1:size(dydt, 1) - n
    eqns(2 * n + i) = eval(dydt(n + i));
end

% Solve the ODE's equal to zero and the 'Final eqns'
S = solve(eqns, Vars, 'ReturnConditions', true);

% Evaluate any solutions which were returned as polynomials
if isempty(S.parameters)
    for i = 1:size(Vars, 1)
        eval(strcat("S." , Vars(i), " = eval(", strcat("vpa(S.", Vars(i), ")"), ");"));
    end

    n = eval(strcat("size(S.", Vars{1}, ", 1)"));

    SS = strings(length(Vars), n);

    for i = 1:size(Vars, 1)
        SS(i, :) = transpose(strcat(num2str(eval(strcat("S." , Vars(i)))), " ", units, "M"));
    end

    T = table(Vars, SS);
else    
    if model == 0 && isempty(varargin)
        S = [];
    else
        T = Time_to_SS(varargin{1}, "false");
        [~, y] = ode15s(@ODEs, [0, T], IVs);
        
        S = struct();
        for i = 1:size(Vars, 1)
            eval(strcat("S." , Vars(i), " = max(0, y(end, i));"));
        end
    end
end
end
