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

clear all; close all; clc;
workspace;
                                                                           
tmpDir = "/Users/mosesnah/MATLAB-Drive";                                   % Adding the directory for the Functions which is all saved in MATLAB Drive 
addpath( tmpDir );
tmpList = dir( fullfile( tmpDir , '*.m' ) );                               % Getting all the .m file functions we are importing.

for tmp = { tmpList.name }
    fprintf('IMPORTED FUNCTION [ %-25s ] \n', tmp{ 1 } );
end


cd( fileparts(  matlab.desktop.editor.getActiveFilename ) );               % Setting the current directory as the folder where this "main.m" script is located

                                                                           % [Default Settings]
fontSize = 10; lineWidth = 5; markerSize = 25;                             % The default sizes of the plot
mySetFigureConfig( fontSize, 2 * lineWidth, markerSize );                  % Setting the default configuration of the figure.
c     = myColor();                                                         % Getting my Color, a list of colors for the plot.

clear tmp*

%% (--) ========================================================
%% (1A) Plotting Submovements
%% --- (1A - a) Time vs Position/Velocity, a Single Submovements

tStep = 0.001;
D     = 0.8; 
N     = D / tStep;

tVec  = tStep * [ 0: N ];
vVec  = (30 * ( tVec/D ).^2 - 60 * ( tVec/D ).^3 + 30 * ( tVec/D ).^4);
pVec  = 0.1 + 0.8 * (10 * ( tVec/D ).^3 - 15 * ( tVec/D ).^4 + 6 * ( tVec/D ).^5 );
pVec2 = 0.9 - 0.3 * (10 * ( tVec/D ).^3 - 15 * ( tVec/D ).^4 + 6 * ( tVec/D ).^5 );

vVec  =   0.8 * (30 * ( tVec/D ).^2 - 60 * ( tVec/D ).^3 + 30 * ( tVec/D ).^4 );
vVec2 = - 0.3 * (30 * ( tVec/D ).^2 - 60 * ( tVec/D ).^3 + 30 * ( tVec/D ).^4 );

hFig = figure(); hAxes = axes('parent', hFig );
plot( tVec, vVec, tVec, vVec2) 
set(gca, 'visible', 'off')

%% --- (1A - b) Time vs Position/Velocity, Multiple Submovements

% toffSet = 0.6;
toffSet = 0.9;
D1 = 0.8; D2 = 0.6;
v1SH = 0.7; v2SH = 0.3;
v1EL = 0.8; v2EL = 0.4;

tStep = 0.001;
tWhole = max( D1, D2 + toffSet );
vVec = zeros( 1, tWhole/tStep + 1 );

for i = 1:2
    
    if ( i == 1 )
        tmpt1Vec = 0 : tStep : D1;
        tmp1 = 0.7 * (30 * ( tmpt1Vec/D1 ).^2 - 60 * ( tmpt1Vec/D1 ).^3 + 30 * ( tmpt1Vec/D1 ).^4);
        for j = 1:length( tmp1 )
            vVec(j) = tmp1(j);
        end
    else
        tmpt2Vec = 0 : tStep : D2;
        tmp2 =  0.3 * (30 * ( tmpt2Vec/D2 ).^2 - 60 * ( tmpt2Vec/D2 ).^3 + 30 * ( tmpt2Vec/D2 ).^4 );
%         tmp2 = 0.7 * (30 * ( tmpt2Vec/D2 ).^2 - 60 * ( tmpt2Vec/D2 ).^3 + 30 * ( tmpt2Vec/D2 ).^4 );
        idxOffset = toffSet/tStep;
        for j = 1:length( tmp2 )
            vVec(j + idxOffset) = vVec(j+idxOffset) + tmp2(j);
        end
    end
    
end

f = figure(); a = axes('parent', f);

p1 = plot(0:tStep:tWhole, vVec);
hold on
% p1.Color(4)=0.2;
area( 0:tStep:tWhole, vVec, 'FaceColor', p1.Color, 'FaceAlpha', 0.4, 'EdgeAlpha', 0 );

box off
set(a, 'visible','off')
p2 = plot(tmpt1Vec, tmp1, '--', 'linewidth', 8);
p2.Color(4)=0.2;
% area( tmpt1Vec, tmp1, 'FaceColor', p2.Color, 'FaceAlpha', 0.4, 'EdgeAlpha', 0 );
p3 = plot(toffSet + tmpt2Vec, tmp2, '--' ,'linewidth', 8);
p3.Color(4)=0.2;
% area( toffSet + tmpt2Vec, tmp2, 'FaceColor', p3.Color, 'FaceAlpha', 0.4, 'EdgeAlpha', 0 );


f1 = figure(); a1 = axes('parent', f1);

% pVec = cumsum( vVec * tStep );
% p1 = plot(0:tStep:tWhole, pVec);

box off
set(a1, 'visible','off')
% p1.Color(4)=0.2;
% area( 0:tStep:tWhole, pVec, 'FaceColor', p1.Color, 'FaceAlpha', 0.4, 'EdgeAlpha', 0 );

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