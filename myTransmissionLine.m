% [Project]        [Example] Transmission Line Impedance Calculation.
% [Author]         Moses C. Nah
% [Creation Date]  Sunday, September 20th, 2020
% [Emails]         Moses C. Nah   : mosesnah@mit.edu

%% (--) INITIALIZATION
clear all; close all; clc;

cd( fileparts( matlab.desktop.editor.getActiveFilename ) );                % Setting the current directory as the folder where this "main.m" script is located

myFigureConfig(     'fontsize',  20, ...
                   'lineWidth',   5, ...
                  'markerSize',  25 );               
c  = myColor();                                                            % Setting the color as global.

%% (-1) Translational Mass-Spring-Damper system

m = 2; k = 1; b = 1;
syms s
syms w 
Z  = m * s;
Zk = (b + k/s);

N = 25;
for i = 1 : N
   
    if i == 1
       Ztot = m * s;
    end
    Ztot = Z + 1/( 1/Zk + 1/Ztot ); 
    
end

%%
Ztot1 = subs( Ztot,s, w*1i )
subs(Ztot1, w, 1 )
vpa( ans )
subs( Ztot, m, 1 ); subs( Ztot, k, 1 ); subs( Ztot, b, 1 );