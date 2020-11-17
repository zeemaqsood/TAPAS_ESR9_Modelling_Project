function eqns_nums = vars2nums(eqns_vars)

global Vars;

if iscell(eqns_vars)
    eqns_nums = cell(size(eqns_vars));
    
    for i = 1:length(eqns_vars)
        eqns_nums{i} = vars2nums(eqns_vars{i});
        % disp(eqns_nums(i));
    end
else
    
    % For every variable in Vars, set that variable equal to the number when it
    % occurs
    for i = 1:size(Vars, 1)
        eval(strcat(Vars(i), " = ", num2str(i), ";"));
    end
    
    if isstring(eqns_vars)
        eqns_nums = zeros(size(eqns_vars));
        
        for i = 1:length(eqns_vars)
            eqns_nums(i) = eval(eqns_vars(i));
            % disp(eqns_nums(i));
        end
        
    elseif ischar(eqns_vars)
        eqns_nums = eval(string(eqns_vars));
        
    else
        eqns_nums = eqns_vars;
    end
end