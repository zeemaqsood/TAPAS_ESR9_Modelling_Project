function [a, T_un] = Time_to_SS(models, varargin)

% Time_to_SS:
%
% This function finds the time it takes for every model specified, and any
% variables specified, to reach 99% of the way to its steady state
%
% inputs: models: [1, 2]
%
% options: If variables are specified, it will
%          'Change', if specified, should follow a Type, var and points
%
% See also: ODEs, Models, ode15s
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

sizes = ["y", "z", "a", "f", "p", "n", "u", "m", "", "K", "M", "G", "T", "P", "E", "Z", "Y"];

global Vars IVs K T_unit;

h = 1;
varall = "All";
Points = 't';
Type = "";
KDConst = 0;
modelrun = true;
f = false;

% Check for options
while h <= length(varargin)
    % If an input is numeric, it must be vars
    if isnumeric(varargin{h})
        vars = varargin{h};
        varall = "Some";
        h = h + 1;
        
        % If an options is change, let var be the second after and Points the
        % third after.
    elseif varargin{h} == "Change"
        Type = varargin{h + 1};
        var = varargin{h + 2};
        Points = varargin{h + 3};
        
        % If Type is IV, KD or KD
        if varargin{h + 1} == "IV"
            
        elseif varargin{h + 1} == "K"
            
            if var > 0
                b1 = 1;
            else
                var = - var;
                b1 = -1;
            end
            
        elseif varargin{h + 1} == "KD"
            if var > 0
                b1 = 1;
            else
                var = - var;
                b1 = -1;
            end
        end
        h = h + 4;
    elseif varargin{h} == "KDConst"
        KDConst = 1;
        
        h = h + 1;
        
    elseif varargin{h} == "Accurate"
        f = true;
        h = h + 1;
        
    elseif varargin{h} == "false"
        modelrun = false;
        h = h + 1;
    end
end

a = 0;

% For each model
for i = 1:length(models)
    if modelrun
        Models(models(i), 'N');
    end
    
    KD = K(:, 2)./K(:, 1);
    
    % If no variables were specified
    if varall == "All"
        vars = 1:length(Vars);
    end
    
    % For all points available in change, if change was not specified, run
    % this once
    for j = 1:length(Points)
        % Change the values
        if Type == "IV"
            IVs(var) = Points(j);
            
        elseif Type == "K"
            K(var, 0.5 * (3 - b1)) = Points(j);
            
            if KDConst == 1
                if b1 == 1
                    K(var, 2) = K(var, 1) * KD(var);
                else
                    K(var, 1) = K(var, 2)/KD(var);
                end
            end
            
        elseif Type == "KD"
            KD(var) = Points(j);
            
            if b1 == 1
                K(var, 1) = K(var, 2)/KD(var);
            else
                K(var, 2) = KD(var) * K(var, 1);
            end
        end
        
        % Find the steady states of all variables in the model
        SS = Steady_States(false);
        
        for k = 1:length(vars)
            % Let SS_var be the steady state of variable vars(k)
            if ~isempty(SS)
                SS_var = eval(strcat("SS.", Vars(vars(k))));
            end
            
            T = 1;
            while T ~= 0
                % Run the model and let y equal the output for just the
                % variable
                [t, y] = ode15s(@ODEs, [0, T], IVs);
                y = y(:, vars(k));
                
                if isempty(SS)
                    SS_var = y(end);
                end
                
                % If the start and end are the same, assume the variable is
                % constant and ignore the variable
                if all(y == SS_var)
                    T = 0;
                    
                    % If the distance between the end and the steady state is
                    % smaller than 1% of the start and steady state
                    
                elseif any(abs(y(end) - transpose(SS_var)) <= 0.01 * max(abs(y - transpose(SS_var))))
                    ss = find(abs(y(end) - transpose(SS_var)) <= 0.01 * max(abs(y - transpose(SS_var))));
                    
                    for i1 = 1:size(ss, 2)
                        vec = abs(y - transpose(SS_var(ss(i1)))) <= 0.01 * max(abs(y - transpose(SS_var(ss(i1)))));
                        x = size(vec, 1) - find(~vec(end:-1:1), 1) + 2;

                        % Repeat the above for twice the range to see if the
                        % point found was just passing the steady state value,
                        [t1, y1] = ode15s(@ODEs, [0, 2 * T], IVs);
                        y1 = y1(:, vars(k));

                        % Check for whether there exists a point after the one
                        % found before that is further that 1% from the steady
                        % state
                        z = find(abs(y1(t1 >= t(x)) - transpose(SS_var(ss(i1)))) > 0.01 * max(abs(y - transpose(SS_var))), 1);

                        % If a point exists, move up to the next range
                        if ~isempty(z)
                            T = T * 10;

                            % Set a to be the max of what it already is or the
                            % closest multiple of T/10 up from the value of t(x)
                        else
                            [t1, y1] = ode15s(@ODEs, [0, t(x)], IVs);
                            y1 = y1(:, vars(k));
                            vec = abs(y - SS_var(ss(i1))) <= 0.01 * max(abs(y - SS_var(ss(i1))));
                            x = length(vec) - find(~vec(end:-1:1), 1) + 2;

                            [~, b] = ismember(T_unit, sizes);

                            if f
                                a = max(a, t1(x) * 10^(3 * (b - 9)));
                            else
                                a = max(a, ceil(t1(x) * 10^(-floor(log10(t1(x))))) * 10^(floor(log10(t1(x)))) * 10^(3 * (b - 9)));
                            end
                            T = 0;
                        end
                    end
                    
                else
                    T = T * 10;
                end
            end
        end
    end
end

if a == 0
    a = 1;
    T_un = "";
else
    Log = floor(log10(a)/3);
    T_un = sizes(Log + 9);
    a = a * 10 ^ (- 3 * Log);
end
end