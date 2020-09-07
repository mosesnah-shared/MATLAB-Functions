function cOut = myColorGradient( c1, c2, step, varargin )
% % =============================================================== %
%   [DESCRIPTION]
%
%       Color Gradient 
%
%
% % =============================================================== %
%   [CREATED BY]  Moses Nah
%   [EMAIL]       mosesnah@mit.edu
%   [AFFILIATION] Massachusetts Institute of Technology (MIT)
%   [MADE AT]     08-June-2020    
% % =============================================================== %

if nargin == 4
     type = varargin{ 1 };
     
elseif nargin == 3 
     type = "linear";
     
elseif nargin >= 5
     error( 'Wrong input, maximum input should be more than 4' ); 
     
end


%determine increment step for each color channel.
if type == "linear"
    dr = linspace( c1( 1 ), c2( 1 ), step );
    dg = linspace( c1( 2 ), c2( 2 ), step );
    db = linspace( c1( 3 ), c2( 3 ), step );
    
elseif type == "exponential"
    dr = exp( linspace( log( c1( 1 ) ), log( c2( 1 ) ), step ) );
    dg = exp( linspace( log( c1( 2 ) ), log( c2( 2 ) ), step ) );
    db = exp( linspace( log( c1( 3 ) ), log( c2( 3 ) ), step ) );

end

cOut = [dr', dg', db'];

end

