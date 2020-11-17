function n = how_many_in(var1, vars2)

global Vars eqns;

%If you do not want one of the outputs of a function, then you can replace it with the ~ symbol:
[group, ~] = Groups(var1);

% Set all variables in Vars to be sym
for i = 1:size(Vars, 1)
    %eval(expression,catch_expr) executes expression and, if an error is detected, executes the catch_expr string. 
    eval(strcat(Vars{i},' = sym(Vars{i})', ";"));
end

n = zeros(1, length(vars2));

for i = 1:length(vars2)
    var2 = vars2(i);
    
    if ismember(var2, group)
        % Create a set of equations whcih we will use in solve
        eqn = sym('eqn', [1, size(eqns, 2) + 1]);
        
        % Let the first equation be the start_vars in the group to one
        % Start_vars is always the first of the group. There will also only
        % be one start_vars in each group
        eqn(1) = eval(strcat(Vars(var1), " == ", num2str(1)));
        
        h = 2;
        % Cycle through all equations
        for j = 1:size(eqns, 2)
            b = eqns{j};
            
            % The forward reaction creates a product, and there is an
            % element in the product which is in group{i}
            if size(b{1}, 2) >= size(b{2}, 2) && any(ismember(group, b{2}))
                g = 1;
                % Create a sum of all outgoing variables
                for k = 1:size(b{1}, 2)
                    if ismember(b{1}(k), group)
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
                    if ismember(b{2}(k), groups)
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
        
        eval(strcat("n(i) = S.", Vars(var2), ";"));
    else
        n(i) = 0;
    end
end
end
