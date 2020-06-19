function color = myColor( )
% myColor Calling the list of colors for plot
%
% =============================================================== %
% [INPUT] 
% =============================================================== %
%
% =============================================================== %
% [OUTPUT] color: containing multiple lists of colors
%
% =============================================================== %
%
% [REMARKS]  ADD DETAILS
%
%
% =============================================================== %
%
% =============================================================== %
% SEE ALSO testHelpFunction 
%
%
%
% =============================================================== %
% 
% [CREATED BY]: Moses C. Nah
%
% [DATE]: 07-June-2020
% =============================================================== %

% =============================================================== %
% [DESCRIPTION]
%   Function outputting a list of colors for plot
%
%
% =============================================================== %

color = struct(                                       ...
                'yellow' , [0.9290, 0.6940, 0.1250], ...
                'orange' , [0.8500, 0.3250, 0.0980], ...
                'pink'   , [0.9961, 0.4980, 0.6118], ...
                'blue'   , [     0, 0.4470, 0.7410], ...
                'purple' , [0.4940, 0.1840, 0.5560], ...
                'green'  , [0.4660, 0.6740, 0.1880], ...
                'white'  , [   1.0,    1.0,    1.0], ...
                'grey'   , [0.8200, 0.8200, 0.8200], ...
                'roseRed', [0.7608, 0.1176, 0.3373]  ...
               );

end

