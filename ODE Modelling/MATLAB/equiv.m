function vals = equiv(vals, Var_units, units, powers)

sizes = ["y", "z", "a", "f", "p", "n", "u", "m", "", "K", "M", "G", "T", "P", "E", "Z", "Y"];

% ~exist checks the existence of a variable
if ~exist('powers', 'var')
    %Create an array of all ones with a size of the number of variables
    powers = ones(size(Var_units));
end

%returns a logical vector if an element is found in the matrix
%The ~ represents an output that is discarded. It is essentially equivalent
%to: 
%[dummy,idx]=min(dists);
[~, a] = ismember(units, sizes);
%returns a logical vector if an element is found in the matrix
[~, b] = ismember(Var_units, sizes);

vals = vals .* 10 .^ (3 .* (powers .* (b - a)));

end