% [Project]        [M3X] Whip Project
% [Title]          Plotting submovements for graphical representation.
% [Author]         Moses C. Nah
% [Creation Date]  Thursday, June 13th, 2020
% [Emails]         Moses C. Nah   : mosesnah@mit.edu

%% (0A) DESCRIPTION

%) ====================================================================== (%
%) Multiple plots of submovements for graphical representation.
%) The basis function for the submovement is the minimum-jerk-trajectory
%) [REF] Flash, Tamar, and Neville Hogan. "The coordination of arm movements: an experimentally confirmed mathematical model." Journal of neuroscience 5.7 (1985): 1688-1703. APA
%) ====================================================================== (%

%% (0B) REVISION LOG

%)  [Number]     [Editor]        [Date]                [Description]
%)  00          Moses C. Nah    2020.06.13         Documentation Creation
%)  0-          

%% (0C) SYNTAX

%) (a) This script uses Camel-Hump style naming for the variables, classes and functions.
%) (b) Prefix "h" stand for object handle, most of the objects will be "graphic objects"
%) (c) Function named with prefix "my" is the locally-defined function.

%% (--) INITIALIZATION

clear all; close all; clc; workspace;
cd( fileparts( matlab.desktop.editor.getActiveFilename ) );                % Setting the current directory as the folder where this "main.m" script is located

myFigureConfig(  'fontsize',  20, ...
                'lineWidth',   5, ...
               'markerSize',  25 );         
              
c  = myColor();                

clear tmp*

%% (--) ========================================================
%% (1A) Plotting Submovements
%% --- (1A - a) Time vs Position/Velocity, a Single Submovements

dt = 0.001;

%                           pi   pf   D
submov1 = mySubmovement( [ 0.1, 0.9, 0.8 ]  );
submov2 = mySubmovement( [ 0.9, 0.6, 0.8 ]  );

%                                              dt toff   T
[ p_vec1, v_vec1, t_vec ] = submov1.data_arr(  dt,   0, 1.0 );
[ p_vec2, v_vec2, t_vec ] = submov2.data_arr(  dt, 0.1, 1.0 );

hFig = figure(); hAxes = axes('parent', hFig );
plot( t_vec, p_vec1, t_vec, p_vec2, 'linewidth', 7, 'color', c.blue, 'parent', hAxes );
set(gca, 'visible', 'off')

%% --- (1A - b) Time vs Position/Velocity, Multiple Submovements

% toffSet = 0.6;
toffSet = 0.6;
D1 = 0.8; D2 = 0.5;
v1SH = 0.7; v2SH = 0.3;
v1EL = 0.8; v2EL = 0.4;

tStep = 0.001;
tWhole = max( D1, D2 + toffSet );
vVec  = zeros( 1, int32( tWhole/tStep + 1 ) );
vVec1 = zeros( 1, int32( tWhole/tStep + 1 ) );
vVec2 = zeros( 1, int32( tWhole/tStep + 1 ) );

for i = 1:2
    
    if ( i == 1 )
        tmpt1Vec = 0 : tStep : D1;
        tmp1 = 0.7 * (30 * ( tmpt1Vec/D1 ).^2 - 60 * ( tmpt1Vec/D1 ).^3 + 30 * ( tmpt1Vec/D1 ).^4);
        for j = 1:length( tmp1 )
            vVec(j) = tmp1(j);
            vVec1(j) = tmp1(j);
        end
    else
        tmpt2Vec = 0 : tStep : D2;
        tmp2 =  0.3 * (30 * ( tmpt2Vec/D2 ).^2 - 60 * ( tmpt2Vec/D2 ).^3 + 30 * ( tmpt2Vec/D2 ).^4 );
%         tmp2 = 0.7 * (30 * ( tmpt2Vec/D2 ).^2 - 60 * ( tmpt2Vec/D2 ).^3 + 30 * ( tmpt2Vec/D2 ).^4 );
        idxOffset = toffSet/tStep;
        for j = 1:length( tmp2 )
            vVec(j + idxOffset) = vVec(j+idxOffset) + tmp2(j);
            vVec2( idxOffset + j )  =tmp2(j);
        end
    end
    
end

tVec = 0:tStep:tWhole;

f = figure(); a = axes('parent', f);

pVec = cumsum( vVec * tStep );
pVec1 = cumsum( vVec1 * tStep );
pVec2 = cumsum( vVec2 * tStep );

p1 = plot( tVec, vVec1, 'linestyle', '--', 'color', c.blue);
hold on
p2 = plot( tVec, vVec2, 'linestyle', '--', 'color', c.orange );
p  = plot( tVec, vVec, 'color', c.yellow, 'linewidth', 10  );
% area( tVec, vVec, 'FaceColor', p.Color, 'FaceAlpha', 0.4, 'EdgeAlpha', 0 );
% area( tVec, vVec1, 'FaceColor', p1.Color, 'FaceAlpha', 0.4, 'EdgeAlpha', 0 );
% area( tVec, vVec2, 'FaceColor', p2.Color, 'FaceAlpha', 0.4, 'EdgeAlpha', 0 );
box off
set(a, 'visible','off')


%% --- (1A - c) Joint Coordinate Plot

hFig = figure(); hAxes = axes('parent', hFig );

p1 = subplot( 2, 2, 1 );
p3 = subplot( 2, 2, 3 );
p4 = subplot( 2, 2, 4 );

hold( p1, 'on' );
hold( p3, 'on' );
hold( p4, 'on' );

tVec  = 0.001 * ( 0:1000 );
t1Vec = 0.1:0.001:0.9;
p1Vec = 0.1 + 0.8 * (10 * ( tVec ).^3 - 15 * ( tVec ).^4 + 6 * ( tVec ).^5 );
v1Vec = 0.7 * (30 * ( (t1Vec - 0.1)/0.8 ).^2 - 60 * ( (t1Vec - 0.1)/0.8 ).^3 + 30 * ( (t1Vec - 0.1)/0.8 ).^4 );

t4Vec = 0.1:0.001:0.8;
p4Vec = 0.8 - 0.7 * (10 * ( tVec ).^3 - 15 * ( tVec ).^4 + 6 * ( tVec ).^5 );
v4Vec = 0.7 * (30 * ( (t4Vec - 0.1)/0.7 ).^2 - 60 * ( (t4Vec - 0.1)/0.7 ).^3 + 30 * ( (t4Vec - 0.1)/0.7 ).^4 );

plot( p3, [0.1, 0.9], [0.8, 0.1], 'color', c.grey )
plot( p3, 0.1, 0.8, 'marker', 'o', 'color', c.orange, 'markerfacecolor', c.orange )
plot( p3, 0.9, 0.1, 'marker', 'o', 'color', c.blue  , 'markerfacecolor', c.blue   )

% plot( p1, p1Vec,  tVec, 'color', c.grey )
plot( p1, t1Vec,  v1Vec, 'color', c.grey )
% plot( p1, 0.1, 0.0, 'marker', 'o', 'color', c.orange, 'markerfacecolor', c.orange )
% plot( p1, 0.9, 1.0, 'marker', 'o', 'color', c.blue,   'markerfacecolor', c.blue   )

plot( p1, 0.1, 0.0, 'marker', 'o', 'color', c.orange, 'markerfacecolor', c.orange )
plot( p1, 0.9, 0.0, 'marker', 'o', 'color', c.blue,   'markerfacecolor', c.blue   )


% plot( p4,  tVec, p4Vec, 'color', c.grey )
plot( p4,  v4Vec, t4Vec, 'color', c.grey )
% plot( p4, 0.0, 0.8, 'marker', 'o', 'color', c.orange, 'markerfacecolor', c.orange )
% plot( p4, 1.0, 0.1, 'marker', 'o', 'color', c.blue,   'markerfacecolor', c.blue   )

plot( p4, 0.0, 0.8, 'marker', 'o', 'color', c.orange, 'markerfacecolor', c.orange )
plot( p4, 0.0, 0.1, 'marker', 'o', 'color', c.blue,   'markerfacecolor', c.blue   )

set( p1, 'XTick', [], 'YTick', [] );
set( p3, 'XTick', [], 'YTick', [] );
set( p4, 'XTick', [], 'YTick', [] );

set( p1, 'Xlim', [0,1], 'Ylim', [0,2] )
set( p3, 'Xlim', [0,1], 'Ylim', [0,1] )
set( p4, 'Xlim', [0,2], 'Ylim', [0,1] )

