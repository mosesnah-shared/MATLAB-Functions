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

%% (1A) Symbolic Definition for the SE(3) matrix for the End-Effector (EE) forward kinematics + Jacobian.

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


%% (1B) Joint + End-point Stiffness Calculation

K = [ 17.4,  4.0, -1.90, 8.40; ...
      9.00, 33.0,  4.40, 0.00; ...
     -13.6,  3.0, 27.70, 0.00; ...
      8.40,  0.0,  0.00, 23.2];
  
Kq = ( K + K' )/2;      % Extracting out the symmetric part
Cq = inv( Kq );         % Joint Angle Compliance exist
 
Cx  = JEE * Cq * JEE';  % End-point Compliance
vEE = JEE * dq';        % End-point Velocity
% Kx = inv( Cx );       % If we do this, it takes so much time to do the calculation.

% [txt File List]

for idx = 1:3

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
    elseif idx == 4
        txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/3D_Movement_Analysis/Spatial_Sym_K/Target1/data_log_bad.txt';
        t_start = 0.3;
        t_end   = t_start + 1.07222;    
    elseif idx == 5
        txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/3D_Movement_Analysis/Spatial_Sym_K/Target2/data_log_bad.txt';
        t_start = 0.3;
        t_end   = t_start + 0.58333; 
    elseif idx == 6
        txtFile = '/Users/mosesnah/Documents/projects/WhipProjectTapering/results/3D_Movement_Analysis/Spatial_Sym_K/Target3/data_log_bad.txt';
        t_start = 0.3;
        t_end   = t_start + 0.95;


    end



    rawData = myTxtParse( txtFile );
    N = length( rawData.currentTime );

    for i = 1 : N


        rawData.Cx(:,:,i) = double( vpa( subs( Cx, q, rawData.jointAngleActual( 1:4,i )' ) ) );
        rawData.vEE(:,i ) = double( vpa( subs( vEE, [q, dq], [rawData.jointAngleActual( 1:4,i )', rawData.jointVelActual( 1:4,i )' ] ) ) );
        rawData.Kx(:,:,i) = inv( rawData.Cx(:,:,i) );   % Inverting the Compliant Matrix gives us the stiffness matrix                         

        [V, D, ~ ] = svd( rawData.Kx(:,:,i) );                                 % svd is in descending order.

        rawData.maxK( i )     = D( 1, 1 );
        rawData.medK( i )     = D( 2, 2 );
        rawData.minK( i )     = D( 3, 3 );        
             
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
    rawData.t_start = t_start;
    rawData.t_end   = t_end;
    
    rawDataList{ idx } = rawData;
    
end

%% (1C) time vs. dot-product result

idx_list = find( (rawData.currentTime >= t_start) & (rawData.currentTime <= t_end) );
% %%
% % Find Discontinuity and make it continuous 
% 
% tmp = abs( diff( rawData.dotProd1 ) ) > 0.6;
% tmp_idx(1) = 1;
% 
% ttmp = 1;
% for i = 1:length( tmp )
%     if( tmp( i ) == 1 ) 
%         ttmp = -ttmp;
%     end
%     tmp_idx( i + 1 ) = ttmp;
% 
% end
% 
% rawData.dotProd1 = rawData.dotProd1.*tmp_idx;
% rawData.minVec   = rawData.minVec.*tmp_idx;
% % if     idx == 1
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

tmp = rawData.dotProd1( idx_list );

tmp( tmp < 0 ) = - tmp( tmp < 0 );

tVec = linspace( t_start, t_end, length( idx_list ) );
plot( tVec, tmp ); 

title( "[Target " + num2str( idx ) + "] Dot Product of Velocity Vector and Main Axis Vector" )
xlabel( 'Time [sec]', 'fontsize', 30); 
ylabel('Dot Product [-]' ,'fontsize', 30);
set( gca,'xlim', [t_start, t_end] );

tmpN = 4;
tmp2 = get(gca, 'XTick' );
set( gca, 'XTick', linspace( t_start, t_end, tmpN ) )
xtickformat('%.2f')

tmp1 = get(gca, 'XTickLabel' );


tmp1{1}   = [tmp1{1},' Start'];
tmp1{end} = [tmp1{end},' End'];
set(gca, 'XTickLabel', tmp1 );

get(gca, 'XTickLabel')

mySaveFig( gcf, "output" + num2str( idx ) )


%% (1E) time vs Plot


tStep = rawData.currentTime(2) - rawData.currentTime(1);                   % Time Step of the simulation
nodeN = size(rawData.geomXYZPositions, 1) / 3 ;                            % Number of markers of the simulation
N     = length( rawData.currentTime );


genNodes = @(x) ( "node" + (1:x) );

stringList = [ "Target", "Shoulder", "Elbow", "EndEffector",    genNodes( nodeN - 4 ) ];
sizeList   = [       10,         16,      16,            16, 8 * ones( 1, nodeN - 4 ) ];
colorList  = [  c.green;              repmat( c.pink, 3, 1); repmat( c.grey, nodeN - 4, 1 ) ];

for i = 1: nodeN
    markers( i ) = myMarker( rawData.geomXYZPositions( 3 * i - 2, : ), ... 
                             rawData.geomXYZPositions( 3 * i - 1, : ), ... 
                             rawData.geomXYZPositions( 3 * i    , : ), ...
                                             'name', stringList( i ) , ...
                                       'markersize',   sizeList( i ) , ...
                                      'markercolor',  colorList( i, : ) );
end

% Calling the animation object for plotting
ani = my3DAnimation( tStep, markers );

ani.connectMarkers( 1, ["Shoulder",  "Elbow", "EndEffector"], 'linecolor', c.grey )          
    
KxEllipse = myEllipse( 0.02 * rawData.Kx, zeros( 3, N ),  'faceAlpha', 0.2 );

KxMax_p = myArrow(  KxEllipse.minAxes(1,:),  KxEllipse.minAxes(2,:),  KxEllipse.minAxes(3,:), zeros(3, N ), 'arrowColor', c.green  ,'arrowWidth', 3 ) ;
KxMax_n = myArrow( -KxEllipse.minAxes(1,:), -KxEllipse.minAxes(2,:), -KxEllipse.minAxes(3,:), zeros(3, N ), 'arrowColor', c.green  ,'arrowWidth', 3 ) ;
KxMed_p = myArrow(  KxEllipse.medAxes(1,:),  KxEllipse.medAxes(2,:),  KxEllipse.medAxes(3,:), zeros(3, N ), 'arrowColor', c.blue   ,'arrowWidth', 3 ) ;
KxMed_n = myArrow( -KxEllipse.medAxes(1,:), -KxEllipse.medAxes(2,:), -KxEllipse.medAxes(3,:), zeros(3, N ), 'arrowColor', c.blue   ,'arrowWidth', 3 ) ;
KxMin_p = myArrow(  KxEllipse.maxAxes(1,:),  KxEllipse.maxAxes(2,:),  KxEllipse.maxAxes(3,:), zeros(3, N ), 'arrowColor', c.orange ,'arrowWidth', 3 ) ;
KxMin_n = myArrow( -KxEllipse.maxAxes(1,:), -KxEllipse.maxAxes(2,:), -KxEllipse.maxAxes(3,:), zeros(3, N ), 'arrowColor', c.orange ,'arrowWidth', 3 ) ;

ani.addGraphicObject( 2, KxEllipse )                                       % Add the end-point ellipse
ani.addGraphicObject( 2, [ KxMax_p, KxMax_n, ...
                           KxMed_p, KxMed_n, ...
                           KxMin_p, KxMin_n ] );                           % Add the axes vectors of the ellipse

ani.addZoomWindow( 3, "EndEffector", 0.5 )                                 % Copy the main plot to subplot2 (idx = 3), 
                                                                           % Focus on the EndEffector, window size +-0.5                     

                                                                           
EEVec1 = myArrow(  0.2 * rawData.vEE(1,:), 0.2 * rawData.vEE(2,:), 0.2 * rawData.vEE(3,:), ...
                [ markers(4).xdata; markers(4).ydata; markers(4).zdata ], ...   % The origin of the vector is the end-effector (idx = 4)
                 'arrowColor', c.pink,'arrowWidth', 6 ) ;

KxEllipse_EE = myEllipse( 0.3 * rawData.Kx, [ markers(4).xdata; markers(4).ydata; markers(4).zdata ], 'faceAlpha', 0.2 ) ;            
            
ani.addGraphicObject( 3, EEVec1       )
ani.addGraphicObject( 3, KxEllipse_EE )

EEVec2 = myArrow( 0.5 * rawData.vEE(1,:), ...
                  0.5 * rawData.vEE(2,:), ...
                  0.5 * rawData.vEE(3,:), ...
                  zeros(3, N ), 'arrowColor', c.pink,'arrowWidth', 6  ) ;
        
ani.addGraphicObject( 2, EEVec2 )             

tmpLim = 2.4;
set( ani.hAxes{1},   'XLim',   [ -tmpLim , tmpLim ] , ...                  
                     'YLim',   [ -tmpLim , tmpLim ] , ...    
                     'ZLim',   [ -tmpLim , tmpLim ] , ...
                     'view',   [44.9986   12.8650 ]     )                  
                 
set( ani.hAxes{2},   'XLim',   0.7 * [ -tmpLim , tmpLim ] , ...          
                     'YLim',   0.7 * [ -tmpLim , tmpLim ] , ...    
                     'ZLim',   0.7 * [ -tmpLim , tmpLim ] , ...
                     'view',   [44.9986   12.8650 ]     )                  

set( ani.hAxes{3},   'view',   [44.9986   12.8650 ]     )                  

               
ani.run( 0.2, false, ['output', num2str( idx )] )      
     

%% (1F) Ellipse Plot

tmp = 20;            
[XX, YY, ZZ] = Ellipse_plot( 0.3 * rawData.Kx(:,:,tmp), [0,0,0] );

hF = figure(); hA = axes( 'parent', hF );
hP = mesh(XX,YY,ZZ, 'parent', hA); axis equal; hold( hA,'on' );
[ V, D ] = eig( rawData.Kx( :, :, tmp ) );
scale = 0.3;
V = scale * V; 

quiver3( 0,0,0, V(1,1), V(2,1), V(3,1), 'parent' ,hA, 'linewidth', 4, 'color', c.green  , 'MaxheadSize', 0.4 ) 
quiver3( 0,0,0, V(1,2), V(2,2), V(3,2), 'parent' ,hA, 'linewidth', 4, 'color', c.blue,    'MaxheadSize', 0.4 )
quiver3( 0,0,0, V(1,3), V(2,3), V(3,3), 'parent' ,hA, 'linewidth', 4, 'color', c.orange, 'MaxheadSize', 0.4 )


%% (1G) Dot Product Analysis.

idx = 3;
rawData = rawDataList{ idx };

if idx == 1
    thres = 0.9;
    
elseif idx == 2
    thres = 1.2;
    
elseif idx == 3
    thres = 0.2;
    
end

idx_list = find( rawData.currentTime >= rawData.t_start & rawData.currentTime <= rawData.t_end  );

hold on
plot( rawData.currentTime( idx_list ), rawData.minVec(1,idx_list ), '--', 'linewidth', 4 )
plot( rawData.currentTime( idx_list ), rawData.minVec(2,idx_list ), '--', 'linewidth', 4 ) 
plot( rawData.currentTime( idx_list ), rawData.minVec(3,idx_list ), '--', 'linewidth', 4 ) 
plot( rawData.currentTime( idx_list ), rawData.dotProd1(idx_list ), '-' , 'linewidth', 5 ) 

% ul =   1;
% ll =  -1;
% set( gca, 'Ylim', [ll, ul] );
set( gca, 'XLim', [rawData.t_start, rawData.t_end] )
% ha = fill([rawData.t_start, rawData.t_start, rawData.t_end, rawData.t_end], [ll, ul, ul, ll], [0,0,1]);
% ha.FaceAlpha = 0.1;
% ha.EdgeAlpha = 0.0;

% Adding the start and end time of the graph
% set( gca, 'xtick', sort( [rawData.t_start, round( rawData.t_end, 2 ), linspace( min( get(gca, 'xtick' ) ), max( get(gca, 'xtick' ) ), 5 ) , ] ) );

legend( {'x component', 'y component', 'z component', 'Dot Product' }, 'location', 'northeastoutside') 
title( 'Eigenvector Components and its dot product' ); xlabel( 'Time [sec]' ); ylabel( 'Arbitrary Unit [-]' );

mySaveFig( gcf, ['dotproduct', num2str(idx)] )