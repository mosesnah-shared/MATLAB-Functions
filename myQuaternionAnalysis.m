psi   = sym('psi'   , 'real' );
theta = sym('theta' , 'real' );
phi   = sym('phi'   , 'real' );

Rx = [ cos(phi/2), sin(phi/2), 0, 0 ];
Ry = [ cos(theta/2), 0, sin(theta/2), 0 ];
Rz = [ cos(psi/2), 0, 0, sin(psi/2) ];

Q12 = quatmultiply( Rz, Ry)

myans = quatmultiply( Q12, Rx )


%%
Rx = [ cos(-phi/2), sin(-phi/2), 0, 0 ];
Ry = [ cos(-theta/2), 0, sin(-theta/2), 0 ];
Rz = [ cos(psi/2), 0, 0, sin(psi/2) ];

wa = quatmultiply( Ry, Rx )

myans = quatmultiply( wa, Rz )

syms x y z real

t1 = subs( myans, [theta, phi, psi],  [2.319174374318415, -0.2657430032209951, 1.465919388064663]  )
t2 = subs( myans, [theta, phi, psi],  [y,x,z]  )

vpa( t1 )

% >> simplify( 1- ( t2(2)^2 + t2(3)^2 )*2 )
% cos(x)*cos(y)
% 
% simplify( t2(1)*t2(2) - t2(3)*t2(4) )
% -sin(x)/2
% 
% >> simplify( t2(2)*t2(3) + t2(1)*t2(4) ) 
% (cos(x)*sin(z))/2
% 
% >> simplify( t2(2)*t2(4) + t2(1)*t2(3) )
% -(cos(x)*sin(y))/2
% 
% simplify( t2(2)*t2(3) + t2(4)*t2(1) )
% (cos(x)*sin(z))/2
% % 
% >> simplify( 1- ( t2(2)^2 + t2(4)^2 )*2 )
% cos(x)*cos(z)




