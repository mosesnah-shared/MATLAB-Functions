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
    
myFigureConfig(     'fontsize',  20, ...
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
syms L1 L2 Lc1 Lc2 m1 m2 positive                %  L: Length of each limb segments
                                                 % Lc: Length from proximal joint to C.O.M. of limb
                                                 %  m: mass of each limb segments
syms Ixx1 Ixx2 Iyy1 Iyy2 Izz1 Izz2 positive      %  I: Prinxiple inertia of each limb                                                 

syms g                                           % Gravity of upper limb

I1 = [Ixx1, Iyy1, Izz1]; 
I2 = [Ixx2, Iyy2, Izz2];

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

pUPCOM  = T01 * T12 * T23 * [0;0;-Lc1;1];
pLOWCOM = T04 * [0;0;-Lc2; 1]; 

% END EFFECTOR
pEE = T04 * [0;0;-L2; 1];                        % End-point (effector) position vector, multiplying the position of EE w.r.t Frame 4
x  = [ pEE(1), pEE(2), pEE(3) ];                 % End-point (effector) position vector   
dx = diff( x, t );                               % Time differentiation of dx
dx = subs( dx, diff( q,t ), dq );                % Substituting all diff( q,t ) to dq's

JEE  = myJacobian(dx, dq);                       % Getting the jacobian of the end-effector

dJEE = diff( JEE, t) ;                           % Getting the time-derivative of jacobian of the end-effector

dJEE = subs( dJEE, diff( q,t ), dq );
dJEE = simplify( dJEE );

% UPPER LIMB COM
x  = [ pUPCOM(1), pUPCOM(2), pUPCOM(3) ];                 % End-point (effector) position vector   
dx = diff( x, t );                               % Time differentiation of dx
dx = subs( dx, diff( q,t ), dq );                % Substituting all diff( q,t ) to dq's

J_UPCOM  = myJacobian(dx, dq);                       % Getting the jacobian of the end-effector

dJ_UPCOM = diff( J_UPCOM, t) ;                           % Getting the time-derivative of jacobian of the end-effector

dJ_UPCOM = subs( dJ_UPCOM, diff( q,t ), dq );
dJ_UPCOM = simplify( dJ_UPCOM );

% LOWER LIMB COM
x  = [ pLOWCOM(1), pLOWCOM(2), pLOWCOM(3) ];                 % End-point (effector) position vector   
dx = diff( x, t );                               % Time differentiation of dx
dx = subs( dx, diff( q,t ), dq );                % Substituting all diff( q,t ) to dq's

J_LOWCOM  = myJacobian(dx, dq);                       % Getting the jacobian of the end-effector

dJ_LOWCOM = diff( J_LOWCOM, t) ;                           % Getting the time-derivative of jacobian of the end-effector

dJ_LOWCOM = subs( dJ_LOWCOM, diff( q,t ), dq );
dJ_LOWCOM = simplify( dJ_LOWCOM );

% For the Jacobian
syms q1 q2 q3 q4
JEE_CV      = subs( JEE, q, [q1,q2,q3,q4] );
J_LOWCOM_CV = subs( J_LOWCOM, q, [q1,q2,q3,q4] );
J_UPCOM_CV  = subs( J_UPCOM,  q, [q1,q2,q3,q4] );

%% 

% [FOR CONTROLLER]
% changing the equation for cpp file

dJEEMat = arrayfun(@char, dJEE, 'uniform', 0);

oldS = {'q1(t)','q2(t)','q3(t)','q4(t)', 'dq1(t)','dq2(t)','dq3(t)','dq4(t)'};
newS = { 'q[0]', 'q[1]', 'q[2]', 'q[3]',  'dq[0]', 'dq[1]', 'dq[2]', 'dq[3]'};


tmp = dJEEMat;
for i = 1 : length(oldS)
    tmp = strrep( tmp, oldS{i}, newS{i} );
end
     


% [DEBUG] Checking whether the Jacobian is correct
% vpa( subs( JEE, {L1, L2, q1, q2, q3, q4}, {0.294, 0.291, 2.25545  , 0.3, 0.0, 0.452556 }) )
vpa( subs( R01*R12*R23*R34, {L1, L2, q1, q2, q3, q4}, {0.294, 0.291, 2.25545  , 0.3, 0.0, 0.452556 }) )

% Since we know JEE, we can calculate vEE, based on dq vector!

%% (1D) Defining the SE(3) matrix for Each Limbs Center of Mass,  forward kinematics + Jacobian.

gC1 = T01 * T12 * T23 * [eye(3,3),[0;0;-Lc1]; 0,0,0,1];             % Position of the center of mass of the  first limb (numbered from proximal to distal limb)
xC1 = gC1(1:3,4);                                                   % Extracting the elements of position of the center of mass

gC2 = T01 * T12 * T23 * T34 * [eye(3,3),[0;0;-Lc2]; 0,0,0,1];       % Position of the center of mass of the  first limb (numbered from proximal to distal limb)
xC2 = gC2(1:3,4);                                                   % Extracting the elements of position of the center of mass

dxC1 = diff( xC1, t );                                              % Time differentiation of position of C.O.M 1
dxC2 = diff( xC2, t );                                              % Time differentiation of position of C.O.M 2

dxC1 = subs( dxC1, diff( q,t ), dq );                               % Substituting all diff( q,t ) to dq's
dxC2 = subs( dxC2, diff( q,t ), dq );                               % Substituting all diff( q,t ) to dq's

JC1 = myJacobian(dxC1, dq);
JC2 = myJacobian(dxC2, dq);

% [DEBUG] Checking whether the Jacobian is correct
% vpa( subs( JC1, {L1, L2, Lc1, Lc2, q1, q2, q3, q4}, {0.294, 0.291, 0.108, 0.112, -0.460594 , -0.271257 , -1.117405 , -0.347297 }) )
% vpa( subs( JC2, {L1, L2, Lc1, Lc2, q1, q2, q3, q4}, {0.294, 0.291, 0.108, 0.112, -0.460594 , -0.271257 , -1.117405 , -0.347297 }) )



%% (1E) Finding the generalized mass matrix, which is crucial for calculating the 
% [REF] https://www.cds.caltech.edu/~murray/books/MLS/pdf/mls94-manipdyn_v1_2.pdf

                                                        % The body velocity is determined by the following equation:
                                                        % inv(T) * d(T)
                                                        % Defining (temporarily) the zeta1 and zeta2 as the 4by4 matrix
zeta1 = simplify( inv( gC1 ) * diff( gC1, t ) );        % For limb #1 Center of Mass
zeta2 = simplify( inv( gC2 ) * diff( gC2, t ) );        % For limb #2 Center of Mass

                                                        % The result of zeta will be [[w], v; 0,0,0,1] shape matrix
    
wb1 = [ -zeta1(2,3), zeta1(1,3), -zeta1(1,2) ];         % Angular velocity of body #1
wb2 = [ -zeta2(2,3), zeta2(1,3), -zeta2(1,2) ];         % Angular velocity of body #2

vb1 = zeta1(1:3, 4);                                    % Body    velocity of body #1
vb2 = zeta2(1:3, 4);                                    % Body    velocity of body #2

Rsc1 = gC1(1:3, 1:3);                                   % Rotational Matrix, 3-by-3, from center-of-mass #1 to spatial 
Rsc2 = gC2(1:3, 1:3);                                   % Rotational Matrix, 3-by-3, from center-of-mass #1 to spatial 

vs1 = Rsc1 * vb1;                                       % Spacial Velocity of body #1
vs2 = Rsc2 * vb2;                                       % Spacial Velocity of body #2 


vb1 = subs( vb1, diff( q,t ), dq );
vb2 = subs( vb2, diff( q,t ), dq );
vs1 = subs( vs1, diff( q,t ), dq );
vs2 = subs( vs2, diff( q,t ), dq );
wb1 = subs( wb1, diff( q,t ), dq );
wb2 = subs( wb2, diff( q,t ), dq );

M1 = diag([m1, m1, m1, I1]);
M2 = diag([m2, m2, m2, I2]);

JBody1 = myBodyJacobian( wb1, vb1, dq );
JBody2 = myBodyJacobian( wb2, vb2, dq );

M1_G = simplify( TJac(JBody1) * M1 * JBody1 );
M2_G = simplify( TJac(JBody2) * M2 * JBody2 );

M_G = simplify( M1_G + M2_G );


%% (1F) Culmination of the Code: Finding the Manipulator Equation.
% Lagrangian of the upper limb is as following
% 1/2 * dq * M * dq + V(q)

% Calculating the potential energy V is easy
V = m1 * g * xC1(3) + m2 * g * xC2(3);

% For finding Mq'' + Cq' + N(q) = tau,
% [REF] https://www.cds.caltech.edu/~murray/books/MLS/pdf/mls94-manipdyn_v1_2.pdf

% First, M is already known, which is M_G
% M_G should be positive-symmetric matrix.

% N matrix (or vector) can be derived simply by the position derivative of V

N = sym( 'N', [ 1, length(q) ]);
for i = 1 : length(q)
   N(i) = functionalDerivative( V, q(i) );
end

% C matrix is determined by the Christoffel symbols:
C = sym( 'C', [ length(q), length(q) ]);

for i = 1 : length(q)
    for j = 1 : length(q)
            tmp = 0;
        for k = 1 : length(q)
            tmp1 =   1 / 2 * functionalDerivative( M_G(i,j), q(k) ) ...
                   + 1 / 2 * functionalDerivative( M_G(i,k), q(j) ) ...
                   - 1 / 2 * functionalDerivative( M_G(k,j), q(i) );
            tmp1 = tmp1 * dq(k);
            tmp  = tmp + tmp1;
        end
            C(i,j) = tmp;
    end
end

C = simplify(C);

%% (1G) Inverse Kinematics for the End-Effector
syms q1 q2 q3 q4
tmppEE = subs(   pEE, {L1, L2}, {0.294, 0.291}) ;
tmppEE = subs(tmppEE,  q, {q1, q2, q3, q4}) ;
tmppEE = tmppEE(1:3);
pos = [0.35, 0.0, 0.45]; % The position of the end point.

fun = (tmppEE(1) - pos(1))^2 + (tmppEE(2) - pos(2))^2 + (tmppEE(3) - pos(3))^2;
x0 = [0,0,0,0];
mySol = vpasolve([tmppEE(1) == pos(1), tmppEE(2) == pos(2), tmppEE(3) == pos(3) ], [q1, q2, q3, q4] );

q1s = rem( double( mySol.q1 ), 2*pi );
q2s = rem( double( mySol.q2 ), 2*pi );
q3s = rem( double( mySol.q3 ), 2*pi );
q4s = rem( double( mySol.q4 ), 2*pi );

vpa( subs( pEE, {L1, L2, Lc1, Lc2, q1, q2, q3, q4}, {0.294, 0.291, 0.108, 0.112, q1s, q2s, q3s, q4s }) )

%% (2A) Derivation of the N+2 DOF planar whip model.

syms t positive                                                            % time               variable - independent variable.
syms   q1(t)   q2(t)   q3(t)   q4(t)                                       % joint angle        variable -   dependent variable.
syms  dq1(t)  dq2(t)  dq3(t)  dq4(t)                                       % joint velocity     variable -   dependent variable.
syms ddq1(t) ddq2(t) ddq3(t) ddq4(t)                                       % joint acceelration variable -   dependent variable.

syms L1 L2 Lc1 Lc2 m1 m2 positive                                          %  L: Length of each limb segments
syms Ixx1 Ixx2 Iyy1 Iyy2 Izz1 Izz2 positive                                %  I: Prinxiple inertia of each limb                                                 
syms lw mw kw bw

N  = 10;                                                                   % Number of node of the whip model                                         
  qw = arrayfun( @( N ) str2sym( sprintf(  'qw%d(t)', N ) ), 1 : N ).';    % Ang.     Position array of the whip model 
 dqw = arrayfun( @( N ) str2sym( sprintf( 'dqw%d(t)', N ) ), 1 : N ).';    % Ang.     Velocity array of the whip model 
ddqw = arrayfun( @( N ) str2sym( sprintf('ddqw%d(t)', N ) ), 1 : N ).';    % Ang. Acceleration array of the whip model 
