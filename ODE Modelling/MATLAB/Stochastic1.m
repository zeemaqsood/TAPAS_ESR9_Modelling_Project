function Stochastic1(model, T)

global K IVs eqns constants multiples catalysts
% global Model_names Plot_Vars Vars unit T_unit PlotVars

Models(model, 'N');

runs = 10000;
steps = 100;

number = size(IVs, 1);

Time = zeros(steps, number + 1, runs);
Time(1, :, :) = [0, transpose(IVs)] .* ones(1, number + 1, runs);

Plactivated = zeros(steps, 2);
Plactivated(1, :) = [0, 0];

for i = 1:steps
    Time(i + 1, :, :) = Time(i, :, :);
    Time(i + 1, 1, :) = i * T/steps;
    
    ps = nan(size(eqns, 2) * 2, length(IVs), runs);
    
    for j = 1:length(IVs)
        if ~ismember(j, constants)
            for k = 1:size(eqns, 2)
                if ismember(j, eqns{k}{1})
                    a = eqns{k}{1};
                    
                    kval = K(eqns{k}{3}, 1);
                    mult = multiples{2}(multiples{1} == k);
                    cats = catalysts{2}(catalysts{1} == k);
                    
                    if isempty(mult)
                        ps(2 * (k - 1) + 1, j, :) = kval * T/steps;
                    else
                        ps(2 * (k - 1) + 1, j, :) = kval * mult * T/steps;
                    end
                    
                    for m = 1:length(a)
                        if a(m) ~= j
                            ps(2 * (k - 1) + 1, j, :) = ps(2 * (k - 1) + 1, j, :) .* Time(i + 1, a(m) + 1, :);
                        end
                    end
                    
                    for m = 1:length(cats)
                        ps(2 * (k - 1) + 1, j, :) = ps(2 * (k - 1) + 1, j, :) .* Time(i + 1, cats{m} + 1, :);
                    end
                end
                
                if ismember(j, eqns{k}{2})
                    a = eqns{k}{2};
                    
                    kval = K(eqns{k}{3}, 2);
                    mult = multiples{2}(multiples{1} == -k);
                    cats = catalysts{2}(catalysts{1} == -k);
                    
                    if isempty(mult)
                        ps(2 * k, j, :) = kval * T/steps;
                    else
                        ps(2 * k, j, :) = kval * mult * T/steps;
                    end
                    
                    for m = 1:length(a)
                        if a(m) ~= j
                            ps(2 * k, j, :) = ps(2 * k, j, :) .* Time(i + 1, a(m) + 1, :);
                        end
                    end
                    
                    for m = 1:length(cats)
                        ps(2 * k, j, :) = ps(2 * k, j, :) .* Time(i + 1, cats{m} + 1, :);
                    end
                end
            end
        end
    end
    
    prob = zeros(2 * size(eqns, 2), length(IVs), runs);
    
    for j = 1:length(IVs)
        n = sum(~isnan(ps(:, j, 1)), 1);
        
        for k = 1:2 * size(eqns, 2)
            if ~isnan(ps(k, j, :))
                for i1 = 1:n
                    list = perms([zeros(n - i1), ones(i1 - 1)]);
                    
                    for j1 = size(list, 1)
                        t = (1/i1) * size(list, 1) * ones(1, 1, runs);
                        h = 1;
                        
                        for k1 = 1:2 * size(eqns, 2)
                            g = 1;
                            if k1 ~= k && ~isnan(ps(k1, j, 1))
                                if list(j1, g) == 0
                                    t = t .* (1 - ps(k1, j, :));
                                    g = g + 1;
                                    
                                else
                                    t = t .* ps(k1, j, :);
                                    g = g + 1;
                                end
                            end
                        end
                        
                        prob(k, j, :) = prob(k, j, :) + t;
                    end
                end
                
                prob(k, j, :) = ps(k, j, :) .* prob(k, j, :);
            else
                prob(k, j, :) = NaN;
            end
        end
    end
    
    rs = rand(size(eqns, 2) * 2, 1, runs);
    test = nan(size(eqns, 2) * 2, max(max(sum(~isnan(ps), 2))), runs);
    
    for k = 1:size(eqns, 2)
        h = 1;
        g = 1;
        
        for j = 1:length(IVs)
            if ~isnan(prob(2 * k - 1, j, :))
                test(2 * k - 1, h, :) = binoinv(rs(2 * k - 1, 1, :), Time(i, j + 1, :), min(prob(2 * k - 1, j, :), 1));
                h = h + 1;
            end
            
            if ~isnan(prob(2 * k, j, :))
                test(2 * k, g, :) = binoinv(rs(2 * k, 1, :), Time(i, j + 1, :), min(prob(2 * k, j, :), 1));
                g = g + 1;
            end
        end
    end
end
h = 1;
%     Time(i + 1, :, :) = Time(i, :, :);
%     Time(i + 1, 1, :) = i * T/steps;
%
%     for j = 1:length(IVs)
%         ps = zeros(size(eqns, 2) * 2, Time(i + 1, j, :), runs);
%         rs = rand(size(eqns, 2) * 2, Time(i + 1, j, :), runs);
%
%         if ~ismember(j, constants)
%             for k = 1:size(eqns, 2)
%                 if ismember(j, eqns{k}{1})
%                     a = eqns{k}{1};
%
%                     kval = K(eqns{k}{3}, 1);
%                     mult = multiples{2}(multiples{1} == k);
%                     cats = catalysts{2}(catalysts{1} == k);
%
%                     if isempty(mult)
%                         ps(2 * (k - 1) + 1, :, :) = kval * T/steps;
%                     else
%                         ps(2 * (k - 1) + 1, :, :) = kval * mult * T/steps;
%                     end
%
%                     for m = 1:length(a)
%                         if a(m) ~= j
%                             ps(2 * (k - 1) + 1, :, :) = ps(2 * (k - 1) + 1, :, :) .* Time(i + 1, a(m) + 1, :);
%                         end
%                     end
%
%                     for m = 1:length(cats)
%                         ps(2 * (k - 1) + 1, :, :) = ps(2 * (k - 1) + 1, :, :) .* Time(i + 1, cats{m} + 1, :);
%                     end
%                 end
%
%                 if ismember(j, eqns{k}{2})
%                     a = eqns{k}{2};
%
%                     kval = K(eqns{k}{3}, 2);
%                     mult = multiples{2}(multiples{1} == -k);
%                     cats = catalysts{2}(catalysts{1} == -k);
%
%                     if isempty(mult)
%                         ps(2 * k, :, :) = kval * T/steps;
%                     else
%                         ps(2 * k, :, :) = kval * mult * T/steps;
%                     end
%
%                     for m = 1:length(a)
%                         if a(m) ~= j
%                             ps(2 * k, :, :) = ps(2 * k, :, :) .* Time(i + 1, a(m) + 1, :);
%                         end
%                     end
%
%                     for m = 1:length(cats)
%                         ps(2 * k, :, :) = ps(2 * k, :, :) .* Time(i + 1, cats{m} + 1, :);
%                     end
%                 end
%
%                 if rs < ps
%
%                 end
%             end
%         end
%     end
% end
end

