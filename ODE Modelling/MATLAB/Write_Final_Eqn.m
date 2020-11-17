function final_eqn = Write_Final_Eqn(Type, vars)

% Write_final_eqn:
%
% This function will take the eqns from Modeln and will find the equations
% which instruct how much of every variable there can be as there is a
% limited amount of some variables. i.e. in a cell there are always a
% certain number of receptors, whether they are bound to something or not
% they are still counted.
%
% See also: Modeln, Groups
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1


% Pull over what variables are required from the Modeln function
global IVs eqns Vars n;

% Let m be the number of equations and v the number of constant variables.
m = size(eqns, 2);

% Group any variables together which share some element.
[groups, ~] = Groups;

% Set all variables in Vars to be sym
for i = 1:n
    eval(strcat(Vars{i},' = sym(Vars{i})', ";"));
end

% Create an empty string for each group of elements
if Type == "Max_Num"
    final_eqn = zeros(size(groups, 2), length(vars));
else
    final_eqn = strings(size(groups, 2), 1);
end
f = 1;

% Cycle through all the groups
for i = 1:size(groups, 2)
    % If the group has more than one element
    if size(groups{i}, 2) ~= 1
        % Create a set of equations whcih we will use in solve
        eqn = sym('eqn', [1, m + 1]);
        
        % Let the first equation be the start_vars in the group to one
        % Start_vars is always the first of the group. There will also only
        % be one start_vars in each group
        eqn(1) = eval(strcat(Vars(groups{i}(1)), " == ", num2str(1)));
        
        h = 2;
        % Cycle through all equations
        for j = 1:m
            b = eqns{j};
            
            % The forward reaction creates a product, and there is an
            % element in the product which is in group{i}
            if size(b{1}, 2) >= size(b{2}, 2) && any(ismember(groups{i}, b{2}))
                g = 1;
                % Create a sum of all outgoing variables
                for k = 1:size(b{1}, 2)
                    if ismember(b{1}(k), groups{i})
                        if g == 1
                            dum1 = Vars{b{1}(k)};
                            g = g + 1;
                        else
                            dum1 = strcat(dum1, " + ", Vars(b{1}(k)));
                            g = g + 1;
                        end
                    end
                end
                
                % Create a sum of all products of the reaction
                for k = 1:size(b{2}, 2)
                    if k == 1
                        dum2 = Vars{b{2}(k)};
                    else
                        dum2 = strcat(dum2, " + ", Vars(b{2}(k)));
                    end
                end
                
                % There must be the same amount of start_vars in both sides
                % of equations, so create an equation as such
                eqn(h) = eval(strcat(dum1, " == ", dum2));
                h = h + 1;
                
                % If backwards reaction creates a product, and there is an
                % element in the product which is in group{i}, do the same as
                % above in reverse.
            elseif size(b{1}, 2) <= size(b{2}, 2) && any(ismember(groups{i}, b{1}))
                g = 1;
                for k = 1:size(b{2}, 2)
                    if ismember(b{2}(k), groups{i})
                        if g == 1
                            dum1 = Vars{b{2}(k)};
                            g = g + 1;
                        else
                            dum1 = strcat(dum1, " + ", Vars(b{2}(k)));
                            g = g + 1;
                        end
                    end
                end
                
                for k = 1:size(b{1}, 2)
                    if k == 1
                        dum2 = Vars{b{1}(k)};
                    else
                        dum2 = strcat(dum2, " + ", Vars(b{1}(k)));
                    end
                end
                
                eqn(h) = eval(strcat(dum1, " == ", dum2));
                h = h + 1;
            end
        end
        
        % Solve all equations to find how many start_vars each variable
        % corresponds to
        S = solve(eqn(1:h - 1));
        
        a = groups{i};
        total = 0;
        
        % Create a total, which writes the amount of start_vars at the
        % start. Set this equal to an equation involving all variables
        % involved and how much each corresponds to start_vars
        if Type == "Matlab"
            total = total + IVs(a(1)) * eval(strcat("S.", Vars(a(1))));
            dum = strcat(sim2str(eval(strcat("S.", Vars(a(1))))), " * ", Vars(a(1)));
            
            for k = 2:size(a, 2)
                total = total + IVs(a(k)) * eval(strcat("S.", Vars(a(k))));
                dum = strcat(dum, " + ", sim2str(eval(strcat("S.", Vars(a(k))))), " * ", Vars(a(k)));
            end
            
            final_eqn(f) = strcat(dum, " == ", num2str(eval(total)));
            f = f + 1;
            
        elseif Type == "Latex"
            total = strcat(sim2str(eval(strcat("S.", Vars(a(1))))), " * IV(1)");
            dum = strcat(sim2str(eval(strcat("S.", Vars(a(1))))), " * var(", num2str(a(1)), ")");
            
            for k = 2:size(a, 2)
                total = strcat(total, " + ", sim2str(eval(strcat("S.", Vars(a(k))))), " * IV(", num2str(k), ")");
                dum = strcat(dum, " + ", sim2str(eval(strcat("S.", Vars(a(k))))), " * var(", num2str(a(k)), ")");
            end
            
            final_eqn(f) = strcat(dum, " == ", total);
            f = f + 1;
            
        elseif Type == "Max_Num"
            if any(ismember(vars, groups{i}))
                total = total + IVs(a(1)) * eval(strcat("S.", Vars(a(1))));
                
                for k = 2:size(a, 2)
                    total = total + IVs(a(k)) * eval(strcat("S.", Vars(a(k))));
                end
                
                for k = 1:length(vars)
                    if ismember(vars(k), groups{i})
                        varnum = eval(sim2str(eval(strcat("S.", Vars(vars(k))))));
                        final_eqn(f, k) = total/varnum;
                        
                    end
                end
                
            else
                final_eqn(f, k) = NaN;
            end  
            f = f + 1;
        end
    end
end

final_eqn = final_eqn(1:f - 1, :);
end
