function [hFig, hAxes, hPlots] = my3DStaticPlot( data, lineWidth, lineColor )
% my3DStaticPlot for plotting a time-static 3D plot of data.
%
% =============================================================== %
% [INPUT] 
%   (1) data 
%       -  The 3D Position Data of the plot.
%          The data is given as a cell, and each cell is composed of 3 x N array.
%          3 rows stand for X, Y and Z coordinate position data, and N is the time series. 
%          This data will be plotted in 3D Cartesian Space
%
%   (2) lineWidth:
%       -  The line width of each data.
%          The length of the "lineWidth" should be the same with data and lineColor
%
%   (3) lineColor:
%       -  The line color of each data.
%          The input will be a N x 3 data, where the column stands for R,G and B, valued between 0 and 1
% =============================================================== %
%
% =============================================================== %
% [OUTPUT] 
%   (1) hFig
%       - The handle of the figure 
%
%   (2) hAxes
%       - The handle of the Axes
%
%   (3) hPlots
%       - The handles of the plot, in most cases there will be multiple handles.
%         Thus returned in a "cell" form.
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
% =============================================================== %
% 
% [CREATED BY]: Moses C. Nah
% [   DATE   ]: 07-June-2020
% =============================================================== %

% =============================================================== %
% [DESCRIPTION]
%   Function for plotting a static 3D Plot 
%
% =============================================================== %

% Sanity Check
% Checking the size of whether the input data, linewidth and linecolor data are all filled.
[tmpN, ~] = size( lineColor );

if ( length( data ) ~= length( lineWidth) ) || ( length( data ) ~= tmpN ) 
    error( "Wrong size of input \n Input sizes are %d, %d and %d for each", ...
                                    length( data ), length( lineWidth ), tmpN ) 
end


hFig  = figure();
pos   = [0.08 0.1 0.84 0.80];                                              % Position/size for the main plot - 3D real time plot
hAxes = axes( 'Position', pos, 'parent', hFig );                           % Defining and returning the handle of the plot

hold( hAxes,'on' ); axis( hAxes, 'equal' )                                 % This will make the plot with equal ratio


for i = 1 : length( data )
    
    tmp = data{ i };
    hPlots( i ) = plot3(  tmp(1,:), tmp(2,:), tmp(3,:)        ,  ...
                                  'parent',   hAxes           ,  ...
                                   'color', lineColor( i, : ) ,  ...
                               'Linewidth', lineWidth( i )   );  
end


end

