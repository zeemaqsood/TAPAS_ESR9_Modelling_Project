function Models(model, Plot)

% Models:
%
% This function will run the function model from the folder Models. If no
% plot of the model is required, enter 'N' as the second input, otherwise a
% plot of how the parameters interact is shown
%
% See also: Folder: Models
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

global Model_names

% Please change the arguent to how many models there are
if isempty(Model_names)
    Model_names = strings(13, 1);
end

% This will run the necessary model
eval(strcat("run Models\Model", num2str(model)));

if ~exist('Plot', 'var')
    % Create the graph of the variables to visualize the reactions
    Graphs;
elseif ismember(Plot, ['y', 'yes', 'Y', 'Yes'])
    % Create the graph of the variables to visualize the reactions
    Graphs;
end
end