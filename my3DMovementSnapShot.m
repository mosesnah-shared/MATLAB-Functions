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

myFigureConfig(  'fontsize',  30, ...
                'lineWidth',   5, ...
               'markerSize',  25 );         
              
c  = myColor();                

clear tmp*

%% (1A) Parsing Data

for i = 1 : 3
    
%    rawData{ i } = myTxtParse( ['data_log_T', num2str( i ), '.txt']  );
    rawData{ i } = myTxtParse( ['data_log_dense_T', num2str( i ), '.txt']  );
   
   rawData{ i }.geomXPositions = rawData{ i }.geomXYZPositions( 1 : 3 : end , : );
   rawData{ i }.geomYPositions = rawData{ i }.geomXYZPositions( 2 : 3 : end , : );
   rawData{ i }.geomZPositions = rawData{ i }.geomXYZPositions( 3 : 3 : end , : );
   
end

%% (1B) Screen-Shot

idx = 3;

idxS = find( rawData{ idx }.outputVal == min( rawData{ idx }.outputVal )  );

tIdx  = [10, 68, idxS];                                                % The index of the positions that are aimed to be shown
alpha = [0.2, 0.5, 1.0];                                              % The alpha values of each screen shot   
f = figure( ); a = axes( 'parent', f, 'Projection','perspective' );
axis equal; hold on;

switch idx 
   
    case 1
        cTarget = c.pink;

    case 2
        cTarget = c.blue;
    case 3
        cTarget = c.green;
end

mTarget = scatter3( rawData{ idx }.geomXPositions( 1, 1 ), ...
                    rawData{ idx }.geomYPositions( 1, 1 ), ...
                    rawData{ idx }.geomZPositions( 1, 1 ), 300, ...        % Setting the handle of the ZFT Plot, 
                   'parent', a,   'LineWidth', 4,               ...       % For the main plot (s1)
                   'MarkerFaceColor', c.white, 'MarkerEdgeColor', cTarget, ...
                   'MarkerFaceAlpha', 1      , 'MarkerEdgeAlpha',    1  );

      
for i = 1 : length( tIdx )
    p1 = plot3(  rawData{ idx }.geomXPositions( 2:4, tIdx( i ) ), ...
                 rawData{ idx }.geomYPositions( 2:4, tIdx( i ) ), ...
                 rawData{ idx }.geomZPositions( 2:4, tIdx( i ) ), ...
                 'parent', a, ...
                'linewidth', 7, 'color', [ c.orange_milky, alpha( i ) ] );
            
    p2 = scatter3( rawData{ idx }.geomXPositions( 2:4, tIdx( i ) ), ...
                   rawData{ idx }.geomYPositions( 2:4, tIdx( i ) ), ...
                   rawData{ idx }.geomZPositions( 2:4, tIdx( i ) ), 300, ... 
                   'parent', a,   'LineWidth', 4, ...
                   'MarkerFaceColor', c.white, 'MarkerEdgeColor', c.orange_milky, ...
                   'MarkerFaceAlpha', 1      , 'MarkerEdgeAlpha', alpha(i)  );

               
    p3 = plot3(  rawData{ idx }.geomXPositions( 5:end, tIdx( i ) ), ...
                 rawData{ idx }.geomYPositions( 5:end, tIdx( i ) ), ...
                 rawData{ idx }.geomZPositions( 5:end, tIdx( i ) ), ...
                 'parent', a, ...
                'linewidth', 6, 'color', [ c.purple_plum, alpha( i ) ] );
            
    p4 = scatter3( rawData{ idx }.geomXPositions( 5:end, tIdx( i ) ), ...
                   rawData{ idx }.geomYPositions( 5:end, tIdx( i ) ), ...
                   rawData{ idx }.geomZPositions( 5:end, tIdx( i ) ), 30, ... 
                   'parent', a,   'LineWidth', 1, ...
                   'MarkerFaceColor', c.white, 'MarkerEdgeColor', c.purple_plum, ...
                   'MarkerFaceAlpha', 1      , 'MarkerEdgeAlpha', alpha(i)  );
               
               
end    

xlabel( 'X [m]', 'fontsize', 30 ); 
ylabel( 'Y [m]', 'fontsize', 30 );
zlabel( 'Z [m]', 'fontsize', 30 );

tmpLim = 2.4;               
set( a,   'XLim',   [ - tmpLim, tmpLim ] , ...                             % Setting the axis ratio of x-y-z all equal.
          'YLim',   [ - tmpLim, tmpLim ] , ...    
          'ZLim',   [ - tmpLim, tmpLim ] , ...
          'view',   [  44.3530, 7.4481 ] )

mySaveFig( f, ['output', num2str( idx )] );
            
%% (1C) Upper-Limb Movement

% Plotting the ``trace'' or ``path'' of the upper-limb movement.
idx = 1;

switch idx 
   
    case 1
        tStart = 0.1; D = 0.950; % tStart = 0.3 if not Dense!
    case 2
        tStart = 0.1; D = 0.579;
    case 3
        tStart = 0.1; D = 0.950;
end

idxS = find( rawData{ idx }.currentTime >= tStart & rawData{ idx }.currentTime <= tStart + D );	
% idxS = idxS( 1 : 3 : end);
idxStart = min( idxS ); idxEnd = max( idxS );

f = figure( ); a = axes( 'parent', f, 'Projection','perspective' );
axis equal; hold on;

scatter3( rawData{ idx }.geomXPositions( 2, idxStart ), ...
          rawData{ idx }.geomYPositions( 2, idxStart ), ...
          rawData{ idx }.geomZPositions( 2, idxStart ), 300, ... 
           'parent', a,   'LineWidth', 4, ...
           'MarkerFaceColor', c.white, 'MarkerEdgeColor', c.orange_milky, ...
           'MarkerFaceAlpha', 1      , 'MarkerEdgeAlpha', 1  );

cElbow = myColorGradient( c.grey, c.blue,  length( idxS ), "exponential" );
cEE    = myColorGradient( c.grey, c.green, length( idxS ), "exponential" );
       

plot3( rawData{ idx }.geomXPositions( 3, idxStart : idxEnd ), ...
       rawData{ idx }.geomYPositions( 3, idxStart : idxEnd ), ...
       rawData{ idx }.geomZPositions( 3, idxStart : idxEnd ), ... 
      'parent', a,   'LineWidth', 4, 'color', [c.blue, 0.3] )

plot3( rawData{ idx }.geomXPositions( 4, idxStart : idxEnd ), ...
       rawData{ idx }.geomYPositions( 4, idxStart : idxEnd ), ...
       rawData{ idx }.geomZPositions( 4, idxStart : idxEnd ), ...
      'parent', a,   'LineWidth', 4, 'color', [c.green, 0.3] )  


for i = 1 : length( idxS )
    
    scatter3( rawData{ idx }.geomXPositions( 3, idxS( i ) ), ...
              rawData{ idx }.geomYPositions( 3, idxS( i ) ), ...
              rawData{ idx }.geomZPositions( 3, idxS( i ) ), 200, ... 
               'parent', a,   'LineWidth', 4, ...
               'MarkerFaceColor', c.white, 'MarkerEdgeColor', cElbow( i, : ) , ...
               'MarkerFaceAlpha', 1      , 'MarkerEdgeAlpha', 1  );           
    
    scatter3( rawData{ idx }.geomXPositions( 4, idxS( i ) ), ...
              rawData{ idx }.geomYPositions( 4, idxS( i ) ), ...
              rawData{ idx }.geomZPositions( 4, idxS( i ) ), 200, ... 
               'parent', a,   'LineWidth', 4, ...
               'MarkerFaceColor', c.white, 'MarkerEdgeColor', cEE( i, : ), ...
               'MarkerFaceAlpha', 1      , 'MarkerEdgeAlpha', 1  );           

end


xEL = rawData{ idx }.geomXPositions( 3, idxS )';
yEL = rawData{ idx }.geomYPositions( 3, idxS )';
zEL = rawData{ idx }.geomZPositions( 3, idxS )';

xEE = rawData{ idx }.geomXPositions( 4, idxS )';
yEE = rawData{ idx }.geomYPositions( 4, idxS )';
zEE = rawData{ idx }.geomZPositions( 4, idxS )';

[ kEL, volEL ] = convhull( xEL, yEL, zEL, 'Simplify',true );
[ kEE, volEE ] = convhull( xEE, yEE, zEE, 'Simplify',true );

xlabel( 'X [m]', 'fontsize', 30 ); 
ylabel( 'Y [m]', 'fontsize', 30 );
zlabel( 'Z [m]', 'fontsize', 30 );

tmpLim = 0.6;               
set( a,   'XLim',   [ - tmpLim, tmpLim ] , ...                             % Setting the axis ratio of x-y-z all equal.
          'YLim',   [ - tmpLim, tmpLim ] , ...    
          'ZLim',   [ - tmpLim, tmpLim ] , ...
          'view',   [  44.3530, 7.4481 ] )  
               
% trisurf( kEL, xEL, yEL, zEL, 'Facecolor',  c.blue, 'FaceAlpha', 0.1, 'EdgeColor', 'none' );
% trisurf( kEE, xEE, yEE, zEE, 'Facecolor', c.green, 'FaceAlpha', 0.1, 'EdgeColor', 'none' );

xEE = d3.geomXYZPositions( 10, : );
yEE = d3.geomXYZPositions( 11, : );
zEE = d3.geomXYZPositions( 12, : );

[xx, yy] = meshgrid( xEE, yEE );
C = planefit( xEE, yEE, zEE );
zzft = C( 1 ) * xx + C( 2 ) * yy + C( 3 );
surf( xx, yy, zzft, 'edgecolor', 'none', 'facecolor', c.green, 'facealpha', 0.3 )
hold on
plot3( xEE, yEE, zEE, 'o' );
axis equal
% p3 = plot3(  rawData{ idx }.geomXPositions( 5:end, tIdx( i ) ), ...
%              rawData{ idx }.geomYPositions( 5:end, tIdx( i ) ), ...
%              rawData{ idx }.geomZPositions( 5:end, tIdx( i ) ), ...
%              'parent', a, ..
%             'linewidth', 6, 'color', [ c.purple_plum, alpha( i ) ] );

% mySaveFig( f, ['output', num2str( idx )] );

%% (1D) Calculating the co-planarity of the movement


% Plotting the ``trace'' or ``path'' of the upper-limb movement.
idx  = 3;
idx2 = 2;       % 1: EL, 2: EE 

switch idx 
   
    case 1
        tStart = 0.3; D = 0.950; % tStart = 0.3 if not Dense!
    case 2
        tStart = 0.3; D = 0.579;
    case 3
        tStart = 0.3; D = 0.950;
end

switch idx2 
        
    case 1  %% EL
          color = c.blue;
    case 2  %% EE
          color = c.green;
end

idxS = find( rawData{ idx }.currentTime >= tStart & rawData{ idx }.currentTime <= tStart + D );	
idxStart = min( idxS ); idxEnd = max( idxS );



f = figure( ); a = axes( 'parent', f, 'Projection','perspective' );
axis equal; hold on;

x = rawData{ idx }.geomXPositions( idx2 + 2, idxS )';
y = rawData{ idx }.geomYPositions( idx2 + 2, idxS )';
z = rawData{ idx }.geomZPositions( idx2 + 2, idxS )';

p  = [ x, y, z ];
pC = mean( p );

pn = p - pC;                                                               % Centralized data
[eigvecs, eigvals] = eig(pn' * pn);

[ eigvecs2, ~, eigvals2 ] = pca( p );                                        % Running the PCA of the data

% The last vector of eigvecs correspond to the normal vector of the plane, which is the smallest pca value of the data matrix
w = null( eigvecs( : , 1)' );                                              % Find two orthonormal vectors which are orthogonal to v


scatter3( rawData{ idx }.geomXPositions( 2, idxStart ), ...
          rawData{ idx }.geomYPositions( 2, idxStart ), ...
          rawData{ idx }.geomZPositions( 2, idxStart ), 300, ... 
          'parent', a,   'LineWidth', 4, ...
          'MarkerFaceColor', c.white, 'MarkerEdgeColor', c.orange_milky, ...
          'MarkerFaceAlpha', 1      , 'MarkerEdgeAlpha', 1  );

plot3( rawData{ idx }.geomXPositions( idx2 + 2, idxStart : idxEnd ), ...
       rawData{ idx }.geomYPositions( idx2 + 2, idxStart : idxEnd ), ...
       rawData{ idx }.geomZPositions( idx2 + 2, idxStart : idxEnd ), ... 
      'parent', a,   'LineWidth', 4, 'color', [color, 0.3] )

scatter3(  rawData{ idx }.geomXPositions( idx2 + 2, idxS ), ...
           rawData{ idx }.geomYPositions( idx2 + 2, idxS ), ...
           rawData{ idx }.geomZPositions( idx2 + 2, idxS ), 200, ... 
           'parent', a,   'LineWidth', 4, ...
           'MarkerFaceColor', c.white, 'MarkerEdgeColor', color, ...
           'MarkerFaceAlpha', 1      , 'MarkerEdgeAlpha', 1  );           
       

tmpLim = 0.45;      

tmp = 0;
for i = 1 : length( idxS )  % Brute force calculation of the distance.
    ttmp = abs( eigvecs(1,1) * ( x(i) - pC(1) ) + eigvecs(2,1) * ( y(i) - pC(2) ) + eigvecs(3,1) * ( z(i) - pC(3) )  ) ;
    tmp = tmp + ttmp * ttmp;
end

sqrt( tmp/length( idxS ) )

[P,Q] = meshgrid( -tmpLim: 0.001 : tmpLim );                              % Provide a gridwork (you choose the size)

XX = pC( 1 ) + w(1,1) * P + w(1,2) * Q;                                    % Compute the corresponding cartesian coordinates
YY = pC( 2 ) + w(2,1) * P + w(2,2) * Q;                                    %   using the two vectors in w
ZZ = pC( 3 ) + w(3,1) * P + w(3,2) * Q;
       
surf( XX, YY, ZZ, 'parent', a, 'edgecolor', 'none', 'facecolor', color, 'facealpha', 0.3 )
tmpLim2 = 0.7;
xlabel( 'X [m]', 'fontsize', 30 ); 
ylabel( 'Y [m]', 'fontsize', 30 );
zlabel( 'Z [m]', 'fontsize', 30 );


set( a,   'XLim',   [ - tmpLim2, tmpLim2 ] , ...                             % Setting the axis ratio of x-y-z all equal.
          'YLim',   [ - tmpLim2, tmpLim2 ] , ...    
          'ZLim',   [ - tmpLim2, tmpLim2 ] , ...
          'view',   [  44.3530, 7.4481 ] )  
               
      
%% (1E) Calculating the contribution of the each eigenmovements.

K = [ 17.4,  4.7, -1.90, 8.40; ...
      9.00, 33.0,  4.40, 0.00; ...
     -13.6,  3.0, 27.70, 0.00; ...
      8.40,  0.0,  0.00, 23.2];
  
Ksym = ( K + K' )/2;      % Extracting out the symmetric part

[V, D] = eig( Ksym );

v1 = V( :,1 );
v2 = V( :,2 );
v3 = V( :,3 );
v4 = V( :,4 );      % Ordered in ascending order of the size of eigenvalues. 

idx = 3;

switch idx 
   
    case 1
        tStart = 0.3; D = 0.950; % tStart = 0.3 if not Dense!
    case 2
        tStart = 0.3; D = 0.579;
    case 3
        tStart = 0.3; D = 0.950;
end

idxS = find( rawData{ idx }.currentTime >= tStart & rawData{ idx }.currentTime <= tStart + D );	
idxStart = min( idxS ); idxEnd = max( idxS );

clear c1 c2 c3 c4

    
dp = rawData{ idx }.jointAngleActual( 1:4, : ) - rawData{ idx }.pZFT;
dv =   rawData{ idx }.jointVelActual( 1:4, : ) - rawData{ idx }.vZFT;

c1_K = dp' * v1;
c2_K = dp' * v2;
c3_K = dp' * v3;
c4_K = dp' * v4;

c1_B = dv' * v1;
c2_B = dv' * v2;
c3_B = dv' * v3;
c4_B = dv' * v4;


norm( c1_K( idxS ), 2 )
norm( c2_K( idxS ), 2 )
norm( c3_K( idxS ), 2 )
norm( c4_K( idxS ), 2 )


f = figure( ); a = axes( 'parent', f );hold on;

plot( rawData{idx}.currentTime( idxS ) - tStart, [c1_K( idxS ), c2_K( idxS ), c3_K( idxS ), c4_K( idxS ) ]' )
% plot( rawData{idx}.currentTime, [c1_K, c2_K, c3_K, c4_K]' )
% plot( rawData{idx}.currentTime, [c1_B, c2_B, c3_B, c4_B]' )
legend( "$c_1$","$c_2$","$c_3$","$c_4$", 'fontsize', 30, 'location', 'northwest' );

set( a,   'XLim',   [ 0, rawData{idx}.currentTime( idxEnd ) - tStart ], 'fontsize', 28 )
set( a,   'YLim',   [ -1, 1]                                          , 'fontsize', 28 )

xlabel( 'Time [sec]'      , 'fontsize', 34 ); 
ylabel( 'Contribution [-]', 'fontsize', 34 );