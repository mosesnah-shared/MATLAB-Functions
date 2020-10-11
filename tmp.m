
clear all; close all; clc;
workspace;
cd( fileparts( matlab.desktop.editor.getActiveFilename ) );                % Setting the current directory as the folder where this "main.m" script is located

myFigureConfig(  'fontsize',  20, ...
                'lineWidth',   5, ...
               'markerSize',  25 );         
              
c  = myColor();                

clear tmp*

r = myTxtParse( 'test1.txt' );

%%

mov_par = [0.2037, 0.024 , 0.2423, 0.4717, 0.0783, 0.2192, 0.2819, 0.3077, 0.0939, 0.288 , 0.2248, 0.4393, 0.4147, 0.4043, 0.1252];

init = [0.2037, 0.024 , 0.2423, 0.4717];
A11 = mov_par( 5 );
A12 = mov_par( 6 );
A21 = mov_par( 7 );
A22 = mov_par( 8 );
A31 = mov_par( 9 );
A32 = mov_par( 10 );
A41 = mov_par( 11 );
A42 = mov_par( 12 );

Af = [A11;A21;A31;A41];
Ab = [A12;A22;A32;A42];

D1   = mov_par(13);
D2   = mov_par(14);
toff = mov_par(15);

D    = max( D1, D2 + toff );
dt = 0.0001;
Ntot = D/dt + 1; 

Ntot = round( Ntot );

v1 = @(t) ( Af / D1 * ( 30 * (t/D1).^2 - 60 * (t/D1).^3 + 30 * (t/D1).^4 ) );
v2 = @(t) ( Ab / D2 * ( 30 * (t/D2).^2 - 60 * (t/D2).^3 + 30 * (t/D2).^4 ) );

Darr = [D1, D2];
tarr = [0, toff];

varr = zeros( 4, Ntot );
parr = zeros( 4, Ntot );

for i = 1 : 2
   
    iS = round( tarr( i ) / dt ) + 1;
    iE = round( ( tarr( i ) + Darr( i ) ) / dt ) + 1; 
    
    if i == 1
        tmp = v1( 0: dt : Darr(i) );
    else 
        tmp = v2( 0: dt : Darr(i) );
    end
    
    varr( :, iS:iE ) = varr( :, iS:iE  ) + tmp;
    
end

parr = init' + cumsum( varr, 2 ) * dt;

%%
plot( r.currentTime, r.vZFT( 1, :) )
hold on
plot( 0.1+ dt * (1:length( varr ) ), varr(1,:) ) 

%%
plot( r.currentTime, r.pZFT )
hold on
plot( 0.1+ dt * (1:length( varr ) ), parr, '--' ) 