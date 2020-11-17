function [R, LRs] = stoch(R, LR, LRs, k)

global maxR L

if k(2) == 0.0125 && R ~= 0
    f = 2;
end

i = 1;
R_halves = 0;
LR_halves = zeros(size(LRs));

while i <= R
    i = i + 1;
    RL = randperm(L);
    for j = RL
        if rand < k(1) * (1.01 ^ sum(LR)) * (16 ^ (LR(j))) && LR(j) + LR_halves(j) < maxR
            % if rand < k1 * (8 ^ (LRs(j, t))) && LRs(j, t + 1) < maxR
            R = R - 1;
            LR_halves(j) = LR_halves(j) + 1;
            i = i - 1;
            
            break;
        end
    end
end

LR = LR + LR_halves;

for i = 1:L
    j = 1;
    while j <= LRs(i)
        if rand < k(2)
            LRs(i) = LRs(i) - 1;
            LR(i) = LR(i) - 1;
            R_halves = R_halves + 1;
        else
            j = j + 1;
        end
    end
end

if R_halves ~= 0 || sum(LR_halves) ~= 0
    [R_halves, LR_halves] = stoch(R_halves, LR, LR_halves, k/2);
    R = R + R_halves;
    LRs = LRs + LR_halves;
end

end