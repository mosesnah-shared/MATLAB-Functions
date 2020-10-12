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
rawData = myTxtParse( 'data_log_T2.txt' );

%% (2b) Running the 3D Animation

tStep = rawData.currentTime(2) - rawData.currentTime(1);                   % Time Step of the simulation
nodeN = size(rawData.geomXYZPositions, 1) / 3 ;                            % Number of markers of the simulation, dividing by 3 (x-y-z) gives us the number of geometry.
N     = length( rawData.currentTime );

genNodes = @(x) ( "node" + (1:x) );
stringList = [ "Target", "SH", "EL", "EE",  genNodes( 25 ) ];              % 25 Nodes for the whip

% Setting the size of each markers
sizeList   = [ 16, 16, 16, 16, 8 * ones( 1, 25 ) ];

% Setting the color of each markers
colorList  = [    c.blue; repmat( c.blue, 3, 1); repmat( c.grey, 25 , 1 ) ];

for i = 1: length( sizeList )
    markers( i ) = myMarker( rawData.geomXYZPositions( 3 * i - 2, : ), ... 
                             rawData.geomXYZPositions( 3 * i - 1, : ), ... 
                             rawData.geomXYZPositions( 3 * i    , : ), ...
                                             'name', stringList( i ) , ...
                                       'markersize',   sizeList( i ) , ...
                                      'markercolor',  colorList( i, : ) ); % Defining the markers for the plot
end

ani = my3DAnimation( tStep, markers );
ani.connectMarkers( 1, [ "SH", "EL", "EE" ], 'linecolor', c.grey )        
                                                                           % Connecting the markers with a line.

tmpLim = 2.5;
set( ani.hAxes{1},   'XLim',   [ -tmpLim , tmpLim ] , ...                  
                     'YLim',   [ -tmpLim , tmpLim ] , ...    
                     'ZLim',   [ -tmpLim , tmpLim ] , ...
                     'view',   [44.9986   12.8650 ]     )                  % Set the view, xlim, ylim and zlim of the animation
                                                                           % ani.hAxes{1} is the axes handle for the main animation
                                                                           
% Calculating curvature (kappa) of the movement. 
qacc  = rawData.jointAccActual(1:4,:);
qvel  = rawData.jointVelActual(1:4,:);

ttmp = qacc - qvel ./ sum( qvel.^2 ).* sum( qvel.*qacc );

kappa = ( 1./sum( qvel.^2 ) ) .* sqrt( sum( ttmp.^2 ) ) ;
                                         
tmp1 = my2DLine( rawData.currentTime, kappa, 'linecolor', c.blue, 'linestyle', '-', 'linewidth', 6 );
ani.addTrackingPlots( 2, tmp1 ); 

set( ani.hAxes{ 2 }, 'xlim', [0.1, 2.5 ], 'ylim', [0, 300] );
h = fill( [0.1, 0.6833, 0.6833, 0.1],[0, 0, 300, 300], c.grey, 'parent', ani.hAxes{ 2 } );
h.FaceAlpha=0.4; h.EdgeAlpha=0;      


tmp1 = my2DLine( rawData.currentTime, kappa, 'linecolor', c.blue, 'linestyle', '-', 'linewidth', 6 );
ani.addTrackingPlots( 3, tmp1 ); 
set( ani.hAxes{ 3 }, 'xlim', [0.1, 0.6833 ], 'ylim', [0, 3] );
h = fill( [0.1, 0.6833, 0.6833, 0.1],[0, 0, 3, 3], c.grey, 'parent', ani.hAxes{ 3 } );
h.FaceAlpha=0.4; h.EdgeAlpha=0;     

%                  
% set( ani.hAxes{ 3 }, 'xlim', [0, 1.5 ], ...
%                      'ylim', [-5, 10] );                 
%    
% h = fill( [0.3, 1.25, 1.25, 0.3],[-2, -2, 4, 4], c.grey, 'parent', ani.hAxes{ 2 } );
% h.FaceAlpha=0.4; h.EdgeAlpha=0;      

% Add side plots
% For the Angular Position along time
% tmp1 = my2DLine( rawData.currentTime, rawData.jointAngleActual( 1, : ), 'linecolor', c.pink,   'linestyle', '-', 'linewidth', 6 );
% tmp2 = my2DLine( rawData.currentTime, rawData.jointAngleActual( 2, : ), 'linecolor', c.green,  'linestyle', '-', 'linewidth', 6 );
% tmp3 = my2DLine( rawData.currentTime, rawData.jointAngleActual( 3, : ), 'linecolor', c.blue,   'linestyle', '-', 'linewidth', 6 );
% tmp4 = my2DLine( rawData.currentTime, rawData.jointAngleActual( 4, : ), 'linecolor', c.yellow, 'linestyle', '-', 'linewidth', 6 );

% ani.addTrackingPlots( 2, tmp1 );      
% ani.addTrackingPlots( 2, tmp2 );      
% ani.addTrackingPlots( 2, tmp3 );      
% ani.addTrackingPlots( 2, tmp4 );      
% 
% plot( rawData.currentTime, rawData.pZFT( 1, : ), 'parent', ani.hAxes{ 2 }, 'color', c.pink,   'linestyle', "--", 'linewidth', 3 );
% plot( rawData.currentTime, rawData.pZFT( 2, : ), 'parent', ani.hAxes{ 2 }, 'color', c.green,  'linestyle', "--", 'linewidth', 3 );
% plot( rawData.currentTime, rawData.pZFT( 3, : ), 'parent', ani.hAxes{ 2 }, 'color', c.blue,   'linestyle', "--", 'linewidth', 3 );
% plot( rawData.currentTime, rawData.pZFT( 4, : ), 'parent', ani.hAxes{ 2 }, 'color', c.yellow, 'linestyle', "--", 'linewidth', 3 );
%      
% tmp1 = my2DLine( rawData.currentTime, rawData.jointVelActual( 1, : ), 'linecolor', c.pink,   'linestyle', '-', 'linewidth', 6 );
% tmp2 = my2DLine( rawData.currentTime, rawData.jointVelActual( 2, : ), 'linecolor', c.green,  'linestyle', '-', 'linewidth', 6 );
% tmp3 = my2DLine( rawData.currentTime, rawData.jointVelActual( 3, : ), 'linecolor', c.blue,   'linestyle', '-', 'linewidth', 6 );
% tmp4 = my2DLine( rawData.currentTime, rawData.jointVelActual( 4, : ), 'linecolor', c.yellow, 'linestyle', '-', 'linewidth', 6 );
% 
% ani.addTrackingPlots( 3, tmp1 );      
% ani.addTrackingPlots( 3, tmp2 );      
% ani.addTrackingPlots( 3, tmp3 );      
% ani.addTrackingPlots( 3, tmp4 );      
% 
% plot( rawData.currentTime, rawData.vZFT( 1, : ), 'parent', ani.hAxes{ 3 }, 'color', c.pink,   'linestyle', "--", 'linewidth', 3 );
% plot( rawData.currentTime, rawData.vZFT( 2, : ), 'parent', ani.hAxes{ 3 }, 'color', c.green,  'linestyle', "--", 'linewidth', 3 );
% plot( rawData.currentTime, rawData.vZFT( 3, : ), 'parent', ani.hAxes{ 3 }, 'color', c.blue,   'linestyle', "--", 'linewidth', 3 );
% plot( rawData.currentTime, rawData.vZFT( 4, : ), 'parent', ani.hAxes{ 3 }, 'color', c.yellow, 'linestyle', "--", 'linewidth', 3 );
%      
% set( ani.hAxes{ 2 }, 'xlim', [0, 1.5 ], ...
%                      'ylim', [-2, 4] );
%                  
% set( ani.hAxes{ 3 }, 'xlim', [0, 1.5 ], ...
%                      'ylim', [-5, 10] );                 
%    
% h = fill( [0.3, 1.25, 1.25, 0.3],[-2, -2, 4, 4], c.grey, 'parent', ani.hAxes{ 2 } );
% h.FaceAlpha=0.4; h.EdgeAlpha=0;                 
% 
% h = fill( [0.3, 1.25, 1.25, 0.3],[-5, -5, 10, 10], c.grey, 'parent', ani.hAxes{ 3 } );
% h.FaceAlpha=0.4; h.EdgeAlpha=0;             

willSave = true;           % Set this as 'true' if you want to save the video
ani.run( 0.2, willSave, 'output' ) 

%% (2c) MSE Calculation.

t_start = 0.3;
t_end   = 0.3 + 0.5833;
idx_list = find( (rawData.currentTime >= t_start) & (rawData.currentTime <= t_end) );

for idx_J = 1:4


if     idx_J == 1
    tmpc = c.pink;
    
elseif idx_J == 2    
    tmpc = c.green;
    
elseif idx_J == 3
    tmpc = c.blue;
    
elseif idx_J == 4
    tmpc = c.yellow;
    
end
figure( )
plot( rawData.currentTime( idx_list ), rawData.jointAngleActual( idx_J, idx_list ),  '-', 'linewidth', 5, 'color', tmpc )
hold on
plot( rawData.currentTime( idx_list ), rawData.pZFT( idx_J, idx_list ), '--', 'linewidth', 5, 'color', tmpc )
set( gca, 'xlim', [t_start, t_end], 'ylim', [-2, 2.5]);

tmp = 1/length( idx_list ) * sqrt( sum( ( rawData.pZFT( idx_J, idx_list ) - rawData.jointAngleActual( idx_J, idx_list ) ).^2 ) );
tmp
% plot( rawData.currentTime, rawData.jointAngleActual( 2, idx_list ), rawData.currentTime, rawData.pZFT( 2, idx_list ) )
% plot( rawData.currentTime, rawData.jointAngleActual( 3, idx_list ), rawData.currentTime, rawData.pZFT( 3, idx_list ) )
% plot( rawData.currentTime, rawData.jointAngleActual( 4, idx_list ), rawData.currentTime, rawData.pZFT( 4, idx_list ) )
mySaveFig( gcf, ['J', num2str( idx_J )] );
end
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


