classdef my3DAnimation < handle
%
%  my3DAnimation class for setting up the 3D animation with the input data.
% 
% % =============================================================== %
%   [DESCRIPTION]
%
%
% % =============================================================== %
%   [CREATED BY]  Moses Nah
%   [EMAIL]       mosesnah@mit.edu
%   [AFFILIATION] Massachusetts Institute of Technology (MIT)
%   [MADE AT]     08-June-2020    
% % =============================================================== %


% % =============================================================== %
%   [REFERENCES]
%   my3DAnimation class for setting up the 3D animation with the input data.
% 
% % =============================================================== %

% % =============================================================== %
% [START] 

    properties ( SetAccess = private )
        
        % ================================================================= % 
        % [Figure and Axes Configuration]
        % suffix m  stands for main
        % suffix s1 stands for side plot #1 (Lower Right)
        % suffix s2 stands for side plot #2 (Upper Right)
        
                                           % [Configuration #1] A single big plot
        pos1m  = [0.08 0.10 0.84 0.80];    % Position/size for the main plot before adding plot 
        
                                           % [Configuration #2] A big plot on the left, two plots on the upper/lower right.
        pos2m  = [0.08 0.08 0.42 0.82];    % Position/size for the main plot - 3D real time plot
        pos2s1 = [0.58 0.08 0.40 0.37];    % Position/size for the under-sub-plot, drawn in the lower section
        pos2s2 = [0.58 0.55 0.40 0.40];    % Position/size for the above-sub-plot, drawn in the upper section.
        
    end
    
    properties ( SetAccess = public )
        % ================================================================ %
        % [Syntax]
        % (1) Graphic Handle
        %     - h Stands for handle
        %     - F, A, L, M, E Stands for Figure, Axes, Line, Markers, Ellipse Handle, respectively.
        %     - m, s1, s2 stands for main, side1, side2, respectively.
        %     - s1Z, Z suffix stands for "Zoomed" Plot, which is special 
        % (2) Position Information 
        %     - p prefix stands for XYZ position information.
        %     - If pX, then position of X.
        % (3) Indexing Information 
        %     - The indexing information is important for "connect" method 
        %     - "idx" prefix stands for indexing
        % ================================================================ %
        
        % ================================================================ %
        % [START OF DEFINITION]
        
        tVec; tStep;            % Time vector and step of the simulation.

        
                                % [The handle of the Figure and Title]
        hFigure = []            % The handle of the whole figure
        hTitle  = []            % The  title of the whole figure.

                                % [The handle of the axes]
        hAxesMain  = []         % Main Axes
        hAxesSide1 = []         % Side plot Axes 1 (Lower)       
        hAxesSide2 = []         % Side plot Axes 2 (Upper)   
        
        % main Graphic Objects
        markersMain     = [] 
        ellipseMain     = [] 
        arrowMain       = []
        hMarkersMain    = gobjects( 0 )
        hLineMain       = gobjects( 0 )
        hEllipseMain    = gobjects( 0 )
        hArrowMain      = gobjects( 0 )
        
        % Side Plot 1 Graphic Objects
        ellipseSide1    = [] 
        arrowSide1      = []
        hEllipseSide1   = gobjects( 0 )
        hArrowSide1     = gobjects( 0 )    
        
        % Side Plot 2 Graphic Objects
        ellipseSide2    = [] 
        arrowSide2      = []
        hEllipseSide2   = gobjects( 0 )
        hArrowSide2     = gobjects( 0 )    
        

        % Index list for "connect" method.
        idxLines = logical.empty        

    end
    
    methods
                
        function obj = my3DAnimation( tStep, markers, varargin )
            %[CONSTRUCTOR #1] Construct an instance of this class
            %   (1) tVec [sec]
            %       -  The time vector of the simulation
            %   (2) markers [marker array] 
            %       -  The class array of "myMarker" class. 

            % [Quick Sanity Check] Check the size between the data and time vec    
            obj.markersMain = markers;
            
            for m = markers
                if ( m.N ~= markers( 1 ).N  )
                    error( "Wrong size [Name: %s] %d != %d " ,m.name, m.N, marker( 1 ).N )
                end
            end
                        
            % If the size of the data are all the same.
            % Setting the default time step and its corresponding time vector.
            obj.tStep = tStep;
            obj.tVec  = tStep * (0 : m.N-1);   % Taking out 1 to match the size of data        
            

            % Setting the default figure and Axes for the plot
            obj.hFigure   = figure();
            obj.hAxesMain = subplot( 'Position', obj.pos1m, 'parent', obj.hFigure );    
            obj.hTitle    = title( obj.hAxesMain, sprintf( '[Time] %5.3f (s)', obj.tVec( 1 ) ) );
            hold( obj.hAxesMain,'on' ); axis( obj.hAxesMain, 'equal' )             

            tmpN = length( markers );                   % Getting the length of the markers
            obj.hMarkersMain = gobjects( 1, tmpN );     % Defining the graphic object handles as an array
            
            % Plotting the Markers 
            for i = 1 : tmpN
                m = markers( i );
                obj.hMarkersMain( i ) = plot3(   m.xdata( 1 ), ...
                                                 m.ydata( 1 ), ...
                                                 m.zdata( 1 ), ...
                                      'parent', obj.hAxesMain, ...
                                           'Marker',  m.style, ...
                                       'MarkerSize',   m.size, ...
                                  'MarkerEdgeColor',  m.color, ...
                                  'MarkerFaceColor',  [1,1,1]  );  
                              
            end
            
        end
        
        function addMarkers( obj, markers, varargin )
            %addMarker: adding dynamic markers to the main plot
            % =============================================================== %
            % [INPUTS]
            %   (1) markers (myMarker class List) 
            %       - a whole class of markers to be added to the main plot
            %   (2) varagin
            %       - [TO BE ADDED]
            
            N = length( markers );          % Getting the length of the given markers
                    
            for i = 1 : N                   % Append the markers to the graph
                m = markers( i );
                
                % Check whether size is correct.
                if ( length( obj.tVec ) ~= m.N )
                    error( "Wrong size [Name: %s] %d != %d " ,m.name, m.N, length( obj.tVec ) )
                end
                
                % If size is correct, add the markers to the plot
                obj.markersMain( end + i ) = m; 
                obj.hMarkersMain( end + i ) = plot3( m.xdata( 1 ), ...
                                                     m.ydata( 1 ), ...
                                                     m.zdata( 1 ), ...
                                          'parent', obj.hAxesMain, ...
                                               'Marker',  m.style, ...
                                           'MarkerSize',   m.size, ...
                                      'MarkerEdgeColor',  m.color, ...
                                      'MarkerFaceColor',  [1,1,1]  );  
            end
            
            % If there exist line index, created from "connectMarkers" method, then increase the size of the index.
            if ~isempty( obj.idxLines )
                
                for i = 1 : size( obj.idxLines, 1 ) % Iterate along the row 
                    %                                               Filling it with zeros    
                    obj.idxLines( i, : ) = [ obj.idxLines( i, : ), false( zeros( 1, N ) ) ];
                end
                
            end
            
        end

        function addGraphicObject( obj, idx, myGraphic, varargin )
             %addGraphicObject: adding a single graphical object to the plot
             % 
             % [TYPES OF GRAPHIC OBJECTS]
             % (1) Ellipse 
             %
             % (2) Vector
             %
             % (3) varagin
             %     - [TO BE ADDED]             
             % Check where to draw the graphic
             
             
            % Change the configuration of the plots if side plots are not on
            if  ( idx == 1 || idx == 2 ) && ( isempty( obj.hAxesSide1 ) && isempty( obj.hAxesSide2 ) )
                set( obj.hAxesMain, 'Position', obj.pos2m ); 
                
                if     idx == 1
                    obj.hAxesSide1 = subplot( 'Position', obj.pos2s1, 'parent', obj.hFigure );
                    hold( obj.hAxesSide1,    'on' );
                    axis( obj.hAxesSide1, 'equal' );
                     
                elseif idx == 2
                    obj.hAxesSide2 = subplot( 'Position', obj.pos2s2, 'parent', obj.hFigure );
                    hold( obj.hAxesSide2,    'on' );
                    axis( obj.hAxesSide2, 'equal' );                    
                     
                end
                
            end
            
             if     idx == 0
                 h2Draw =  obj.hAxesMain;
                 
             elseif idx == 1
                 h2Draw = obj.hAxesSide1;
                 
             elseif idx == 2
                 h2Draw = obj.hAxesSide2;
                 
             else
                 error( "Wrong index! %d Give, Please input between 0 to 2", idx )
             end
            
            if     isa( myGraphic , 'myArrow' )
                  hArrow = quiver3( myGraphic.orig( 1,1 ), ...
                                    myGraphic.orig( 2,1 ), ...
                                    myGraphic.orig( 3,1 ), ...
                                           myGraphic.x(1), ...
                                           myGraphic.y(1), ...
                                           myGraphic.z(1), ...
                                         'parent', h2Draw, ...
                                      'linewidth', myGraphic.arrowWidth, ...
                                          'color', myGraphic.arrowColor, ...
                                    'MaxheadSize', myGraphic.arrowHeadSize );
                 
                     if     idx == 0
                         if isempty( obj.hArrowMain  )
                            obj.hArrowMain = hArrow;
                            obj.arrowMain  = myGraphic;
                         else
                            obj.hArrowMain( end + 1 ) = hArrow;
                            obj.arrowMain( end + 1 )  = myGraphic;
                         end
                         

                     elseif idx == 1
                         if isempty( obj.hArrowSide1 )
                            obj.hArrowSide1 = hArrow;
                            obj.arrowSide1  = myGraphic;                            
                         else
                            obj.hArrowSide1( end + 1 ) = hArrow;
                            obj.arrowSide1( end + 1 )  = myGraphic;
                            
                         end

                     elseif idx == 2
                         if isempty( obj.hArrowSide2 )
                            obj.hArrowSide2 = hArrow;
                            obj.arrowSide2  = myGraphic;
                         else
                            obj.hArrowSide2( end + 1 ) = hArrow;
                            obj.arrowSide2( end + 1 )  = myGraphic;                            
                         end
                         
                     end

                    
            elseif isa( myGraphic , 'myEllipse' )

                  hEllipse = mesh( myGraphic.xmesh(:,:,1), ...
                                   myGraphic.ymesh(:,:,1), ...
                                   myGraphic.zmesh(:,:,1), 'parent', h2Draw );
                    
                     if     idx == 0
                         if isempty( obj.hEllipseMain  )
                            obj.hEllipseMain = hEllipse;
                            obj.ellipseMain  = myGraphic;
                         else
                            obj.hEllipseMain( end + 1 ) = hEllipse;
                            obj.ellipseMain( end + 1 )  = myGraphic;

                         end

                     elseif idx == 1
                         if isempty( obj.hArrowSide1 )
                            obj.hEllipseSide1 = hEllipse;
                            obj.ellipseSide1  = myGraphic;                            
                            
                         else
                            obj.hEllipseSide1( end + 1 ) = hEllipse;
                            obj.ellipseSide1( end + 1 )  = myGraphic;                            
                         end

                     elseif idx == 2
                         if isempty( obj.hArrowSide2 )
                            obj.hEllipseSide2 = hEllipse;
                            obj.ellipseSide2  = myGraphic;                                
                         else
                            obj.hEllipseSide2( end + 1 ) = hEllipse;
                            obj.ellipseSide2( end + 1 )  = myGraphic;                                                        
                         end
                         
                     end
                  
            end
                
        end
        
        
        function connectMarkers( obj, whichMarkers, varargin )
            %connect: connecting markers with lines in the main plot
            % =============================================================== %
            % [INPUTS]
            %   (1) names (string) List
            %       - the index of the markers that are aimed to be connected
            
            % Start with index array with 
            N = length( obj.markersMain );
            idxList = false( 1, N );   
            
            % Temporary Saving the list of names of the markers for the connect

            if     isstring( whichMarkers )     % If markers info. are given as strings
                
                for s = whichMarkers
                    tmp = strcmp( [obj.markersMain.name], s ) ;       % Try finding the string.
                    
                    if isempty( tmp )  % If marker name doesn't exist
                       error( "%s doesn't exist in the markers list", s ) 
                    end
                    
                    idxList( tmp ) = true;      % Turn on the index as true
                    
                end
                
            elseif isnumeric( whichMarkers )    % If markers info. are given as integer array 
                
                idxList( whichMarkers ) = true; 
                
            else
                error( "Wrong input, argument should be array of strings or integers" ) 
            end
            

            r = myParser( varargin );   
            
            tmpx = vertcat( obj.markersMain.xdata );
            tmpy = vertcat( obj.markersMain.ydata );
            tmpz = vertcat( obj.markersMain.zdata );
            
            tmph = plot3(  tmpx( idxList ), tmpy( idxList ), tmpz( idxList), ...
                             'parent', obj.hAxesMain , ...
                          'linewidth',    r.lineWidth, ...
                          'linestyle',    r.lineStyle, ...
                              'color',    r.lineColor );     
            
            obj.hLineMain = [ obj.hLineMain, tmph   ];                      
            obj.idxLines  = [ obj.idxLines; idxList ];
            
        end        

        function run( obj, vidRate, isVidRecord, videoName )
            %run: running the a whole animation and saving the video if defined.
            % [INPUTS]
            %   (1) vidRate 
            %       - video Rate of the animation.
            %       - if vidRate is 0.5, then the video is two times slower. 
            %       - if vidRate is 1.0, then the video is at real time speed.
            %       - if vidRate is 2.0, then the video is two times faster. 
            %
            %   (2) isVidRecord ( boolean )
            %       - true or false, if false, simply showing the animation.
            %
            %   (3) videoName (string)
            %       - name of the video for the recording.

                
            N       = length( obj.tVec );
            tStep   = obj.tVec( 2 ) - obj.tVec( 1 ) ;                      % Equal time step, hence getting the first element which is the single time step value.                                                               
            simStep = round( ( 1 / tStep / 60 ) );                         % Setting 60 fps - 1 second as default!

            set( obj.hA_s2,  'view',   get( obj.hAxesMain, 'view' ) )           
            
            if simStep == 0
               simStep = 1; 
            end
            
            if isVidRecord                                                 % If video record is ON

                fps     = 60 * vidRate;                                    % Frame-per-second of the video, 60Hz is default rate.
                writerObj = VideoWriter( videoName, 'MPEG-4' );            % Saving the video as "videoName" 
                writerObj.FrameRate = fps;                                 % How many frames per second.
                open( writerObj );                                         % Opening the video write file.

            end    

            for i = 1 : simStep : N

                set( obj.hTitle,'String', sprintf( '[Time] %5.3f (s)  x%2.1f', obj.tVec( i ), vidRate ) );

                for j = 1 : length( obj.data )
                    set( obj.hMarkersMain( j ), 'XData', obj.data{ j }( 1, i ), ...
                                        'YData', obj.data{ j }( 2, i ), ...
                                        'ZData', obj.data{ j }( 3, i ) ) 
                            
                    % If Zoom Window On
                    if ~isempty( obj.hM_s1Z )                                                  
                        set( obj.hM_s1Z( j ), 'XData', obj.data{ j }( 1, i ), ...
                                              'YData', obj.data{ j }( 2, i ), ...
                                              'ZData', obj.data{ j }( 3, i ) ) 

                        if ~isempty( obj.hL_s1Z )                                               
                            set( obj.hL_s1Z( j ), 'XData', obj.pX_m( obj.idx_L( j,: ), i ), ...
                                                  'YData', obj.pY_m( obj.idx_L( j,: ), i ), ...
                                                  'ZData', obj.pZ_m( obj.idx_L( j,: ), i ) )  
                        end
                        
                        if ~isempty( obj.hE_Z ) 
                            set( obj.hE_Z, 'XData', obj.pE_X{ i }, ...
                                           'YData', obj.pE_Y{ i }, ...
                                           'ZData', obj.pE_Z{ i }  )        
                        end
                                          
                        orig = obj.data{ obj.idx_Z }( :, i );
            
                        set( obj.hA_s1Z,  'XLim',   [ -obj.size_Z + orig(1), obj.size_Z + orig(1) ] , ...         
                                          'YLim',   [ -obj.size_Z + orig(2), obj.size_Z + orig(2) ] , ...    
                                          'ZLim',   [ -obj.size_Z + orig(3), obj.size_Z + orig(3) ] , ...
                                          'view',   get( obj.hAxesMain, 'view' ) )   
                    end
                                                  
                end 
                
                if ~isempty( obj.hA_s2E )
                    
                    [XX, YY, ZZ] = Ellipse_plot( obj.E_Mat(:,:,i), [0,0,0] );            
                    [ V, ~, ~ ] = svd( obj.E_Mat(:,:,i) );
                    set( obj.hE_s2, 'xdata', XX, 'ydata', YY, 'zdata', ZZ )
                    
                    set( obj.hE_s2_AXp, 'udata',  V(1,1), 'vdata',  V(2,1), 'wdata',  V(3,1) ) ;
                    set( obj.hE_s2_AXn, 'udata', -V(1,1), 'vdata', -V(2,1), 'wdata', -V(3,1) ) ;

                    set( obj.hE_s2_AYp, 'udata',  V(1,2), 'vdata',  V(2,2), 'wdata',  V(3,2) ) ;
                    set( obj.hE_s2_AYn, 'udata', -V(1,2), 'vdata', -V(2,2), 'wdata', -V(3,2) ) ;

                    set( obj.hE_s2_AZp, 'udata',  V(1,3), 'vdata',  V(2,3), 'wdata',  V(3,3) ) ;
                    set( obj.hE_s2_AZn, 'udata', -V(1,3), 'vdata', -V(2,3), 'wdata', -V(3,3) ) ;
                    
                    set( obj.hE_s2_Arrow, 'udata', obj.hE_s2_Arrow_vec( 1, i ), ...
                                          'vdata', obj.hE_s2_Arrow_vec( 2, i ), ...
                                          'wdata', obj.hE_s2_Arrow_vec( 3, i ) )
                end

                for j = 1 : length( obj.hL_m )                    
                    set( obj.hL_m( j ),   'XData', obj.pX_m( obj.idx_L( j,: ), i ), ...
                                          'YData', obj.pY_m( obj.idx_L( j,: ), i ), ...
                                          'ZData', obj.pZ_m( obj.idx_L( j,: ), i ) )    
                end
                
                if ~isempty( obj.hV_s2 )
                    
                    for k = 1 : length( obj.hV_s2 ) 
                        set( obj.hV_s2( k ), 'UData', obj.pVX_s2( k, i ), ...
                                             'VData', obj.pVY_s2( k, i ), ...
                                             'WData', obj.pVZ_s2( k, i ))
                    end
                    
                    
                end
                
                if ~isempty( obj.hM_s1 )
                    
                    for k = 1 : length( obj.hM_s1 ) 
                        set( obj.hM_s1( k ), 'XData', obj.pX_s1( k, i ), ...
                                             'YData', obj.pY_s1( k, i ) )
                    end
                    
                end
                
                if ~isempty( obj.hM_s2 )
                    
                    for k = 1 : length( obj.hM_s2 ) 
                        set( obj.hM_s2( k ), 'XData', obj.pX_s2( k, i ), ...
                                             'YData', obj.pY_s2( k, i ) )                        
                    end                    
                    
                end                
                
                
                if ~isempty( obj.hE )
                    
                    set( obj.hE, 'XData', obj.pE_X{ i }, ...
                                 'YData', obj.pE_Y{ i }, ...
                                 'ZData', obj.pE_Z{ i }, 'visible', 'off' )                        
                
                    
                end                       

                if isVidRecord                                             % If videoRecord is ON
                    frame = getframe( obj.hFigure );                          % Get the current frame of the figure
                    writeVideo( writerObj, frame );                        % Writing it to the mp4 file/
                else                                                       % If videoRecord is OFF
                    drawnow                                                % Just simply show at Figure
                end

            end   

            if isVidRecord
                close( writerObj );
            end         

        end
        
        function addVectorPlot( obj, xData, yData, zData )
            % Plotting the vector arrow based on xData, yData and zData
            obj.pVX_s2 = [obj.pVX_s2; xData];
            obj.pVY_s2 = [obj.pVY_s2; yData];
            obj.pVZ_s2 = [obj.pVZ_s2; zData];
            
            if ( isempty( obj.hAxesSide2 ) )
                obj.hAxesSide2 = subplot( 'Position', obj.pos2A, 'parent', obj.hFigure );        % Defining and returning the handle of the sub-plot
                hold( obj.hAxesSide2,'on' );
            end        
            
            set( obj.hAxesSide2, 'XLim', [-1, 1], ...
                            'YLim', [-1, 1], ...
                            'ZLim', [-1, 1] )  
            
            tmp = quiver3( 0,0,0, xData(1), yData(1), zData(1), 'parent', obj.hAxesSide2, 'autoscale', 'off', 'linewidth', 4 );
            obj.hV_s2 = [obj.hV_s2, tmp];
            
        end
        
        
        function addZoomWindow( obj, idx, size )
            % This is the Zoom window for the plot
            obj.size_Z = size;
            obj.idx_Z  = idx;
            
            if ( isempty( obj.hAxesSide1 ) && isempty( obj.hAxesSide2 ) )
                % If The plot is first added to m plot
                set( obj.hAxesMain, 'Position', obj.pos0B ); 
            end
            
            obj.hA_s1Z = subplot( 'Position', obj.pos1A, 'parent', obj.hFigure ); 
            hold( obj.hA_s1Z,'on' );
            
            
            % Copy markers 
            obj.hM_s1Z = copyobj( obj.hMarkersMain, obj.hA_s1Z );
            
            % Copy Lines if exist
            if ~isempty( obj.hL_s1Z )     
                obj.hL_s1Z = copyobj( obj.hL_m, obj.hA_s1Z );   
            end
            
            if ~isempty( obj.hE )                   
                obj.hE_Z = copyobj( obj.hE, obj.hA_s1Z );                        
            end
            
            orig = obj.data{ idx }( :, 1 );
            
            set( obj.hA_s1Z,  'XLim',   [ -obj.size_Z + orig(1), obj.size_Z + orig(1) ] , ...         
                              'YLim',   [ -obj.size_Z + orig(2), obj.size_Z + orig(2) ] , ...    
                              'ZLim',   [ -obj.size_Z + orig(3), obj.size_Z + orig(3) ] , ...
                              'view',   get( obj.hAxesMain, 'view' ) )  
            
        end
        
        function addSidePlot( obj, idx, xdata, ydata, varargin )
            
            if ( idx ~= 1 && idx ~= 2 )
                error( "Wrong idx, please input 1 or 2" )
            end
            
            if ( isempty( obj.hAxesSide1 ) && isempty( obj.hA_side2 ) )
                % If The plot is first added to m plot
                set( obj.hAxesMain, 'Position', obj.pos0B ); 
            end
            
            if ( idx == 1 && isempty( obj.hAxesSide1 ) )
                obj.hAxesSide1 = subplot( 'Position', obj.pos1A, 'parent', obj.hFigure );        % Defining and returning the handle of the sub-plot
                hold( obj.hAxesSide1,'on' );
            end
            
            if ( idx == 2 && isempty( obj.hAxesSide2 ) )
                obj.hA_side2 = subplot( 'Position', obj.pos2A, 'parent', obj.hFigure );        % Defining and returning the handle of the sub-plot
                hold( obj.hAxesSide2,'on' );
            end            
            
                
            p = inputParser( );
            
            ckc1 = @(x) ( isnumeric( x ) && ( x > 0 ) ) ;
            ckc2 = @(x) ( isnumeric( x ) && all( x >= 0 & x <= 1        ) );
            ckc3 = @(x) ( ischar( x ) || isstring( x ) );
            
            addParameter( p,         'lineWidth', 5                , ckc1 );
            addParameter( p,         'lineColor', 0.82 * ones(1,3) , ckc2 );
            addParameter( p,         'lineStyle', "-"              , ckc3 );
            addParameter( p,        'markerSize', 10               , ckc1 );
            addParameter( p, 'addTrackingMarker', false            , @(x) islogical( x ) );
                
            parse( p, varargin{ : } )            

            r = p.Results;

            lw     = r.lineWidth;
            lc     = r.lineColor;
            l_sty  = r.lineStyle;
            ms     = r.markerSize;
            isON   = r.addTrackingMarker;

            
            if idx == 1
                tmp_p = obj.hAxesSide1;
            elseif idx == 2
                tmp_p = obj.hAxesSide2;
            end

            plot( xdata, ydata, 'parent',    tmp_p,  ...                               
                                 'color',       lc,  ...   
                             'LineWidth',       lw,  ... 
                             'LineStyle',    l_sty   );

            if isON 
               tmp = 'on' ;
            else
               tmp = 'off';
            end
            
            tmp_m = plot( xdata(1), ydata(1), 'parent', tmp_p, ...          
                                            'Marker',     "o", ...
                                        'MarkerSize',      ms, ...
                                   'MarkerEdgeColor',      lc, ...      
                                   'MarkerFaceColor', [1,1,1], ...
                                           'visible', tmp);
                                       
                                       
                               
            if idx == 1
                obj.hM_s1 = [obj.hM_s1, tmp_m ];
                obj.pX_s1 = [obj.pX_s1; xdata];
                obj.pY_s1 = [obj.pY_s1; ydata];
                
            elseif idx == 2
                obj.hM_s2 = [obj.hM_s2, tmp_m];                 
                obj.pX_s2 = [obj.pX_s2; xdata];
                obj.pY_s2 = [obj.pY_s2; ydata];                
            end
                                  
            
        end
        
    end
end

