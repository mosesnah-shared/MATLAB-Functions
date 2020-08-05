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

%% (1B) Symbolic Definition for the SE(3) matrix for the End-Effector (EE) forward kinematics + Jacobian.

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
L1 = 0.294; L2 = 0.291;
                                     
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
vEE = JEE * dq';        % End-point Velocity
% Kx = inv( Cx );       % If we do this, it takes so much time to do the calculation.

% [txt File List]

idx = 1;

if     idx == 1
    txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/3D_Movement_Analysis/Spatial_Sym_K/Target1/data_log.txt';
    t_start = 0.3;
    t_end   = t_start + 0.95;    
elseif idx == 2
    txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/3D_Movement_Analysis/Spatial_Sym_K/Target2/data_log.txt';
    t_start = 0.3;
    t_end   = t_start + 0.5788;    
elseif idx == 3
    txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/3D_Movement_Analysis/Spatial_Sym_K/Target3/data_log.txt';
    t_start = 0.3;
    t_end   = t_start + 0.95;
end

rawData = myTxtParse( txtFile );
N = length( rawData.currentTime );

for i = 1 : N
                                                                       
                                                          
    rawData.Cx(:,:,i) = double( vpa( subs( Cx, q, rawData.jointAngleActual( 1:4,i )' ) ) );
    rawData.vEE(:,i ) = double( vpa( subs( vEE, [q, dq], [rawData.jointAngleActual( 1:4,i )', rawData.jointVelActual( 1:4,i )' ] ) ) );
    rawData.Kx(:,:,i) = inv( rawData.Cx(:,:,i) );   % Inverting the Compliant Matrix gives us the stiffness matrix                         
    
    [V, D, ~ ] = svd( rawData.Kx(:,:,i) );
    % svd is in descending order.
    
    rawData.maxVec( :,i ) = V( :,1 );                                      
    rawData.medVec( :,i ) = V( :,2 );   
    rawData.minVec( :,i ) = V( :,3 );
    
    % Calculating the norm, which shows how much the vectors are aligned.
    tmp = norm( rawData.vEE( :,i ) );
    
    if ( tmp ~= 0)
        
        tmp1 = ( rawData.minVec(:,i)' * rawData.vEE(:,i) ) / ( tmp );
        tmp2 = ( rawData.medVec(:,i)' * rawData.vEE(:,i) ) / ( tmp );
        tmp3 = ( rawData.maxVec(:,i)' * rawData.vEE(:,i) ) / ( tmp );        
                 
        rawData.dotProd1( i ) = tmp1;
        rawData.dotProd2( i ) = tmp2;
        rawData.dotProd3( i ) = tmp3;
    else
        rawData.dotProd1( i ) = 0;
        rawData.dotProd2( i ) = 0;
        rawData.dotProd3( i ) = 0;        
        
    end
    
    fprintf( '[%d/%d]\n', i, N ); 
    
end

idx_list = (rawData.currentTime >= t_start) & (rawData.currentTime <= t_end);
%%
% Find Discontinuity and make it continuous 

tmp = abs( diff( rawData.dotProd1 ) ) > 0.6;
tmp_idx(1) = 1;

ttmp = 1;
for i = 1:length( tmp )
    if( tmp( i ) == 1 ) 
        ttmp = -ttmp;
    end
    tmp_idx( i + 1 ) = ttmp;

end

rawData.dotProd1 = rawData.dotProd1.*tmp_idx;
rawData.minVec   = rawData.minVec.*tmp_idx;
% if     idx == 1
%     rawData.dotProd1( 19:46 ) = -rawData.dotProd1( 19:46 );
%     rawData.dotProd2( 45:46 ) = -rawData.dotProd2( 45:46 );    
%     rawData.dotProd3( 45:75 ) = -rawData.dotProd3( 45:75 );        
% elseif idx == 2
%     rawData.dotProd1( 20:37 ) = -rawData.dotProd1( 20:37 );
%     rawData.dotProd2( 38:53 ) = -rawData.dotProd2( 38:53 );    
%     rawData.dotProd3( 30:53 ) = -rawData.dotProd3( 30:53 );
% elseif idx == 3
%     rawData.dotProd1( 19:46 ) = -rawData.dotProd1( 19:46 );    
%     rawData.dotProd1( 48:51 ) = -rawData.dotProd1( 48:51 );    
%     rawData.dotProd1( 62:64 ) = -rawData.dotProd1( 62:64 );    
%     rawData.dotProd1( 69:75 ) = -rawData.dotProd1( 69:75 ); 
%     
%     tmp = rawData.dotProd2 < 0;
%     rawData.dotProd2( tmp ) = -rawData.dotProd2( tmp );
%     
%     tmp = rawData.dotProd3 < 0;
%     rawData.dotProd3( tmp ) = -rawData.dotProd3( tmp );    
% end
%     
plot( rawData.dotProd1( idx_list ) )
%% (1E) time vs Plot

for i = 1 : N
    
    Kx = rawData.Kx(:,:,i);   % The Kx to Analyze
    C  = rawData.geomXYZPositions( 10:12, i);   % The end-effector Position
    [X,Y,Z] = Ellipse_plot( Kx, C );
    X_Whole{i} = X; Y_Whole{i} = Y; Z_Whole{i} = Z;
    
    [XX,YY,ZZ] = Ellipse_plot( Kx, [0,0,0] );
    XX_Whole{i} = XX; YY_Whole{i} = YY; ZZ_Whole{i} = ZZ;    
    
end

tVec  = rawData.currentTime;       
nodeN = size(rawData.geomXYZPositions, 1) / 3 ;

genNodes = @(x) ( "node" + (1:x) );

stringList = [ "Target", "Shoulder", "Elbow", "EndEffector", genNodes( nodeN - 4 ) ];
sizeList   = [ 10, 16, 16, 16, 8 * ones( 1, nodeN - 4 ) ];
colorList  = [ c.green; repmat( c.pink, 3, 1); repmat( c.grey, nodeN - 4, 1 ) ];

% markers = [];

for i = 1: nodeN
    markers( i ) = myMarker( rawData.geomXYZPositions( 3 * i - 2, : ), ... 
                             rawData.geomXYZPositions( 3 * i - 1, : ), ... 
                             rawData.geomXYZPositions( 3 * i    , : ), ...
                                             'name', stringList( i ) , ...
                                       'markersize',   sizeList( i ) , ...
                                      'markercolor',  colorList( i, : ) );
end
tmp = markers(1);
markers(1) = [] ;

% Calling the animation object for plotting
ani = my3DAnimation( tVec(2), markers );
ani.connectMarkers( ["Shoulder",  "Elbow", "EndEffector"] )
ani.addMarkers( tmp )

tmp1 = myEllipse( rawData.Kx, zeros( 3, size( rawData.Kx, 3 ) ) ) ;
tmp2 = myArrow( tmp1.minAxes(1,:), tmp1.minAxes(2,:), tmp1.minAxes(3,:), zeros(3, size( rawData.Kx, 3 ) ), 'arrowColor', c.green ) ;
tmp3 = myArrow( tmp1.medAxes(1,:), tmp1.medAxes(2,:), tmp1.medAxes(3,:), zeros(3, size( rawData.Kx, 3 ) ), 'arrowColor', c.blue ) ;
tmp4 = myArrow( tmp1.maxAxes(1,:), tmp1.maxAxes(2,:), tmp1.maxAxes(3,:), zeros(3, size( rawData.Kx, 3 ) ), 'arrowColor', c.pink ) ;

ani.addGraphicObject( 1, tmp1 );
ani.addGraphicObject( 1, tmp2 );
ani.addGraphicObject( 1, tmp3 );
ani.addGraphicObject( 1, tmp4 );

tmpLim = 2.4;
set( ani.hAxesMain,  'XLim',   [ -tmpLim , tmpLim ] , ...                  % Setting the axis ratio of x-y-z all equal.
                     'YLim',   [ -tmpLim , tmpLim ] , ...    
                     'ZLim',   [ -tmpLim , tmpLim ] , ...
                     'view',   [44.9986   12.8650 ]     )                  % view(0,0) is XZ Plane
                 
tmpLim = 0.3;                 
set( ani.hAxesSide1, 'XLim',   [ -tmpLim , tmpLim ] , ...                  % Setting the axis ratio of x-y-z all equal.
                     'YLim',   [ -tmpLim , tmpLim ] , ...    
                     'ZLim',   [ -tmpLim , tmpLim ] , ...
                     'view',   [44.9986   12.8650 ]     )                  % view(0,0) is XZ Plane                 

%%             
             
ani.addEllipse( X_Whole, Y_Whole, Z_Whole ) 
ani.addZoomWindow( 4, 0.8 )
ani.addEllipsePlot( rawData.Kx ) 
ani.addArrow2Ellipse( rawData.vEE ) 

set( ani.hA_s2E , 'view',   [44.9986   12.8650 ]     )

% ani.addVectorPlot(  rawData.vEE(1,:),rawData.vEE(2,:),rawData.vEE(3,:) )
% ani.addVectorPlot(  -rawData.minVec(1,:), -rawData.minVec(2,:), -rawData.minVec(3,:) )

% ani.addVectorPlot( 0.1,0.2,0.3 )

ani.run( 0.2, true, 'output')


%%
% Kx = rawData.Kx(:,:,1);   % The Kx to Analyze
% [XX,YY,ZZ] = Ellipse_plot( Kx, [0,0,0] );
% h = figure(); a = axes( 'parent', h );
% 
% 
% hold on
% % h2 = plot3(XX,YY,ZZ, 'parent', a); 
% set(a, 'XLim', [-tmpLim,tmpLim], 'YLim', [-tmpLim,tmpLim], 'ZLim', [-tmpLim,tmpLim] )
% 
% tmpLim = 0.15;
% 
% for i = 1 :N 
%     Kx = rawData.Kx(:,:,i); 
%     [XX,YY,ZZ] = Ellipse_plot( Kx, [0,0,0] );
%     set( h1, 'XData', XX, 'YData', YY, 'ZData', ZZ );
%     drawnow 
%     pause(0.1);
% end

%% (1F) Ellipse Plot 3D

idx = 1;
                                                
[XX, YY, ZZ] = Ellipse_plot( 0.3 * rawData.Kx(:,:,idx), [0,0,0] );

[ V, D ] = eig( rawData.Kx( :, :, idx ) );

hF = figure(); hA = axes( 'parent', hF );
hP = mesh(XX,YY,ZZ, 'parent', hA); axis equal; hold( hA,'on' );

scale = 0.3;
V = scale * V; 

quiver3( 0,0,0, V(1,1), V(2,1), V(3,1), 'parent' ,hA, 'linewidth', 4, 'color', c.blue  , 'MaxheadSize', 0.4 ) 
quiver3( 0,0,0, V(1,2), V(2,2), V(3,2), 'parent' ,hA, 'linewidth', 4, 'color', c.orange, 'MaxheadSize', 0.4 )
quiver3( 0,0,0, V(1,3), V(2,3), V(3,3), 'parent' ,hA, 'linewidth', 4, 'color', c.yellow, 'MaxheadSize', 0.4 )

%% (1G) Ellipse Plot 3D

example = [ 25, 10; 10, 35];

scale = 0.03 * (1:15);

hF = figure(); hA = axes( 'parent', hF ); axis equal; hold( hA,'on' );

for s = scale
    [XX,YY,ZZ] = Ellipse_plot( s * example, [0,0] );
    plot( XX, YY );
end


quiver( 0,0, V(1,1), V(2,1), 'parent', hA, 'linewidth', 4, 'color', c.orange, 'MaxheadSize', 0.4 ) 
quiver( 0,0, V(1,2), V(2,2), 'parent', hA, 'linewidth', 4, 'color', c.yellow, 'MaxheadSize', 0.4 ) 
set( hA, 'xlim', [-1.5, 1.5], 'ylim', [-1.5,1.5])
