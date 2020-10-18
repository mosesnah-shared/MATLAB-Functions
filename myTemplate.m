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

% For the animation, you need to have the 'data_log.txt' file.
data = myTxtParse( 'data_log.txt' );

idx = 1;                                                                   % Choosing Target 1 to 3.

if     idx == 1
    c_m = c.pink;
elseif idx == 2
    c_m = c.blue;
elseif idx == 3    
    c_m = c.green;
end
    

%% --- (2 - b) Running the 3D Animation - Basic Movement

dt    = data.currentTime( 2 ) - data.currentTime( 1 );                     % Time Step of the simulation
nodeN = size( data.geomXYZPositions, 1) / 3 ;                              % Number of markers of the simulation, dividing by 3 (x-y-z) gives us the number of geometry.

mov_pars = [-2.06822,-0.27925,-0.27925, 2.40855, 0.01571, 0.     ,-0.83776, 1.5708 , 2.09963, 0.     , 0.80673, 0.03491, 1.21667, 0.63333, 0.6];
pi = mov_pars( 1:4  );
pm = mov_pars( 5:8  );
pf = mov_pars( 9:12 );

D1   = mov_pars( end - 2 );
D2   = mov_pars( end - 1 );
toff = mov_pars( end     );





T = max( D1, D2 + toff );

tVec  = ( 0:0.01:T );


genNodes = @(x) ( "node" + (1:x) );
stringList = [ "Target", "SH", "EL", "EE",  genNodes( nodeN - 4 ) ];       % 3 Upper limb markers + 1 target

% Marker in order, target (1), upper limb (3, SH, EL, WR) and Whip (25) 
sizeList   = [ 24, 24, 24, 24, 12 * ones( 1, 25 ) ];                        % Setting the size of each markers
colorList  = [ c_m; repmat( c_m, 3, 1); repmat( c.grey, 25 , 1 ) ];  % Setting the color of each markers

for i = 1: nodeN    % Iterating along each markers
    markers( i ) = myMarker( data.geomXYZPositions( 3 * i - 2, : ), ... 
                             data.geomXYZPositions( 3 * i - 1, : ), ... 
                             data.geomXYZPositions( 3 * i    , : ), ...
                                          'name', stringList( i ) , ...
                                    'markersize',   sizeList( i ) , ...
                                   'markercolor',  colorList( i, : ) );    % Defining the markers for the plot
end


ani = my3DAnimation( dt, markers );                                        % Input (1) Time step of sim. (2) Marker Information
ani.connectMarkers( 1, [ "SH", "EL", "EE" ], 'linecolor', c.grey )        
                                                                           % Connecting the markers with a line.

tmpLim = 2.5;
set( ani.hAxes{ 1 }, 'XLim',   [ -tmpLim , tmpLim ] , ...                  
                     'YLim',   [ -tmpLim , tmpLim ] , ...    
                     'ZLim',   [ -tmpLim , tmpLim ] , ...
                     'view',   [10   12.8650 ]     )                  % Set the view, xlim, ylim and zlim of the animation
                                                                           % ani.hAxes{ 1 } is the axes handle for the main animation
                                                                                                                     
isZFT = true;

if isZFT    % If ZFT Representation is ON
                                                                           % First, we need to calculate the forward kinematics of the 4-DOF upper limb model.
   ZFT_UL = my4DOF_Robot( [ 0.294, 0.291] );                               % The length of the upperarm and forearm, respectively.  
   [ pSH, pEL, pEE ] = ZFT_UL.forwardKinematics( data.pZFT );
   
   ani.addGraphicObject( 1, myMarker( pEL( 1, : ), pEL( 2, : ), pEL( 3, : ), 'markerSize', 13, 'name', "EL_ZFT", 'markerColor', c_m, 'markerAlpha', 0.5 ) );
   ani.addGraphicObject( 1, myMarker( pEE( 1, : ), pEE( 2, : ), pEE( 3, : ), 'markerSize', 13, 'name', "EE_ZFT", 'markerColor', c_m, 'markerAlpha', 0.5 ) );
   ani.connectMarkers( 1, [ "SH", "EL_ZFT" "EE_ZFT" ], 'linecolor', c.grey, 'lineWidth', 3, 'lineStyle', '--' );
   
end

% TARGET (1:3) SH (4:6) EL (7:9) EE(10:12)
v_EE = data.geomXYZVelocity( 10:12,  : );
v_EE_m = sqrt( sum( v_EE.^2 ) );

tmp1 = my2DLine( data.currentTime, v_EE_m, 'linecolor', c.pink,   'linestyle', '--', 'linewidth', 3 );

% tmp1 = my2DLine( data.currentTime, data.vZFT( 1, : ), 'linecolor', c.pink,   'linestyle', '--', 'linewidth', 3 );
% tmp2 = my2DLine( data.currentTime, data.vZFT( 2, : ), 'linecolor', c.green,  'linestyle', '--', 'linewidth', 3 );
% tmp3 = my2DLine( data.currentTime, data.vZFT( 3, : ), 'linecolor', c.blue,   'linestyle', '--', 'linewidth', 3 );
% tmp4 = my2DLine( data.currentTime, data.vZFT( 4, : ), 'linecolor', c.yellow, 'linestyle', '--', 'linewidth', 3 );

% tmp11 = my2DLine( data.currentTime, data.jointVelActual( 1, : ), 'linecolor', c.pink,   'linestyle', '-', 'linewidth', 6 );
% tmp22 = my2DLine( data.currentTime, data.jointVelActual( 2, : ), 'linecolor', c.green,  'linestyle', '-', 'linewidth', 6 );
% tmp33 = my2DLine( data.currentTime, data.jointVelActual( 3, : ), 'linecolor', c.blue,   'linestyle', '-', 'linewidth', 6 );
% tmp44 = my2DLine( data.currentTime, data.jointVelActual( 4, : ), 'linecolor', c.yellow, 'linestyle', '-', 'linewidth', 6 );

ani.addTrackingPlots( 2, tmp11 );           
% ani.addTrackingPlots( 2, tmp22 );           
% ani.addTrackingPlots( 2, tmp33 );           
% ani.addTrackingPlots( 2, tmp44 );      

plot( ani.hAxes{ 2 }, data.currentTime, data.vZFT( 1, : ), 'color', c.pink,   'linestyle', '--', 'linewidth', 3 );
plot( ani.hAxes{ 2 }, data.currentTime, data.vZFT( 2, : ), 'color', c.green,  'linestyle', '--', 'linewidth', 3 );
plot( ani.hAxes{ 2 }, data.currentTime, data.vZFT( 3, : ), 'color', c.blue,   'linestyle', '--', 'linewidth', 3 );
plot( ani.hAxes{ 2 }, data.currentTime, data.vZFT( 4, : ), 'color', c.yellow, 'linestyle', '--', 'linewidth', 3 );


%%

plot( data.currentTime, data.vZFT( 1, : ), 'color', c.pink,   'linestyle', '--', 'linewidth', 5 );
hold on
plot( data.currentTime, data.vZFT( 2, : ), 'color', c.green,  'linestyle', '--', 'linewidth', 5 );
plot( data.currentTime, data.vZFT( 3, : ), 'color', c.blue,   'linestyle', '--', 'linewidth', 5 );
plot( data.currentTime, data.vZFT( 4, : ), 'color', c.yellow, 'linestyle', '--', 'linewidth', 5 );

 %%
ani.addZoomWindow( 3, "EE", 0.7 )
set( ani.hAxes{ 3 }, 'view',   [10   12.8650 ]     )  
  
h = fill( [0.1, 0.1 + T, 0.1 + T , 0.1],[-4,-4,8,8], c.grey, 'parent', ani.hAxes{2});
h.FaceAlpha=0.4; h.EdgeAlpha=0;

% 
willSave = true;           % Set this as 'true' if you want to save the video
ani.run( 0.2, willSave, 'output' ) 


%% --- (2 - C) Running the 3D Animation - Special Plot, showing the ZT postures 

%% (--) ========================================================
%% (3-) Quantification of the Movement
%% --- (3 - a) Parsing the txt File 
t_start = 0.3;
t_end   = 0.3 + 0.5833;
idx_list = find( (data.currentTime >= t_start) & (data.currentTime <= t_end) );

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
plot( data.currentTime( idx_list ), data.jointAngleActual( idx_J, idx_list ),  '-', 'linewidth', 5, 'color', tmpc )
hold on
plot( data.currentTime( idx_list ), data.pZFT( idx_J, idx_list ), '--', 'linewidth', 5, 'color', tmpc )
set( gca, 'xlim', [t_start, t_end], 'ylim', [-2, 2.5]);

tmp = 1/length( idx_list ) * sqrt( sum( ( data.pZFT( idx_J, idx_list ) - data.jointAngleActual( idx_J, idx_list ) ).^2 ) );
tmp
% plot( data.currentTime, data.jointAngleActual( 2, idx_list ), data.currentTime, data.pZFT( 2, idx_list ) )
% plot( data.currentTime, data.jointAngleActual( 3, idx_list ), data.currentTime, data.pZFT( 3, idx_list ) )
% plot( data.currentTime, data.jointAngleActual( 4, idx_list ), data.currentTime, data.pZFT( 4, idx_list ) )
mySaveFig( gcf, ['J', num2str( idx_J )] );
end

%% --- (3 - b) Read the data_log.txt

% For the animation, you need to have the 'data_log.txt' file.
data1 = myTxtParse( 'linear_data_log.txt' );
data2 = myTxtParse( 'nontapered_data_log.txt' );
data = {data1, data2};

%% --- (3 - c) Velocity Calculation

% Calculate the velocity 

num = 30;
mat = bone( num );

idx = 1;

if idx == 1
    startTime = 0.3; endTime = 0.3 + 0.58333;
elseif idx == 2
    startTime = 0.3; endTime = 0.3 + 0.40679; 
end

tmpN = size( data{idx}.geomXYZVelocities, 1 ); N = tmpN/3; clear tmp*

for i = 1 : N
   
    tmp = data{ idx }.geomXYZVelocities( 3 * i - 2 : 3 * i, : );
    
    vel( i, : ) = vecnorm( tmp );
    
end

hold on
% for i = 1 : 25
%     plot( data{ idx }.currentTime, vel( i + 3,: ), 'color', mat( i,: ) )
% end
% h = fill( [startTime, endTime, endTime , startTime],[0,0,450,450], 'blue');
% h.FaceAlpha=0.1; h.EdgeAlpha=0;


for i = 1 : 25
    plot3( i * ones(1, size(tmp,2 ) ),  data{ idx }.currentTime, vel( i + 3,: ), 'color', mat( i,: ) )
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

%% --- (3 - d) Calculating curvature (kappa) of the movement. 
qacc  = data.jointAccActual(1:4,:);
qvel  = data.jointVelActual(1:4,:);

ttmp = qacc - qvel ./ sum( qvel.^2 ).* sum( qvel.*qacc );
kappa = ( 1./sum( qvel.^2 ) ) .* sqrt( sum( ttmp.^2 ) ) ;

