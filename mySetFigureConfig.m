function mySetFigureConfig( varargin )
% setFigureConfig  Setting the default figure/axis configuration 
%
% =============================================================== %
% [INPUT] varagin: getting the whole list of inputs given
%        
% [PROPERTIES]                                                  [DEFAULT]
%    fontSize: the default size of the figure font.                10
%   lineWidth: the default width of the line.                       5
%  markerSize: the default size of the marker.                     20
% =============================================================== %
%
% =============================================================== %
% [OUTPUT]    None
%
%
% =============================================================== %
%
% [EXAMPLES] (1) mySetFigureConfig( 'fontSize', 10 )
%            (2) mySetFigureConfig( 'fontSize', 10, 'markerSize', 10 )
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
%
% [DATE]: 07-June-2020
% =============================================================== %

% =============================================================== %
% [DESCRIPTION]
% General plotting settings
% Syntax is as following: 'default' ObjectType PropertyName
%
% [Primitive Objects Properties]
% [REF] https://www.mathworks.com/help/matlab/graphics-object-properties.html
%
% [Figure Properties]
% [REF] https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html
%
%
% =============================================================== %

% Parser 
p = inputParser( );
p.KeepUnmatched = false;
p.CaseSensitive = false;
p.StructExpand  = true;     % By setting this False, we can accept a structure as a single argument.

addParameter( p,   'fontSize', 10 );
addParameter( p,  'lineWidth', 5 );
addParameter( p, 'markerSize', 20 );

parse( p, varargin{ : } )

r = p.Results;

% fprintf( '%16s   %s\n', 'name' , 'value' ) 
% fprintf( '%16s = %f\n', 'fontSize' , r.fontSize ) 
% fprintf( '%16s = %f\n', 'lineWidth'   , r.lineWidth ) 
% fprintf( '%16s = %f\n', 'markerSize', r.markerSize ) 

set( 0, 'defaultTextfontSize'               , 1.6 * r.fontSize    );
set( 0, 'defaultTextInterpreter'            ,     'latex'       );
set( 0, 'defaultLegendInterpreter'          ,     'latex'       );
set( 0, 'defaultLineLinewidth'              ,     r.lineWidth     );
set( 0, 'defaultLineMarkerSize'             ,     r.markerSize    );
set( 0, 'defaultAxesTickLabelInterpreter'   ,     'latex'       );  
set( 0, 'defaultAxesfontSize'               , 3.2 * r.fontSize    );
set( 0, 'defaultAxesXGrid'                  ,       'on'        );
set( 0, 'defaultAxesYGrid'                  ,       'on'        );
set( 0, 'defaultAxesZGrid'                  ,       'on'        );
set( 0, 'defaultAxesBox'                    ,       'on'        );
set( 0, 'defaultFigureWindowStyle'          ,     'normal'      );
set( 0, 'defaultFigureUnits'                ,     'normalized'  );
set( 0, 'defaultFigurePosition'             ,     [0 0 1 1]     );
set( 0, 'defaultFigureColor'                ,     [1 1 1  ]     );

set( 0, 'defaultFigureCreateFcn'            , @( fig, ~ )addToolbarExplorationButtons( fig ) )
set( 0, 'defaultAxesCreateFcn'              , @(  ax, ~ )set( ax.Toolbar, 'Visible', 'off' ) )



end

