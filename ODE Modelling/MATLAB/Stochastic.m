function Time = Stochastic(model, T)

global K IVs eqns constants multiples catalysts
% global Model_names Plot_Vars Vars unit T_unit PlotVars

Models(model, 'N');

runs = 1000;
steps = 100;

number = size(IVs, 1);

Time = zeros(steps + 1, number + 1, runs);
Time(1, :, :) = [0, transpose(IVs)] .* ones(1, number + 1, runs);

for i = 1:steps
    Time(i + 1, :, :) = Time(i, :, :);
    Time(i + 1, 1, :) = i * T/steps;

    r1 = rand(1, size(eqns, 2), runs);
    r2 = rand(1, size(eqns, 2), runs);
    
    p1 = zeros(1, size(eqns, 2), runs);
    p2 = zeros(1, size(eqns, 2), runs);
    
    n = zeros(1, size(eqns, 2), runs);
    m = zeros(1, size(eqns, 2), runs);
    
    for j = 1:size(eqns, 2)
        a = eqns{j}{1};
        b = eqns{j}{2};
        kval = eqns{j}{3};
        
        mult = multiples{2}(multiples{1} == j);
        cats = catalysts{2}(catalysts{1} == j);
        
        if isempty(mult)
            p1(:, j, :) = K(kval, 1) * T/steps;
        else
            p1(:, j, :) = K(kval, 1) * mult * T/steps;
        end
        
        for k = 2:length(a)
            p1(:, j, :) = p1(:, j, :) .* Time(i + 1, a(k) + 1, :);
        end
        
        for k = 1:length(cats)
            p1(:, j, :) = p1(:, j, :) .* Time(i + 1, cats{k} + 1, :);
        end
        
        
        mult = multiples{2}(multiples{1} == -j);
        cats = catalysts{2}(catalysts{1} == -j);
        
        if isempty(mult)
            p2(:, j, :) = K(kval, 2) * T/steps;
        else
            p2(:, j, :) = K(kval, 2) * mult * T/steps;
        end
        
        for k = 2:length(b)
            p2(:, j, :) = p2(:, j, :) .* Time(i + 1, b(k) + 1, :);
        end
        
        for k = 1:length(cats)
            p2(:, j, :) = p2(:, j, :) .* Time(i + 1, cats{k} + 1, :);
        end
        
        n(:, j, :) = min(binoinv(r1(:, j, :), Time(i, a(1) + 1, :), min(p1(:, j, :), 1)), min(Time(i + 1, a(~ismember(a, constants)) + 1, :), [], 2));
        m(:, j, :) = min(binoinv(r2(:, j, :), Time(i, b(1) + 1, :), min(p2(:, j, :), 1)), min(Time(i + 1, b(~ismember(b, constants)) + 1, :), [], 2));
        Time(i + 1, a(~ismember(a, constants)) + 1, :) = Time(i + 1, a(~ismember(a, constants)) + 1, :) - n(:, j, :) + m(:, j, :);
        Time(i + 1, b(~ismember(b, constants)) + 1, :) = Time(i + 1, b(~ismember(b, constants)) + 1, :) + n(:, j, :) - m(:, j, :);
    end
end
end


