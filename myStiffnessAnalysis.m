% [Project]        [M3X] Whip Project
% [Title]          Forward Kinematics of the upper limb
% [Author]         Moses C. Nah
% [Creation Date]  Saturday, August 1th, 2020

% [Emails]         Moses C. Nah   : mosesnah@mit.edu

%% (--) INITIALIZATION

clear all; close all; clc;
workspace;
cd( fileparts( matlab.desktop.editor.getActiveFilename ) );                % Setting the current directory as the folder where this "main.m" script is located

tmpDir = "/Users/mosesnah/MATLAB-Drive" ;
addpath( tmpDir );    
tmpList = dir( fullfile( tmpDir , '*.m' ) );
    
for tmp = { tmpList.name }
    fprintf('IMPORTED FUNCTION [ %-25s ] \n', tmp{ 1 } );
end
    
myFigureConfig(  'fontsize',  20, ...
                'lineWidth',   5, ...
               'markerSize',  25 );         
              
c  = myColor();                

clear tmp*

%% (1B) Symbolic definition of the upper limb parameters.

% Calculating the essential matrix/vectors for the upper limb model in "symbolic equations"
% the symbol will be the each angle of the rotational joint, function of t

% For detailed image and joint number of the upper limb model, please see the following presentation
% /Users/mosesnah/Dropbox (MIT)/MIT/Research/Research Presentation/[Presentation#4]/3DMovements.pptx
% the number of predix 'd' describes the "number of derivative"
syms t positive                                  % time               variable - independent variable.
syms   q1(t)   q2(t)   q3(t)   q4(t)             % joint angle        variable -   dependent variable.
syms  dq1(t)  dq2(t)  dq3(t)  dq4(t)             % joint velocity     variable -   dependent variable.
syms ddq1(t) ddq2(t) ddq3(t) ddq4(t)             % joint acceelration variable -   dependent variable.

q  = [q1(t), q2(t), q3(t), q4(t)];               % Joint Position vector 
dq = [dq1(t), dq2(t), dq3(t), dq4(t)];           % Joint Velocity vector

                                                 % Number of each symbol is ordered in ascending
                                                 % order, from proximal to distal.
syms L1 L2 


%% (1C) Defining the SE(3) matrix for the End-Effector (EE) forward kinematics + Jacobian.
                                                  
                                                 % For detailed frame numbering, please refer following powerpoint file
                                                 % /Users/mosesnah/Dropbox (MIT)/MIT/Research/Research Presentation/[Presentation#4]/3DMovements.pptx
                                                 % Frame 1,2,3 coincides with shoulder GEOM
                                                 % Frame 4     coincides with    elbow GEOM
R01 = roty( -q1(t) ); R12 = rotx( -q2(t) );      % Rotational matrix for each frame transformation
R23 = rotz(  q3(t) ); R34 = roty( -q4(t) );      % Rotational matrix for each frame transformation 

p01=[0;0;0]; p12=[0;0;0];                        % Position vector for each frame.
p23=[0;0;0]; p34=[0;0;-L1];                      % Position vector for each frame.

                                                 % se(3) matrix definition
T01 = [R01, p01; 0,0,0,1]; 
T12 = [R12, p12; 0,0,0,1];
T23 = [R23, p23; 0,0,0,1]; 
T34 = [R34, p34; 0,0,0,1];

T04 = T01 * T12 * T23 * T34;                     % the whole transformation
                                                 % T04 transforms from frame 0 to 4

pEL = T04 * [0;0;0; 1];                          % Elbow Position                           
pEE = T04 * [0;0;-L2; 1];                        % End-point (effector) position vector, multiplying the position of EE w.r.t Frame 4
x  = [ pEE(1), pEE(2), pEE(3) ];                 % End-point (effector) position vector   
dx = diff( x, t );                               % Time differentiation of dx
dx = subs( dx, diff( q,t ), dq );                % Substituting all diff( q,t ) to dq's

JEE  = myJacobian(dx, dq);                       % Getting the jacobian of the end-effector

% [BACKUP] Quick Check of whether the Jacobian is correct.
% txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/20200801_230441/data_log.txt';
% rawData = myTxtParse( txtFile );
% 
% N = length( rawData.currentTime );
% 
% for i = 1 : N
%     tmp = vpa( subs( JEE, {L1, L2, q1, q2, q3, q4}, {0.294, 0.291, rawData.jointAngleActual( 1,i ), ...
%                                                                    rawData.jointAngleActual( 2,i ), ...
%                                                                    rawData.jointAngleActual( 3,i ), ...
%                                                                    rawData.jointAngleActual( 4,i ) }) );
%     tmp  = double( reshape( tmp',1,[]  ) );
%     tmparr1( i, : ) = tmp;
%     tmparr2( i, : ) = rawData.jacobian( :, i )';
%     
% 
% end
% 
% abs( tmparr1-tmparr2 ) < 1e-3


%% (1D) Joint + End-point Stiffness Calculation

K = [ 17.4,  4.0, -1.90, 8.40; ...
      9.00, 33.0,  4.40, 0.00; ...
     -13.6,  3.0, 27.70, 0.00; ...
      8.40,  0.0,  0.00, 23.2];
  
Kq = ( K + K' )/2;      % Extracting out the symmetric part
Cq = inv( Kq );         % Joint Angle Compliance exist
 
Cx = JEE * Cq * JEE';   % End-point Compliance
% Kx = inv( Cx );       % If we do this, it takes so much time to do the calculation.

% [txt File List]
% txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/3D_Movement_Analysis/Spatial_Sym_K/Target1/data_log.txt';
% txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/3D_Movement_Analysis/Spatial_Sym_K/Target2/data_log.txt';
txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/3D_Movement_Analysis/Spatial_Sym_K/Target3/data_log.txt';


rawData = myTxtParse( txtFile );

N = length( rawData.currentTime );
for i = 1 : N
    
    tmp =  double( vpa( subs( Cx, {L1, L2, q1, q2, q3, q4}, {0.294, 0.291, rawData.jointAngleActual( 1,i ), ...
                                                                           rawData.jointAngleActual( 2,i ), ...
                                                                           rawData.jointAngleActual( 3,i ), ...
                                                                           rawData.jointAngleActual( 4,i ) }) ) );
                                                                       
    rawData.Cx(:,:,i) = tmp; 
    rawData.Kx(:,:,i) = inv( tmp );
    fprintf( '[%d/%d]\n', i, N ); 
    
end

%% (1E) Graphical Plot of the Stiffness Ellipse.

qList = [0, 0, 0, 0];     % Setting the Initial Position

pEL_val = double( vpa( subs( pEL, {L1, L2, q1, q2, q3, q4}, {0.294, 0.291, qList(1), qList(2), qList(3), qList(4) } ) ) );            
pEE_val = double( vpa( subs( pEE, {L1, L2, q1, q2, q3, q4}, {0.294, 0.291, qList(1), qList(2), qList(3), qList(4) } ) ) );            

Cx_val  = double( vpa( subs( Cx, {L1, L2, q1, q2, q3, q4}, {0.294, 0.291, qList(1), qList(2), qList(3), qList(4) } ) ) );
Kx_val  = inv( Cx_val );

myData{ 1 } = [0; 0; 0];
myData{ 2 } = pEL_val;
myData{ 3 } = pEE_val;

my3DStaticPlot( myData )


%% (1E-A) Default Plot

for i = 1 : N
    Kx = rawData.Kx(:,:,i);   % The Kx to Analyze
    C  = rawData.geomXYZPositions( 10:12, i);
    [X,Y,Z] = Ellipse_plot( Kx, C );
    
    X_Whole{i} = X;
    Y_Whole{i} = Y;
    Z_Whole{i} = Z;
    
end

tVec = rawData.currentTime;       

nodeN = 29;

tmp = 8;
myMarkerSize  = tmp * ones( 1, nodeN );                                   
myMarkerColor = repmat( c.grey, nodeN, 1 );

myMarkerSize( 2 : 4 ) = 16;
myMarkerColor( 2 : 4, : ) = repmat( c.pink, 3, 1);

% For target
myMarkerSize( 1 ) = 10;
myMarkerColor( 1, : ) = c.green;

clear tmp*

for i = 1 : nodeN
   myData{ i } = rawData.geomXYZPositions( 3 * i - 2 : 3 * i, : ); 
end

% Calling the animation object for plotting
ani = my3DAnimation( tVec, myData, 'markersize',  myMarkerSize, ...
                                   'markercolor', myMarkerColor);
axis( ani.hAxes_main, 'equal' )

tmpLim = 2.4;
set( ani.hAxes_main ,  'XLim',   [ -tmpLim , tmpLim ] , ...        % Setting the axis ratio of x-y-z all equal.
                       'YLim',   [ -tmpLim , tmpLim ] , ...    
                       'ZLim',   [ -tmpLim , tmpLim ] , ...
                       'view',   [44.9986   12.8650]     )                 % view(0,0) is XZ Plane

ani.addEllipse( X_Whole, Y_Whole, Z_Whole ) 
ani.addZoomWindow( 1 )
ani.run( 0.3, false, 'output')


%%
Kx = rawData.Kx(:,:,1);   % The Kx to Analyze
[XX,YY,ZZ] = Ellipse_plot( Kx, [0,0,0] );
h = figure(); a = axes( 'parent', h );

h1 = mesh(XX,YY,ZZ, 'parent', a); axis equal
hold on
% h2 = plot3(XX,YY,ZZ, 'parent', a); 
set(a, 'XLim', [-tmpLim,tmpLim], 'YLim', [-tmpLim,tmpLim], 'ZLim', [-tmpLim,tmpLim] )

tmpLim = 0.15;

for i = 1 :N 
    Kx = rawData.Kx(:,:,i); 
    [XX,YY,ZZ] = Ellipse_plot( Kx, [0,0,0] );
    set( h1, 'XData', XX, 'YData', YY, 'ZData', ZZ );
    drawnow 
    pause(0.1);
end


