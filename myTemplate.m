% [Project]        [M3X] Whip Project
% [Title]          Template File for 
%                  (1) x-y Plot 
%                  (2) 3D Animation of the MuJoCo simulation
% [Author]         Moses C. Nah
% [Creation Date]  Friday, May 29th, 2020
%
% [Emails]         Moses C. Nah   : mosesnah@mit.edu
%% (--) INITIALIZATION

clear all; close all; clc; workspace;


cd( fileparts( matlab.desktop.editor.getActiveFilename ) );                % Setting the current directory (cd) as the current location of this folder. 
addpath( 'myGraphics' );
addpath( 'myRobots' );
addpath( 'myUtils' );

myFigureConfig( 'fontsize', 20, ...
               'lineWidth',  5, ...
              'markerSize', 25    )     
             
global c                                                                   % Setting color structure 'c' as global variable
c  = myColor();                                                     

%% (--) ========================================================
%% (1-) Iter vs. Optimization Results
%% --- (1 - a) Parsing the txt File 

% Example                
txtFile = "optimization_log.txt";   % The name of the txt file.
                                    % YOU NEED TO PUT THE TXT FILE TO THE SAME DIRECTORY WITH THIS FOLDER
data = myTxtParse( txtFile );

% You can now access the txt file's data as following:
% data.Iter   - xdata
% data.output - data

%% --- (1 - b) Plotting 2D xyz Graph
% Just simply plot the graph and modify the properties!
plot( data.Iter, data.output, 'linewidth', 3, 'color', c.pink, 'linestyle', '-' )

% Save the plots as pdf for presentation/paper
% Uncomment this if you want to save the plot
mySaveFig( gcf, 'example' )

%% (--) ========================================================
%% (2-) Generating 3D Animation
%% --- (2 - a) Parsing the txt File 

data = myTxtParse( 'data_log_sparse_1.txt' );

c_m  = c.blue;

dt    = data.currentTime( 2 ) - data.currentTime( 1 );                     % Time Step of the simulation
nodeN = size( data.geomXYZPositions, 1) / 3 ;                              % Number of markers of the simulation, dividing by 3 (x-y-z) gives us the number of geometry.


genNodes = @(x) ( "node" + (1:x) );
nodeN = nodeN - 4;
stringList = [ "Target", "SH", "EL", "EE",  genNodes( nodeN ) ];       % 3 Upper limb markers + 1 target

% Marker in order, target (1), upper limb (3, SH, EL, WR) and Whip (25) 
sizeList   = [ 24, 40, 40, 40, 12 * ones( 1, nodeN ) ];                        % Setting the size of each markers
colorList  = [ c_m; repmat( c_m, 3, 1); repmat( c.grey, nodeN , 1 ) ];  % Setting the color of each markers

for i = 1: nodeN + 4    % Iterating along each markers
    markers( i ) = myMarker( data.geomXYZPositions( 3 * i - 2, : ), ... 
                             data.geomXYZPositions( 3 * i - 1, : ), ... 
                             data.geomXYZPositions( 3 * i    , : ), ...
                                          'name', stringList( i ) , ...
                                    'markersize',   sizeList( i ) , ...
                                   'markercolor',  colorList( i, : ) );    % Defining the markers for the plot
end


ani = myAnimation( dt, markers );                                        % Input (1) Time step of sim. (2) Marker Information
ani.connectMarkers( 1, [ "SH", "EL", "EE" ], 'linecolor', c.grey )        
                                                                           % Connecting the markers with a line.

tmpLim = 2.4;
set( ani.hAxes{ 1 }, 'XLim',   [ -tmpLim , tmpLim ] , ...                  
                     'YLim',   [ -tmpLim , tmpLim ] , ...    
                     'ZLim',   [ -tmpLim , tmpLim ] , ...
                     'view',   [0   0] )
%                      'view',   [23.8506   15.1025 ] )
%                      'view',   [41.8506   15.1025 ]     )                

robot = my4DOFRobot( );  
robot.initialize();

% For animation, the forward kinematics of the elbow and end-effector joint
pEL = robot.forwardKinematics( 2, [ 0; 0;             0 ] );               % Position of the elbow
pEE = robot.forwardKinematics( 2, [ 0; 0; -robot.L( 2 ) ] );               % Position of the end-effector


sym_array = [ robot.M, robot.L, robot.Lc, reshape( robot.I', 1, [] ), robot.g ];
val_array = { 1.595, 0.869, ... Mass   of each limb segment, ordered from proximal to distal (upperarm - forearm)
              0.294, 0.291, ... Length of each limb segment, ordered from proximal to distal (upperarm - forearm)
              0.129, 0.112, ... Length from proximal joint to center of mass, ordered from proximal to distal (upperarm - forearm)
             0.0119, 0.0119, 0.0013, ... Moment of inertia of I1xx, I1yy, I1zz, w.r.t. center of mass.
             0.0048, 0.0049, 0.0005, ... Moment of inertia of I2xx, I2yy, I2zz, w.r.t. center of mass.
                  9.81 };  % Gravity


% Substituting the symbol's values to values
pEL = subs( pEL, sym_array, val_array );
pEE = subs( pEE, sym_array, val_array );        

% pEL   = robot.calcForwardKinematics( 2, [0;0;     0], data.pZFT  );
% pEE   = robot.calcForwardKinematics( 2, [0;0;-0.291], data.pZFT  );
% pSH   = zeros( 2, length( pEL ) );
ani.addGraphicObject( 1, myMarker( pEL( 1, : ), pEL( 2, : ), pEL( 3, : ), 'markerSize', 40, 'name', "EL_ZFT", 'markerColor', c_m, 'markerAlpha', 0.3 ) );
ani.addGraphicObject( 1, myMarker( pEE( 1, : ), pEE( 2, : ), pEE( 3, : ), 'markerSize', 40, 'name', "EE_ZFT", 'markerColor', c_m, 'markerAlpha', 0.3 ) );
ani.connectMarkers( 1, [ "SH", "EL_ZFT" "EE_ZFT" ], 'linecolor', c.grey, 'lineWidth', 3, 'lineStyle', '--' );


% TARGET (1:3) SH (4:6) EL (7:9) EE(10:12)
v_EE = data.geomXYZVelocity( 10:12,  : );
v_EE_m = sqrt( sum( v_EE.^2 ) );
% plot( data.currentTime,  v_EE_m );
% tmp1 = my2DLine( data.currentTime, v_EE_m, 'linecolor', c.purple_plum,   'linestyle', '-', 'linewidth', 6 );

% ani.addTrackingPlots( 2, tmp1 );           


% tmp11 = my2DLine( data.currentTime, data.inputVal( 1, : ), 'linecolor', c.pink,   'linestyle', '-', 'linewidth', 6 );
% tmp22 = my2DLine( data.currentTime, data.inputVal( 2, : ), 'linecolor', c.green,  'linestyle', '-', 'linewidth', 6 );
% tmp33 = my2DLine( data.currentTime, data.inputVal( 3, : ), 'linecolor', c.blue,   'linestyle', '-', 'linewidth', 6 );
% tmp44 = my2DLine( data.currentTime, data.inputVal( 4, : ), 'linecolor', c.yellow, 'linestyle', '-', 'linewidth', 6 );
% ani.addTrackingPlots( 2, tmp11 );           
% ani.addTrackingPlots( 2, tmp22 );           
% ani.addTrackingPlots( 2, tmp33 );           
% ani.addTrackingPlots( 2, tmp44 );  

% a1 = area( t_vec, v_vec1, 'FaceColor',  c.yellow );  
% a1.FaceAlpha = 0.2; a1.EdgeAlpha = 0;
% 
% a2 = area( t_vec, v_vec5, 'FaceColor',  c.yellow );  
% a2.FaceAlpha = 0.2; a2.EdgeAlpha = 0;
% 
% plot( ani.hAxes{ 2 }, data.currentTime, data.dpZFT( 1, : ), 'color', c.pink,   'linestyle', '--', 'linewidth', 3 );
% plot( ani.hAxes{ 2 }, data.currentTime, data.dpZFT( 2, : ), 'color', c.green,  'linestyle', '--', 'linewidth', 3 );
% plot( ani.hAxes{ 2 }, data.currentTime, data.dpZFT( 3, : ), 'color', c.blue,   'linestyle', '--', 'linewidth', 3 );
% plot( ani.hAxes{ 2 }, data.currentTime, data.dpZFT( 4, : ), 'color', c.yellow, 'linestyle', '--', 'linewidth', 3 );

% ani.addGraphicObject( 3, myMarker( data.pZFT(1,:), zeros(1,length(data.currentTime) ), data.pZFT(2,:),'markerSize', 60, 'markerColor', c.blue, 'markerAlpha', 1 ) );
% tmp = plot3( ani.hAxes{ 3 }, data.pZFT(1,:),  zeros(1,length(data.currentTime)), data.pZFT( 2, : ), 'color', c.blue,  'linestyle', '--', 'linewidth', 3 );
% tmp.Color(4) =  0.3;
% scatter3( ani.hAxes{ 3 }, data.pZFT(1,1), 0, data.pZFT( 2, 1 )    , 150, 'markeredgecolor', c.blue,  'markerfacecolor', c.white, 'linewidth', 2  );
% scatter3( ani.hAxes{ 3 }, data.pZFT(1,end), 0, data.pZFT( 2, end ), 150, 'markeredgecolor', c.blue,  'markerfacecolor', c.white, 'linewidth', 2  );

% set( ani.hAxes{ 3 }, 'view',   [0   0]     )  

% tmpLim = 3;
% set( ani.hAxes{ 3 }, 'XLim',   [ -tmpLim , tmpLim ] , ...                  
%                      'YLim',   [ -tmpLim , tmpLim ] , ...    
%                      'ZLim',   [ -tmpLim , tmpLim ] , ...
%                      'view',   [       0 ,      0 ] )
% set( ani.hAxes{ 3 }, 'xtick', [], 'ytick', [], 'ztick', []  )



% set( ani.hAxes{ 3 }, 'view',   [41.8506   15.1025 ]     )  
% set( ani.hAxes{ 2 } ) %'ylim', [-7,  6] )  
% T = 0.895680;
% h = fill( [0.1, 0.1+T, 0.1+T, 0.1],[-10,-10,10,10], c.grey);

% h = fill( [0.1, 0.1 + T, 0.1 + T , 0.1],[-4,-4,8,8], c.grey, 'parent', ani.hAxes{2});
% h.FaceAlpha=0.4; h.EdgeAlpha=0;

% ani.addZoomWindow( 3, "EE", 0.7 )
% set( ani.hAxes{ 3 }, 'view', get( ani.hAxes{ 1 }, 'view' ) );
% set( ani.hAxes{ 3 }, 'xtick', [], 'ytick', [], 'ztick', [] )


ani.run( 0.5, true, 'output' ) 


%% (--) ========================================================
%% (3-) Quantification of the Movement
%% --- (3 - a) Read the data_log.txt

% For the animation, you need to have the 'data_log.txt' file.
d1 = myTxtParse( 'optimization_log_T1.txt' );
d2 = myTxtParse( 'optimization_log_T2.txt' );
d3 = myTxtParse( 'optimization_log_T3.txt' );

hold on
p1 = plot(  d1.Iter, d1.output );
p2 = plot(  d2.Iter, d2.output );
p3 = plot(  d3.Iter, d3.output );
legend( 'Target1', 'Target2', 'Target3' )
xlabel( 'Iterations [-]'); ylabel( '$L^{*}$ [m]' );


%% 

MSE1 = sqrt( sum( ( d1.jointAngleActual( 1:4, idx1 ) - d1.pZFT( :, idx1 ) ).^2, 2 ) / sum( idx1 ) );
MSE2 = sqrt( sum( ( d2.jointAngleActual( 1:4, idx2 ) - d2.pZFT( :, idx2 ) ).^2, 2 ) / sum( idx2 ) );
MSE3 = sqrt( sum( ( d3.jointAngleActual( 1:4, idx3 ) - d3.pZFT( :, idx3 ) ).^2, 2 ) / sum( idx3 ) );