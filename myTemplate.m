% [Project]        [M3X] Whip Project
% [Title]          Template File for 
%                  (1) x-y Plot 
%                  (2) 3D Animation of the MuJoCo simulation
% [Author]         Moses C. Nah
% [Creation Date]  Friday, May 29th, 2020
%
% [Emails]         Moses C. Nah   : mosesnah@mit.edu
%% (--) INITIALIZATION

clear all; close all; clc;
workspace;
cd( fileparts( matlab.desktop.editor.getActiveFilename ) );                % Setting the current directory as the folder where this "main.m" script is located

myFigureConfig(  'fontsize',  20, ...
                'lineWidth',   5, ...
               'markerSize',  25 );         
              
c  = myColor();                

clear tmp*

%% (1-) For x-y Plot
%% (1a) Parsing the txt File 

% Example                
txtFile = "optimization_log.txt";   % The name of the txt file.
                                    % YOU NEED TO PUT THE TXT FILE TO THE SAME DIRECTORY WITH THIS FOLDER
rawData = myTxtParse( txtFile );

% You can now access the txt file's data as following:
% rawData.Iter   - xdata
% rawData.output - data


%% (1b) Plotting X-Y Graph

% Just simply plot the graph and modify the properties!
plot( rawData.Iter, rawData.output, 'linewidth', 3, 'color', c.pink, 'linestyle', '-' )

% Save the plots as pdf for presentation/paper
% Uncomment this if you want to save the plot
mySaveFig( gcf, 'HiJosh' )

%% (2-) For 3D Animation Plot
%% (2a) Parsing the txt File 

% For the animation, you need to have the 'data_log.txt' file.
rawData = myTxtParse( 'data_log.txt' );

%% (2b) Running the 3D Animation

tStep = rawData.currentTime(2) - rawData.currentTime(1);                   % Time Step of the simulation
nodeN = size(rawData.geomXYZPositions, 1) / 3 ;                            % Number of markers of the simulation, dividing by 3 (x-y-z) gives us the number of geometry.
N     = length( rawData.currentTime );

genNodes = @(x) ( "node" + (1:x) );

% Setting the name for the markers
nodeN = 25;     % Number of nodes of the whip.
stringList = [ "NAMETHEGEOM1", "NAMETHEGEOM2", "NAMETHEGEOM3", "NAMETHEGEOM4",  genNodes( nodeN ) ];

% Setting the size of each markers
sizeList   = [    16,      16,            16, 8 * ones( 1, nodeN ) ];

% Setting the color of each markers
colorList  = [      repmat( c.pink, 3, 1); repmat( c.grey, nodeN , 1 ) ];

for i = 1: length( sizeList )
    markers( i ) = myMarker( rawData.geomXYZPositions( 3 * i - 2, : ), ... 
                             rawData.geomXYZPositions( 3 * i - 1, : ), ... 
                             rawData.geomXYZPositions( 3 * i    , : ), ...
                                             'name', stringList( i ) , ...
                                       'markersize',   sizeList( i ) , ...
                                      'markercolor',  colorList( i, : ) ); % Defining the markers for the plot
end

ani = my3DAnimation( tStep, markers );
ani.connectMarkers( 1, ["NAMETHEGEOM1",  "NAMETHEGEOM2", "NAMETHEGEOM3"], 'linecolor', c.grey )        
                                                                           % Connecting the markers with a line.

tmpLim = 2.0;
set( ani.hAxes{1},   'XLim',   [ -tmpLim , tmpLim ] , ...                  
                     'YLim',   [ -tmpLim , tmpLim ] , ...    
                     'ZLim',   [ -tmpLim , tmpLim ] , ...
                     'view',   [44.9986   12.8650 ]     )                  % Set the view, xlim, ylim and zlim of the animation
                                                                           % ani.hAxes{1} is the axes handle for the main animation


willSave = false;           % Set this as 'true' if you want to save the video
ani.run( 0.2, willSave, 'output' ) 

%% (3-) Plot for the time vs. velocity
%% (3a) Read the data_log.txt

% For the animation, you need to have the 'data_log.txt' file.
rawData1 = myTxtParse( 'linear_data_log.txt' );
rawData2 = myTxtParse( 'nontapered_data_log.txt' );
rawData = {rawData1, rawData2};
%% (3b) Velocity Calculation
% Calculate the velocity 

num = 30;
mat = bone( num );

idx = 1;

if idx == 1
    startTime = 0.3; endTime = 0.3 + 0.58333;
elseif idx == 2
    startTime = 0.3; endTime = 0.3 + 0.40679; 
end

tmpN = size( rawData{idx}.geomXYZVelocities, 1 ); N = tmpN/3; clear tmp*

for i = 1 : N
   
    tmp = rawData{ idx }.geomXYZVelocities( 3 * i - 2 : 3 * i, : );
    
    vel( i, : ) = vecnorm( tmp );
    
end

hold on
% for i = 1 : 25
%     plot( rawData{ idx }.currentTime, vel( i + 3,: ), 'color', mat( i,: ) )
% end
% h = fill( [startTime, endTime, endTime , startTime],[0,0,450,450], 'blue');
% h.FaceAlpha=0.1; h.EdgeAlpha=0;


for i = 1 : 25
    plot3( i * ones(1, size(tmp,2 ) ),  rawData{ idx }.currentTime, vel( i + 3,: ), 'color', mat( i,: ) )
end


set( gca, 'xlim', [1, 25] );
set( gca, 'ylim', [0.3, 1.0] );
set( gca, 'zlim', [0.0, 450] );
set( gca, 'view', [53.3167, 22.1331] );
xlabel( 'Node Number[-]', 'fontsize', 40 )
ylabel( 'Time [sec]', 'fontsize', 40 )
zlabel( 'Velocity [m/s]', 'fontsize', 40 )
% yline( 340, 'linestyle', '--', 'linewidth',2 )


% set( gca, 'xlim', [0.3, 1.0] );
% set( gca, 'ylim', [  0, 450] );
% xlabel( 'Time [sec]', 'fontsize', 40 )
% ylabel( 'Velocity [m/s]', 'fontsize', 40 )
% yline( 340, 'linestyle', '--', 'linewidth',2 )
mySaveFig( gcf, ['output', num2str( idx ) ] )


