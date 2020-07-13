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


    % First, get the number of data, this is useful for sanity check.
    N = length( data );
    
    p = inputParser( );
    
    
    % [TIP] We can add a function handle for a simple input-type check
    ckc1 = @( x ) ( isnumeric( x ) &&   all( x > 0 ) && ( length( x ) == N ) ) ;
    ckc2 = @( x ) ( ( isstring( x ) || ischar( x ) ) && ( length( x ) == N ) ) ;
    ckc3 = @( x ) ( isnumeric( x ) &&  all( x >= 0 & x <= 1, [1,2] ) && ( size( x, 1 ) == N ) );
    
  
    addParameter( p, 'lineWidth',  5 * ones( 1, N )                        , ckc1 );
    addParameter( p, 'lineStyle',  repmat( "-", N, 1 )                     , ckc2 );
    addParameter( p, 'lineColor',  repmat( [0.8200, 0.8200, 0.8200], N, 1 ), ckc3 );
    
    parse( p, varargin{ : } )

    r = p.Results;

    l_w     = r.lineWidth;
    l_c     = r.lineColor;
    l_style = r.lineStyle;

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

