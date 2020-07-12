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
%
% =============================================================== %
%
% =============================================================== %
% [PROPERTIES] A single line description 
%   (1) data 
%       -  The 3D Position Data of the plot.
%
%   (2) markerSize:
%       -  The size of the marker for each data
%
%   (3) markerColor:
%       -  The color of the marker of each data.
%
%   (4) markerStyle:
%       -  The style of the marker of each data.
%
%   (5) hFig
%       - The handle of the figure 
%
%   (6) hAxes
%       - The handle of the axes
%
%   (7) hPlots
%       - The handles of plots, in most cases there will be multiple handles.
%         Thus returned in a "cell" form.
%
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
        markerSize
        markerColor
        markerStyle

        pos0 = [0.08 0.1 0.84 0.80];                          % Position/size for the main plot before adding plot 
        pos1 = [0.08 0.08 0.42 0.82];                         % Position/size for the main plot - 3D real time plot
        pos2 = [0.58 0.08 0.40 0.37];                         % Position/size for the under-sub-plot, drawn in the lower section
        pos3 = [0.58 0.55 0.40 0.40];                         % Position/size for the above-sub-plot, drawn in the upper section.
        
    end
    properties ( SetAccess = public )
        % [INTERNAL PROPERTIES]    
        
        hFig
        hFig_side1 = []
        hFig_side2 = []
        
        hAxes
        hAxes_side1 = []
        hAxes_side2 = []        
        
        hPlotsMarkers_side1 = []
        hPlotsX_side1 = []
        hPlotsY_side1 = []
        
        hPlotsMarkers_side2 = []
        hPlotsX_side2 = []
        hPlotsY_side2 = []
                
        hTitle
        hPlotsMarkers 
        hPlotsLines   = []        
        
        lineIdx = {}
        posX    = []
        posY    = []
        posZ    = []
    end
    
    methods
        function obj = my3DAnimation( tVec, data , varargin )
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
            %   (3) markerSize:
            %       -  The size of the marker for each data
            %          The length of the "markerSize" should be the same with data.
            %
            %   (4) markerColor:
            %       -  The color of the marker of each data.
            %          The length of the "markerColor" should be the same with data.
            %          Color represents the marker's edge. The face color of the marker is by default "white".
            %
            %   (5) markerStyle:
            %       -  The style of the marker of each data.
            %          The length of the "markerStyle" should be the same with data.
            
            % [Quick Sanity Check] Checking the size of the input data
            
            
            % Simple Parser for name-value pairing.
            p = inputParser( );
            p.KeepUnmatched = false;
            p.CaseSensitive = false;
            p.StructExpand  = true;     % By setting this False, we can accept a structure as a single argument.

            addParameter( p, 'markerSize',  NaN );
            addParameter( p, 'markerColor', NaN );
            addParameter( p, 'markerStyle', {}  );
            
            parse( p, varargin{ : } )
            
            r = p.Results;
            
            markerSize  = r.markerSize;
            markerColor = r.markerColor;
            markerStyle = r.markerStyle;

            % Check the size between the data and time vec
            [ ~, tmpN ] = size( data{ 1 } );
            
            if ( length( tVec ) ~= tmpN )
                error( "Wrong size of input \n Time vector size is %d but %d is given for given data length", ...
                                                      length( tVec ), tmpN) 
            end
            
            N = length( data );
            
            if isnan( markerColor )
                markerColor = repmat( [0.8200, 0.8200, 0.8200], N, 1 );    % Setting the default color as "grey" for the line 
            else
                [ tmpN, ~ ] = size( markerColor );                         % If input is not given,  
                if ( N ~= tmpN )
                    error( "Wrong size of input \n Number of input data is %d but %d is given for color", ...
                                                                           N,    tmpN ) 
                end
            end    

            if isnan( markerSize )
                markerSize = 5 * ones( 1, N );                                            % Setting the default line width as 5
            else
                if ( N ~= length( markerSize ) ) 
                    error( "Wrong size of input \n Number of input data is %d but %d is given for size", ...
                                                                            N, length( markerSize ) ) 
                end           
            end

            if isempty( markerStyle )
                markerStyle = repmat( "o", N, 1 );                                     % If lineStyle not given, setting the default line style as full line                                                     
            else
                if ( N ~= length( markerStyle ) ) 
                    error( "Wrong size of input \n Number of input data is %d but %d is given for style", ...
                                                                            N, length( markerStyle ) ) 
                end                        
            end

            obj.tVec        = tVec;
            obj.data        = data;
            obj.markerSize  = markerSize;
            obj.markerColor = markerColor;
            obj.markerStyle = markerStyle;
            
            
            % Setting the default figure and Axes for the plot
            obj.hFig  = figure();
            obj.hAxes = subplot( 'Position', obj.pos0, 'parent', obj.hFig );    
            obj.hTitle = title( obj.hAxes, sprintf( '[Time] %5.3f (s)', tVec(1) ) );
            hold( obj.hAxes,'on' ); axis( obj.hAxes, 'equal' )             

            % Plotting the Markers 
            for i = 1 : length( obj.data  )
                obj.hPlotsMarkers( i ) = plot3(  obj.data{ i }( 1,1 ), ...
                                                 obj.data{ i }( 2,1 ), ...
                                                 obj.data{ i }( 3,1 ), ...
                                  'parent', obj.hAxes                , ...
                                  'Marker', obj.markerStyle( i )     , ...
                         'MarkerEdgeColor', obj.markerColor( i, : )  , ...
                         'MarkerFaceColor', [1,1,1]                  , ...   
                              'MarkerSize', obj.markerSize( i ) );  
                                                           
                % Separately saving the x, y and z coordinates for each markers
                obj.posX = [ obj.posX; obj.data{ i }( 1,: ) ];
                obj.posY = [ obj.posY; obj.data{ i }( 2,: ) ];
                obj.posZ = [ obj.posZ; obj.data{ i }( 3,: ) ];
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
            
            % Getting the data from the index of the markers 
            
            % Simple Parser for name-value pairing.
            p = inputParser( );
            p.KeepUnmatched = false;
            p.CaseSensitive = false;
            p.StructExpand  = true;     % By setting this False, we can accept a structure as a single argument.

            addParameter( p, 'lineWidth', NaN );
            addParameter( p, 'lineColor', NaN );
            addParameter( p, 'lineStyle', {}  );
            parse( p, varargin{ : } )            
            
            r = p.Results;
            
            
            
            lineWidth  = r.lineWidth;
            lineColor  = r.lineColor;
            lineStyle  = r.lineStyle;
            
            
            if isnan( lineColor )
                lineColor = [0.8200, 0.8200, 0.8200];                        % Setting the default color as "grey" for the line 
            end    

            if isnan( lineWidth )
                lineWidth = 5;    
            end

            if isempty( lineStyle )
                lineStyle = '-';                                     % If lineStyle not given, setting the default line style as full line                                                                     
            end            
            
            tmph = plot3(  obj.posX( idxMarkers, 1 ), ...
                           obj.posY( idxMarkers, 1 ), ... 
                           obj.posZ( idxMarkers, 1 ), ...
                             'parent',  obj.hAxes   , ...
                          'linewidth', lineWidth    , ...
                          'linestyle', lineStyle    , ...
                              'color', lineColor        );     
            
            obj.hPlotsLines = [ obj.hPlotsLines, tmph         ];           % Horizontally appending the line handles
            
            if length( obj.hPlotsLines ) == 1
                obj.lineIdx = { idxMarkers }; 
            else
                obj.lineIdx = [ obj.lineIdx , {idxMarkers} ];              % Horizontally concatenating the indexs as cell, since the size of index might vary
            end
            
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

            if isVidRecord                                                 % If video record is ON

                fps     = 60 * vidRate;                                    % Frame-per-second of the video, 60Hz is default rate.
                writerObj = VideoWriter( videoName, 'MPEG-4' );            % Saving the video as "videoName" 
                writerObj.FrameRate = fps;                                 % How many frames per second.
                open( writerObj );                                         % Opening the video write file.

            end    


            for i = 1 : simStep : N

                
                set( obj.hTitle,'String', sprintf( '[Time] %5.3f (s)  x%2.1f', obj.tVec( i ), vidRate ) );

                for j = 1 : length( obj.data )
                    set( obj.hPlotsMarkers( j ), 'XData',   obj.data{ j }( 1, i ), ...
                                                 'YData',   obj.data{ j }( 2, i ), ...
                                                 'ZData',   obj.data{ j }( 3, i ) )    
                end 

                for j = 1 : length( obj.hPlotsLines )
                    set( obj.hPlotsLines( j ),   'XData',   obj.posX( obj.lineIdx{ j }, i ), ...
                                                 'YData',   obj.posY( obj.lineIdx{ j }, i ), ...
                                                 'ZData',   obj.posZ( obj.lineIdx{ j }, i ) )    
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
        
        
        function addSidePlot( obj, idx, xdata, ydata, varargin )% , xdata, ydata, isMarker )
            
            if ( isempty( obj.hAxes_side1 ) && isempty( obj.hAxes_side2 ) )
                set( obj.hAxes, 'Position', obj.pos1 ); 
            end
            
            if ( idx == 1 && isempty( obj.hAxes_side1 ) )
                obj.hAxes_side1 = subplot( 'Position', obj.pos2, 'parent', obj.hFig );        % Defining and returning the handle of the sub-plot
                hold( obj.hAxes_side1,'on' );
            end
            
            if ( idx == 2 && isempty( obj.hAxes_side2 ) )
                obj.hAxes_side2 = subplot( 'Position', obj.pos3, 'parent', obj.hFig );        % Defining and returning the handle of the sub-plot
                hold( obj.hAxes_side2,'on' );
            end            
            
            if ~isempty( varargin )
                
                p = inputParser( );
                p.KeepUnmatched = false;
                p.CaseSensitive = false;
                p.StructExpand  = true;     % By setting this False, we can accept a structure as a single argument.

                addParameter( p, 'lineWidth', NaN );
                addParameter( p, 'lineColor', NaN );
                addParameter( p, 'lineStyle', {}  );
                
                addParameter( p, 'markerSize' , NaN );
                addParameter( p, 'markerColor', NaN );
                addParameter( p, 'markerStyle', {}  );                
                
                parse( p, varargin{ : } )            

                r = p.Results;

                lw    = r.lineWidth;
                lc    = r.lineColor;
                l_sty = r.lineStyle;
                ms    = r.markerSize;
                mc    = r.markerColor;
                m_sty = r.markerStyle;


                if isnan( lc )
                    lc = [0.8200, 0.8200, 0.8200];     
                end    

                if isnan( lw )
                    lw = 5;    
                end

                if isnan( ms )
                    ms = 10;     
                end    

                if isnan( mc )
                    mc = [0.8200, 0.8200, 0.8200];    
                end                
                
                if isempty( l_sty )
                    l_sty = '-';                        
                end            

                if isempty( m_sty )
                    m_sty = 'o';   
                end                           

            else
                
                lc = [0.8200, 0.8200, 0.8200];     
                lw = 5;    
                ms = 10;     
                mc = [0.8200, 0.8200, 0.8200];    
                l_sty = '-';                        
                m_sty = 'o';                   
                
            end

            
            switch idx 
                
                case 1 
                    tmp_p = obj.hAxes_side1;

                case 2
                    tmp_p = obj.hAxes_side2;
                
                otherwise 
                    error( "Wrong idx, idx should be 1 or 2, but %d is given", ...
                                                                idx )
            end

            plot( xdata, ydata, 'parent',  tmp_p  ,    ...                               
                                 'color',  lc,  ...   
                             'LineWidth',  lw,  ... 
                             'LineStyle', l_sty   );
                         
            tmp_m = plot( xdata(1), ydata(1), 'parent', tmp_p, ...          
                                            'Marker',   m_sty, ...
                                        'MarkerSize',      ms, ...
                                   'MarkerEdgeColor',      mc, ...      
                                   'MarkerFaceColor', [1,1,1] );
                               
                               
                               
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

