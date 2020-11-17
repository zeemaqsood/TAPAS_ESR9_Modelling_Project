function [coms, sizes] = combos(N, n)
    sizes = factorial(n + N - 1)/(factorial(n + 1 - 1) * factorial(N - 1));

    coms = zeros(sizes, N);
        
    if N == 1
        coms = n;
        
    else
        j = 1;
        
        for i = 0:n
            [vec, sizes2] = combos(N - 1, n - i);
            coms(j:j + sizes2 - 1, :) = [coms; i * ones(sizes2, 1), vec];
            j = j + sizes2;
        end
    end
end