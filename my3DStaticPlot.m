function [ hFig, hAxes, hPlots ] = my3DStaticPlot( data, varargin ) 
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
%
%   (4) lineStyle:
%       -  The line style for each data.
%          The input will list of string, containing the 
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

    % Simple Parser for name-value pairing.
    p = inputParser( );
    p.KeepUnmatched = false;
    p.CaseSensitive = false;
    p.StructExpand  = true;     % By setting this False, we can accept a structure as a single argument.

    addParameter( p, 'lineWidth', NaN );
    addParameter( p, 'lineColor', NaN );
    addParameter( p, 'lineStyle', NaN );

    parse( p, varargin{ : } )

    r = p.Results;

    l_w     = r.lineWidth;
    l_c     = r.lineColor;
    l_style = r.lineStyle;

    % Get the number of data
    N = length( data );

    if isnan( l_c )
        l_c = repmat( [0.8200, 0.8200, 0.8200], N, 1 );                    % Setting the default color as "grey" for the line 
    else
        [tmpN, ~] = size( l_c );                                           % If input is not given,  
        if ( N ~= tmpN )
            error( "Wrong size of input \n Number of input data is %d but %d is given for style", ...
                                                                   N,    tmpN ) 
        end
    end    
    
    if isnan( l_w )
        l_w = 5 * ones( 1, N );                                            % Setting the default line width as 5
    else
        if ( N ~= length( l_w ) ) 
            error( "Wrong size of input \n Number of input data is %d but %d is given for style", ...
                                                                    N, length( l_w ) ) 
        end           
    end

    if isnan( l_style )
        l_style = repmat( "-", N, 1 );                                     % If lineStyle not given, setting the default line style as full line                                                     
    else
        if ( N ~= length( l_style ) ) 
            error( "Wrong size of input \n Number of input data is %d but %d is given for style", ...
                                                                    N, length( l_style ) ) 
        end                        

    end


    hFig  = figure();
    pos   = [0.08 0.1 0.84 0.80];                                              % Position/size for the main plot - 3D real time plot
    hAxes = axes( 'Position', pos, 'parent', hFig );                           % Defining and returning the handle of the plot

    hold( hAxes,'on' ); axis( hAxes, 'equal' )                                 % This will make the plot with equal ratio

    for i = 1 : N

        tmp = data{ i };
        hPlots( i ) = plot3(  tmp(1,:), tmp(2,:), tmp(3,:)        ,  ...
                                            'parent',   hAxes     ,  ...
                                             'color', l_c( i, : ) ,  ...
                                         'Linewidth', l_w( i )    ,  ...
                                         'LineStyle', l_style( i )      );  
    end


end

