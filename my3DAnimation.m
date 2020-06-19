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
        hFig
        hAxes
        hTitle
        hPlotsMarkers 
        hPlotsLines   = []
        
    end
    properties ( SetAccess = public )
        % [INTERNAL PROPERTIES]    
        lineIdx = {}
        posX    = []
        posY    = []
        posZ    = []
    end
    
    methods
        function obj = my3DAnimation( tVec, data , markerSize, markerColor, markerStyle )
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
            [ tmpN, ~ ] = size( markerColor );

            if ( length( data ) ~= length( markerSize  ) ) || ( length( data ) ~= tmpN ) || ...
               ( length( data ) ~= length( markerStyle ) ) 
                error( "Wrong size of input \n Input sizes are %d, %d, %d and %d for each", ...
                                      length( data ), length( markerSize ), tmpN, length( markerStyle ) ) 
            end
            
            % [Quick Sanity Check] Checking the size of time vector the input data's time series
            [~, tmpN] = size( data{ 1 } );
            if ( length( tVec ) ~= tmpN )
                error( "Wrong size of input \n Input sizes are %d, and %d for time Vector and the time series of the data", ...
                                                    length( tVec ), tmpN )                 
            end
            obj.tVec        = tVec;
            obj.data        = data;
            obj.markerSize  = markerSize;
            obj.markerColor = markerColor;
            obj.markerStyle = markerStyle;
            
            
            
            % Setting the default figure and Axes for the plot
            obj.hFig  = figure();
            pos   = [0.08 0.1 0.84 0.80];                                  % Position/size for the main plot - 3D real time plot
            obj.hAxes = axes( 'Position', pos, 'parent', obj.hFig );       % Defining and returning the handle of the plot

            
            obj.hTitle = title( obj.hAxes, sprintf( '[Time] %5.3f (s)', tVec(1) ) );
            
            hold( obj.hAxes,'on' ); axis( obj.hAxes, 'equal' )                                 % This will make the plot with equal ratio

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

        
        function connect( obj, idxMarkers, lineWidth, lineColor, lineStyle )
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
    end
end

