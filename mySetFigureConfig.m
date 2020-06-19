function mySetFigureConfig( fontSize, lineWidth, markerSize )
% setFigureConfig  Setting the default figure/axis configuration 
%
% =============================================================== %
% [INPUT] fontSize: 
%        lineWidth:
%       markerSize:
% =============================================================== %
%
% =============================================================== %
% [OUTPUT]    None
%
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

set( 0, 'defaultTextfontSize'               , 1.6 * fontSize    );
set( 0, 'defaultTextInterpreter'            ,     'latex'       );
set( 0, 'defaultLegendInterpreter'          ,     'latex'       );
set( 0, 'defaultLineLinewidth'              ,     lineWidth     );
set( 0, 'defaultLineMarkerSize'             ,     markerSize    );
set( 0, 'defaultAxesTickLabelInterpreter'   ,     'latex'       );  
set( 0, 'defaultAxesfontSize'               , 3.2 * fontSize    );
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

