classdef my3DAnimation < handle
% my3DAnimation class for setting up the 3D animation with the input data.
%
% Why inherit from handle? 
% [REF] https://www.mathworks.com/matlabcentral/answers/352043-how-can-i-modify-private-properties-from-inside-a-class
% =============================================================== %
% [CREATED BY]: Moses C. Nah
% [   DATE   ]: 08-June-2020
% =============================================================== %
%
% =============================================================== %
% [DESCRIPTION]
%   Class for setting-up a 3D animation.
%   Several methods and properties (innate variables) are 
%   
% =============================================================== %
%
% =============================================================== %
%
% =============================================================== %
% [METHODS]
%   (1) run( fps, videoName )
%       - running the animation, and saving the video if defined.
%
%   (2) hAxes
%       - The handle of the axes
%
%   (3) hPlots
%       - The handles of plots, in most cases there will be multiple handles.
%         Thus returned in a "cell" form.
%
% =============================================================== %

    
    properties ( SetAccess = private )
        tVec
        data

        
        pos0A = [0.08 0.1 0.84 0.80];     % Position/size for the main plot before adding plot 
        pos0B = [0.08 0.08 0.42 0.82];    % Position/size for the main plot - 3D real time plot
        pos1A = [0.58 0.08 0.40 0.37];    % Position/size for the under-sub-plot, drawn in the lower section
        pos2A = [0.58 0.55 0.40 0.40];    % Position/size for the above-sub-plot, drawn in the upper section.
        
    end
    
    properties ( SetAccess = public )
        
        hFig  = []
        
        hAxes_main  = []
        hAxes_side1 = []
        hAxes_side2 = []   
        
        hPlotsLines   = []      

        hPlotsX_main  = []
        hPlotsY_main  = []
        hPlotsZ_main  = []
        
        hPlotsLineIdx_main = logical.empty        
        hPlotsMarkers_main = []
        
        hPlotsX_side1 = []
        hPlotsY_side1 = []
        hPlotsMarkers_side1 = []        
        
        hPlotsX_side2 = []
        hPlotsY_side2 = []
        hPlotsMarkers_side2 = []
                
        hTitle

    end
    
    methods
        function obj = my3DAnimation( tVec, data, varargin )
            %[CONSTRUCTOR #1] Construct an instance of this class
            %   (1) tVec [sec]
            %       -  The time vector of the simulation
            %       - 
            %   (2) data 
            %       -  The 3D Position Data of the plot.
            %          The data is given as a cell, and each cell is composed of 3 x N array.
            %          3 rows stand for X, Y and Z coordinate position data, and N is the time series. 
            %          This data is a single marker for the animation
            %

            % [Quick Sanity Check] Check the size between the data and time vec
            tmpN = size( data{ 1 }, 2 );
            
            if ( length( tVec ) ~= tmpN )
                error( "Wrong size of input \n Time vector size is %d but %d is given for given data length", ...
                                                      length( tVec ), tmpN) 
            end
            
            p = inputParser( );
            N = length( data );

            % [TIP] We can add a function handle for a simple input-type check
            ckc1 = @( x ) ( isnumeric( x ) &&   all( x > 0 ) && ( length( x ) == N ) ) ;
            ckc2 = @( x ) ( ( isstring( x ) || ischar( x ) ) && ( length( x ) == N ) ) ;
            ckc3 = @( x ) ( isnumeric( x ) &&  all( x >= 0 & x <= 1, [1,2] ) && ( size( x, 1 ) == N ) );

            addParameter( p,  'markerSize',  5 * ones( 1, N )                        , ckc1 );
            addParameter( p, 'markerStyle',  repmat( "o", N, 1 )                     , ckc2 );
            addParameter( p, 'markerColor',  repmat( [0.8200, 0.8200, 0.8200], N, 1 ), ckc3 );

            parse( p, varargin{ : } )
            
            r = p.Results;
            
            ms    =  r.markerSize;
            mc    = r.markerColor;
            m_sty = r.markerStyle;

            obj.tVec = tVec;
            obj.data = data;
            
            
            % Setting the default figure and Axes for the plot
            obj.hFig  = figure();
            obj.hAxes_main = subplot( 'Position', obj.pos0A, 'parent', obj.hFig);    
            obj.hTitle = title( obj.hAxes_main, sprintf( '[Time] %5.3f (s)', tVec( 1 ) ) );
            hold( obj.hAxes_main,'on' ); axis( obj.hAxes_main, 'equal' )             

            % Plotting the Markers 
            for i = 1 : length( obj.data )
                obj.hPlotsMarkers_main( i ) = plot3(  obj.data{ i }( 1,1 ), ...
                                                      obj.data{ i }( 2,1 ), ...
                                                      obj.data{ i }( 3,1 ), ...
                                                  'parent', obj.hAxes_main, ...
                                                  'Marker',     m_sty( i ), ...
                                         'MarkerEdgeColor',     mc( i, : ), ...
                                         'MarkerFaceColor',        [1,1,1], ...   
                                              'MarkerSize',        ms( i ) );  
                                                           
                % Separately saving the x, y and z coordinates for each markers
                obj.hPlotsX_main = [ obj.hPlotsX_main; obj.data{ i }( 1,: ) ];
                obj.hPlotsY_main = [ obj.hPlotsY_main; obj.data{ i }( 2,: ) ];
                obj.hPlotsZ_main = [ obj.hPlotsZ_main; obj.data{ i }( 3,: ) ];
            end

            
        end

        
        function connect( obj, idxMarkers, varargin)
            %connect: connecting markers with lines
            % =============================================================== %
            % [INPUTS]
            %   (1) idxMarkers (int) List
            %       - the index of the markers that are aimed to be connected
            %
            %   (2) lineWidth
            %       - the width of the line which conencts the markers
            %
            %   (3) lineColor
            %       - the color of the line which connects the markers.
            
            % [SANITY CHECK], the maximum index number should not exceed the data size
            if max( idxMarkers ) > length( obj.data )
               error( "Given index is larger than the size of data, maximum number of idx is %d but %d is upperlimit", ...
                                                                             max( idxMarkers ), length( obj.data) )
            end
            
            idx = false( 1, length( obj.data ) ); idx( idxMarkers ) = true; % Turning on the data that should be connected
            
            % Simple Parser for name-value pairing.
            p = inputParser( );

            addParameter( p, 'lineWidth', 5                , @(x) ( isnumeric( x ) && ( x > 0 ) ) );
            addParameter( p, 'lineColor', 0.82 * ones(1,3) , @(x) ( isnumeric( x ) && all( x >= 0 & x <= 1        ) ) );
            addParameter( p, 'lineStyle', "-"              , @(x) ( ischar( x ) || isstring( x ) ) );

            parse( p, varargin{ : } )            
            
            r = p.Results;
            
            lw    = r.lineWidth;
            lc    = r.lineColor;
            l_sty = r.lineStyle;
            
            tmph = plot3(  obj.hPlotsX_main( idx, 1 ), ...
                           obj.hPlotsY_main( idx, 1 ), ... 
                           obj.hPlotsZ_main( idx, 1 ), ...
                         'parent',  obj.hAxes_main   , ...
                                  'linewidth', lw    , ...
                                  'linestyle', l_sty , ...
                                      'color', lc        );     
            
            obj.hPlotsLines = [ obj.hPlotsLines, tmph  ];                  % Horizontally appending the line handles
            obj.hPlotsLineIdx_main = [ obj.hPlotsLineIdx_main; idx ];
            
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

            if simStep == 0
               simStep = 1; 
            end
            
            if isVidRecord                                                 % If video record is ON

                fps     = 60 * vidRate;                                    % Frame-per-second of the video, 60Hz is default rate.
                writerObj = VideoWriter( videoName, 'MPEG-4' );            % Saving the video as "videoName" 
                writerObj.FrameRate = fps;                                 % How many frames per second.
                open( writerObj );                                         % Opening the video write file.

            end    
            
            N
            simStep

            for i = 1 : simStep : N

                
                set( obj.hTitle,'String', sprintf( '[Time] %5.3f (s)  x%2.1f', obj.tVec( i ), vidRate ) );

                for j = 1 : length( obj.data )
                    set( obj.hPlotsMarkers_main( j ), 'XData',   obj.data{ j }( 1, i ), ...
                                                      'YData',   obj.data{ j }( 2, i ), ...
                                                      'ZData',   obj.data{ j }( 3, i ) )    
                end 

                for j = 1 : length( obj.hPlotsLines )                    
                    set( obj.hPlotsLines( j ),   'XData', obj.hPlotsX_main( obj.hPlotsLineIdx_main( j,: ), i ), ...
                                                 'YData', obj.hPlotsY_main( obj.hPlotsLineIdx_main( j,: ), i ), ...
                                                 'ZData', obj.hPlotsZ_main( obj.hPlotsLineIdx_main( j,: ), i ) )    
                end
                
                if ~isempty( obj.hPlotsMarkers_side1 )
                    
                    for k = 1 : length( obj.hPlotsMarkers_side1 ) 
                        set( obj.hPlotsMarkers_side1( k ), 'XData', obj.hPlotsX_side1( k, i ), ...
                                                           'YData', obj.hPlotsY_side1( k, i ) )
                    end
                    
                end
                
                if ~isempty( obj.hPlotsMarkers_side2 )
                    
                    for k = 1 : length( obj.hPlotsMarkers_side2 ) 
                        set( obj.hPlotsMarkers_side2( k ), 'XData', obj.hPlotsX_side2( k, i ), ...
                                                           'YData', obj.hPlotsY_side2( k, i ) )                        
                    end                    
                    
                end                

                if isVidRecord                                             % If videoRecord is ON
                    frame = getframe( obj.hFig );                          % Get the current frame of the figure
                    writeVideo( writerObj, frame );                        % Writing it to the mp4 file/
                else                                                       % If videoRecord is OFF
                    drawnow                                                % Just simply show at Figure
                end

            end   

            if isVidRecord
                close( writerObj );
            end         

        end
        
        
        function addSidePlot( obj, idx, xdata, ydata, varargin )
            
            if ( idx ~= 1 && idx ~= 2 )
                error( "Wrong idx, please input 1 or 2" )
            end
            
            if ( isempty( obj.hAxes_side1 ) && isempty( obj.hAxes_side2 ) )
                % If The plot is first added to main plot
                set( obj.hAxes_main, 'Position', obj.pos0B ); 
            end
            
            if ( idx == 1 && isempty( obj.hAxes_side1 ) )
                obj.hAxes_side1 = subplot( 'Position', obj.pos1A, 'parent', obj.hFig );        % Defining and returning the handle of the sub-plot
                hold( obj.hAxes_side1,'on' );
            end
            
            if ( idx == 2 && isempty( obj.hAxes_side2 ) )
                obj.hAxes_side2 = subplot( 'Position', obj.pos2A, 'parent', obj.hFig );        % Defining and returning the handle of the sub-plot
                hold( obj.hAxes_side2,'on' );
            end            
            
                
            p = inputParser( );
            
            ckc1 = @(x) ( isnumeric( x ) && ( x > 0 ) ) ;
            ckc2 = @(x) ( isnumeric( x ) && all( x >= 0 & x <= 1        ) );
            ckc3 = @(x) ( ischar( x ) || isstring( x ) );
            
            addParameter( p, 'lineWidth'  , 5                , ckc1 );
            addParameter( p, 'lineColor'  , 0.82 * ones(1,3) , ckc2 );
            addParameter( p, 'lineStyle'  , "-"              , ckc3 );
            addParameter( p, 'addTrackingMarker', false      , @(x) islogical( x ) );
            
                
            parse( p, varargin{ : } )            

            r = p.Results;

            lw    = r.lineWidth;
            lc    = r.lineColor;
            l_sty = r.lineStyle;
            isON  = r.addTrackingMarker;

            if idx == 1
                tmp_p = obj.hAxes_side1;
            elseif idx == 2
                tmp_p = obj.hAxes_side2;
            end

            plot( xdata, ydata, 'parent',  tmp_p  ,    ...                               
                                 'color',  lc,  ...   
                             'LineWidth',  lw,  ... 
                             'LineStyle', l_sty   );

            if isON 
               tmp = 'on' ;
            else
               tmp = 'off';
            end
            
            tmp_m = plot( xdata(1), ydata(1), 'parent', tmp_p, ...          
                                            'Marker',     "o", ...
                                        'MarkerSize',  2 * lw, ...
                                   'MarkerEdgeColor',      lc, ...      
                                   'MarkerFaceColor', [1,1,1], ...
                                           'visible', tmp);
                               
            if idx == 1
                obj.hPlotsMarkers_side1 = [obj.hPlotsMarkers_side1, tmp_m ];
                obj.hPlotsX_side1 = [obj.hPlotsX_side1; xdata];
                obj.hPlotsY_side1 = [obj.hPlotsY_side1; ydata];
                
            elseif idx == 2
                obj.hPlotsMarkers_side2 = [obj.hPlotsMarkers_side2, tmp_m];                 
                obj.hPlotsX_side2 = [obj.hPlotsX_side2; xdata];
                obj.hPlotsY_side2 = [obj.hPlotsY_side2; ydata];                
            end
                                  
                         
            
        end
        
    end
end

