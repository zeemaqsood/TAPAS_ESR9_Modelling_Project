function [edges, thick_edges, dotted_edges] = create_links

global eqns K catalysts multiples n;

% Edges will contain all edges and their weights
edges = [];

% Thick edges are the edges which have multiple possibilities
thick_edges = [];

% Dotted edges are catalysts
dotted_edges = [];

% We will use h as a new node, so we don not want it to override any of the
% n nodes we already have
h = n;

% For every equation in eqns
for i = 1:size(eqns, 2)
    % Consider the ith equation
    b = eqns{i};
    
    % If there are more than 1 elements at the start or finish, or if there
    % is a catalyst in both directions of the reaction, we will need to
    % create 2 new dummy nodes
    if size(b{1}, 2) > 1 || size(b{2}, 2) > 1 || (ismember(i, catalysts{1}) && ismember(-i, catalysts{1}))
        h = h + 2;
        
        if ismember(i, multiples{1})
            mult = true;
        else
            mult = false;
        end
        
        % If the forward reaction occurs, add the edges from the start 
        % nodes to the middle node and the middle node to the end nodes
        if K(b{3}, 1) ~= 0
            edges = [edges; [transpose(b{1}), (h - 1) * ones(size(b{1}, 2), 1), b{3} * ones(size(b{1}, 2), 1)]; ...
                            [(h - 1) * ones(size(b{2}, 2), 1), transpose(b{2}), b{3} * ones(size(b{2}, 2), 1)]];
                        
            if mult
                thick_edges = [thick_edges; [transpose(b{1}), (h - 1) * ones(size(b{1}, 2), 1), multiples{2}(multiples{1} == i) * ones(size(b{1}, 2), 1)]; ...
                                            [(h - 1) * ones(size(b{2}, 2), 1), transpose(b{2}), multiples{2}(multiples{1} == i) * ones(size(b{2}, 2), 1)]];
            end
        end
        
        % Check for if forward reaction involve catalysts
        h1 = 0;
        h2 = 0;
        
        % If the forward reaction has a catalyst
        if ismember(i, catalysts{1})
            % Find out which variables are a catalyst
            a1 = catalysts{2}(catalysts{1} == i);
            
            for j = 1:size(a1, 2)
                a2 = transpose(a1{j});
                
                if size(a2, 1) > 1
                    h1 = h1 + 1;
                    
                    % Add the edge from the catalysts to the first middle node
                    edges = [edges; [a2, (h + h1) * ones(size(a2, 1), 1), b{3} * ones(size(a2, 1), 1)]; ...
                                    [h + h1, h - 1, b{3}]];

                    % Since it it a catalyst, add it to the dotted edges
                    dotted_edges = [dotted_edges; [a2, (h + h1) * ones(size(a2, 1), 1)]; ...
                                                  [h + h1, h - 1]];
                                              
                    if mult
                        thick_edges = [thick_edges; [a2, (h + h1) * ones(size(a2, 1), 1),multiples{2}(multiples{1} == i) * ones(size(a2, 1), 1)]; ...
                                                    [h + h1, h - 1, multiples{2}(multiples{1} == i)]];
                    end
                else
                    edges = [edges; [a2, h - 1, b{3}]];

                    % Since it it a catalyst, add it to the dotted edges
                    dotted_edges = [dotted_edges; [a2, h - 1]];
                    
                    if mult
                        thick_edges = [thick_edges; [a2, h - 1, b{3}]];
                    end
                end
            end
        end
        
        if ismember(-i, multiples{1})
            mult = true;
        else
            mult = false;
        end
        
        % If the reverse reaction occurs, add the edges from the end nodes
        % to another middle node and that middle node to the start nodes       
        if K(b{3}, 2) ~= 0
            edges = [edges; [transpose(b{2}), h * ones(size(b{2}, 2), 1), - b{3} * ones(size(b{2}, 2), 1)]; ...
                            [h * ones(size(b{1}, 2), 1), transpose(b{1}), - b{3} * ones(size(b{1}, 2), 1)]];
                        
            if mult
                thick_edges = [thick_edges; [transpose(b{2}), h * ones(size(b{2}, 2), 1), multiples{2}(multiples{1} == - i) * ones(size(b{2}, 2), 1)]; ...
                                            [h * ones(size(b{1}, 2), 1), transpose(b{1}), multiples{2}(multiples{1} == - i) * ones(size(b{1}, 2), 1)]];
            end
        end        
        
        % If the reverse reaction has a catalyst
        if ismember(-i, catalysts{1})
            % Find out which variables are a catalyst
            a1 = catalysts{2}(catalysts{1} == -i);

            for j = 1:size(a1, 2)
                h = h + 1;
                a2 = transpose(a1{j});
                
                if size(a2, 1) > 1
                    h2 = h2 + 1;
                    
                    % Add the edge from the catalysts to the second middle node
                    edges = [edges; [a2, (h + h1 + h2) * ones(size(a2, 1), 1), - b{3} * ones(size(a2, 1), 1)]; ...
                                    [h + h1 + h2, h, - b{3}]];

                    % Since it it a catalyst, add it to the dotted edges
                    dotted_edges = [dotted_edges; [a2, (h + h1 + h2) * ones(size(a2, 1), 1)]; ...
                                                  [h + h1 + h2, h]];
                                              
                    if mult
                        thick_edges = [thick_edges; [a2, (h + h1 + h2) * ones(size(a2, 1), 1), multiples{2}(multiples{1} == - i) * ones(size(a2, 1), 1)]; ...
                                                    [h + h1 + h2, h, multiples{2}(multiples{1} == - i)]];
                    end
                else
                    % Add the edge from the catalysts to the second middle node
                    edges = [edges; [a2, h, - b{3}]];

                    % Since it it a catalyst, add it to the dotted edges
                    dotted_edges = [dotted_edges; [a2, h]];
                    if mult
                        thick_edges = [thick_edges; [a2, h, multiples{2}(multiples{1} == - i)]];
                    end
                end
            end
        end
        
        h = h + h1 + h2;

    % If the reaction contain a catakyst, one new node(s) must be created
    elseif ismember(i, abs(catalysts{1}))
        newnodes = sum(abs(catalysts{1}) == i);
        
        h = h + newnodes;
        
        if ismember(i, multiples{1})
            mult1 = true;
        else
            mult1 = false;
        end
        
        if ismember(-i, multiples{1})
            mult2 = true;
        else
            mult2 = false;
        end
        
        % If the forward reaction contains a catalyst
        if ismember(i, catalysts{1})
            for j = 0:newnodes - 1
                edges = [edges; [transpose(b{1}), (h - j) * ones(size(b{1}, 2), 1), b{3} * ones(size(b{1}, 2), 1)]; ...
                                [(h - j) * ones(size(b{2}, 2), 1), transpose(b{2}), b{3} * ones(size(b{1}, 2), 1)]];

                if mult1
                    thick_edges = [thick_edges; [transpose(b{1}), (h - j) * ones(size(b{1}, 2), 1), multiples{2}(multiples{1} == i)]; ...
                                                [(h - j) * ones(size(b{2}, 2), 1), transpose(b{2}), multiples{2}(multiples{1} == i)]];
                end
            end
                
            % Find out which variables are a catalyst
            a1 = catalysts{2}(catalysts{1} == i);
            
            h1 = 0;
            
            for j = 1:size(a1, 1)
                a2 = transpose(a1{j});
                
                % Add the edges from the first node to the middle node, the
                % middle node to the end node and the catalysts to the middle
                % node
                if size(a2, 1) > 1
                    h1 = h1 + 1;
                    
                    edges = [edges; [a2, (h + h1) * ones(size(a2, 1), 1), b{3} * ones(size(a2, 1), 1)]; ...
                                    [h + h1, h - j + 1, b{3}]];

                    % Add the edges from the catalysts to the middle node
                    dotted_edges = [dotted_edges; [a2, (h + h1) * ones(size(a2, 1), 1)]; ...
                                                  [h + h1, h - j + 1]];
                                              
                    if mult1     
                        thick_edges = [thick_edges; [a2, (h + h1) * ones(size(a2, 1), 1), multiples{2}(multiples{1} == i) * ones(size(a2, 1), 1)]; ...
                                                    [h + h1, h - j + 1, multiples{2}(multiples{1} == i)]];
                    end
                    
                else
                    edges = [edges; [a2, h - j + 1, b{3}]];

                    % Add the edges from the catalysts to the middle node
                    dotted_edges = [dotted_edges; [a2, h - j + 1]];
                    
                    if mult1
                        thick_edges = [thick_edges; [a2, h, multiples{2}(multiples{1} == i)]];
                    end
                end
            end
            
            h = h + h1;
            
            % If the reverse reaction occurs, add edge between end node and
            % start node
            if K(b{3}, 2) ~= 0
                edges = [edges; [b{2}, b{1}, - b{3}]];
                
                if mult2
                    thick_edges = [thick_edges; [b{2}, b{1}, - multiples{2}(multiples{1} == - i)]];
                end
            end
            
            b = 1;
            
            % Repeat for if the catalyst is involved for the reverse direction
        else
            for j = 0:newnodes - 1
                edges = [edges; [transpose(b{2}), (h - j) * ones(size(b{2}, 2), 1), - b{3} * ones(size(b{1}, 2), 1)]; ...
                    [(h - j) * ones(size(b{1}, 2), 1), transpose(b{1}), - b{3} * ones(size(b{1}, 2), 1)]];
                
                if mult2
                    thick_edges = [thick_edges; [transpose(b{2}), (h - j) * ones(size(b{2}, 2), 1), multiples{2}(multiples{1} == - i)]; ...
                        [(h - j) * ones(size(b{1}, 2), 1), transpose(b{1}), multiples{2}(multiples{1} == - i)]];
                end
            end
            
            a1 = catalysts{2}(catalysts{1} == -i);
            
            h1 = 0;
            
            for j = 1:size(a1, 1)
                a2 = transpose(a1{j});
                
                if size(a2, 1) > 1
                    edges = [edges; [a2, (h + j) * ones(size(a2, 1), 1), - b{3} * ones(size(a2, 1), 1)];
                                    [h + j, h - j + 1, - b{3}]];

                    dotted_edges = [dotted_edges; [a2, (h + j) * ones(size(a2, 1), 1)];
                                                  [h + j, h - j + 1]];
                                              
                   if mult2
                        thick_edges = [thick_edges; [a2, (h + j) * ones(size(a2, 1), 1), multiples{2}(multiples{1} == - i) * ones(size(a2, 1), 1)];
                                                    [h + j, h - j + 1, multiples{2}(multiples{1} == - i)]];
                   end
                                              
                else
                    edges = [edges; [a2, h - j + 1, - b{3}]];

                    dotted_edges = [dotted_edges; [a2, h - j + 1]];
                    
                    if mult2
                        thick_edges = [thick_edges; [a2, h - j + 1]];
                    end
                end
            end
            
            if K(b{3}, 1) ~= 0
                edges = [edges; [b{1}, b{2}, b{3}]];
                
                if mult1
                    thick_edges = [thick_edges; [b{1}, b{2}, multiples{2}(multiples{1} == i)]];
                end
            end
            
            b = -1;
        end
        
    else
        % If the forward reaction occurs
        if K(b{3}, 1) ~= 0
            edges = [edges; [b{1}, b{2}, b{3}]];
        end
        
        % If the reverse reaction occurs
        if K(b{3}, 2) ~= 0
            edges = [edges; [b{2}, b{1}, - b{3}]];
        end
   
        % If the forward reaction is a double
        if ismember(i, multiples{1})
            thick_edges = [thick_edges; [b{1}, b{2}, multiples{2}(multiples{1} == i)]];
        end
        
        % If the reverse reaction is a double
        if ismember(- i, multiples{1})
            thick_edges = [thick_edges; [b{2}, b{1}, multiples{2}(multiples{1} == - i)]]; %#ok<*AGROW>
        end
    end
end
end
