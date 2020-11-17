function Model_template

global Model_names Vars Plot_Vars IVs K eqns multiples catalysts constants n;

Model_names() = "";

% Number of variables
n = ;

Vars = cell(n, 1);
IVs = zeros(n, 1);
K = zeros(, 2);

% Variable names and their initial values
Vars{1} = ;     IVs(1) = ; % 'L', 1
Vars{2} = ;      IVs(2) = ;

% Formal variable names displayed when used to plot graphs. If you would
% like to change any, do so here

Plot_Vars = Create_plot_vars(Vars);

% Define the K values. If no reverse reaction occurs, set the second value
% to zero
K(1, :) = [, ]; % [0.1, 0.1]
K(2, :) = [, ];

% Define the reactions i.e. {[1, 2],  6,  [1, 2]} means variables 1 and 2
% react to make variable 6 with rate constant K(1) and the reverse reaction 
% happens with rate constant K(2)

eqns = cell(1, );

%            in           out     k value numbers
eqns{1} = {, , }; % {["R", "LL_R"], "LL_RR", 2}
eqns{2} = {, , };

eqns = vars2nums(eqns);
    

% Reactions which have multiple possibilities
multiples = cell(1, 2);

multiples{1} = zeros(, 1);
multiples{2} = zeros(, 1);
      
%                 Eqn No               Mult
multiples{1}(1) = ; multiples{2}(1) = ; % 1, 4
      

% Variables which are not used in a reaction, just used as a catalyst
catalysts = cell(1, 2);

% How many catlysts occur?
catalysts{1} = zeros(, 1);
catalysts{2} = strings(, 1);

%                 Eqn number            Var
catalysts{1}(1) = ; catalysts{2}(1) = ; % 1, "LL"

catalysts{2} = vars2nums(catalysts{2});
      

% Variables which we assume to stay constant
constants = vars2nums(); % [1, 2]
    
end