function K_units = K_Var_units

global eqns K catalysts

sizes = ["y", "z", "a", "f", "p", "n", "u", "m", "", "K", "M", "G", "T", "P", "E", "Z", "Y"];

K_units = 2 * ones(size(K));

for i = 1:length(eqns)
    eqn = eqns{i};
    
    k = eqn{3};
        
    if K(k, 1) ~= 0 && K_units(k, 1) == 2
        f = catalysts{2}(catalysts{1} == i);
         
        s = 1 - length(eqn{1}) - length(f);
                
        K_units(k, 1) = s;
    end
    
    if K(k, 2) ~= 0 && K_units(k, 2) == 2
        f = catalysts{2}(catalysts{1} == -i);
        
        s = 1 - length(eqn{2})- length(f);
                
        K_units(k, 2) = s;
    end
end

K_units(K_units == 2) = 0;
end