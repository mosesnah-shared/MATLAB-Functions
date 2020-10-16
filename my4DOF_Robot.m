classdef my4DOF_Robot < handle 
% % =============================================================== %
%   [DESCRIPTION]
%       my4DOF_Robot class, 
%       3-DOF exists in the shoulder and 1-DOF on the elbow. 
%
% % =============================================================== %
%   [CREATED BY]  Moses Nah
%   [EMAIL]       mosesnah@mit.edu
%   [AFFILIATION] Massachusetts Institute of Technology (MIT)
%   [MADE AT]     08-October-2020    
% % =============================================================== %


% % =============================================================== %
% [START] 
    
    properties ( SetAccess = private )
     
    end
    
    properties ( SetAccess = public )
        l1 
        l2    
        q       % The 4-DOF angle array, 4-by-N size
    end        
    
    methods
        
        function obj = my4DOF_Robot( l, varargin )
            % ================================================================ %
            % [Syntax]
            % (1) l (array, size 2)
            %     - l = [l1, l2], the length of the 4DOF-Robot
            %     - The robot consists of 2 limb segments. 
            % (2) varargin
            %     - Further arguments that will be given.
            % ================================================================ %
            
            if length( l ) ~= 2
                error( 'The input size of length should be 2, but %d is given', length( l ) )
            end
            
            obj.l1 = l( 1 );    obj.l2 = l( 1 );
        end
        
        function [pSH, pEL, pEE] = forwardKinematics( obj, q, varagin )
            % ================================================================ %
            % [Input]
            % (1) q (array, size 4-by-N)
            %     - The angle array which will calculate the forward kinematics information 
            % (2) varargin
            %     - Further arguments that will be given.
            %
            % [Output]            
            % (1) pSH (array, size 3-by-N)
            %     - The xyz position array of the shoulder, it will be at origin (0,0,0) for this class.
            % (2) pEL (array, size 3-by-N)
            %     - The xyz position array of the elbow.
            % (3) pEE (array, size 3-by-N)            
            %     - The xyz position array of the end-effector, or wrist.
            % ================================================================ %            
           
            if size( q, 1 ) ~= 4
                error( 'The number of rows of matrix q should be 4, but %d is given', size( q, 1 ) )
            end            
            
            pSH = zeros( 3, size( q, 2 ) );                                % The position of the     Shoulder (SH) is always fixed at origin.
            pEL = zeros( 3, size( q, 2 ) );                                % The position of the        Elbow (EL) 
            pEE = zeros( 3, size( q, 2 ) );                                % The position of the End-Effector (EE) 
            
            % se(3) [R,p,0,1] matrix definition
            T01 = @( q ) [ roty( -q( 1 ) ), [ 0; 0;       0 ]; 0,0,0,1 ];  % From 0->1
            T12 = @( q ) [ rotx( -q( 2 ) ), [ 0; 0;       0 ]; 0,0,0,1 ];  % From 1->2                 
            T23 = @( q ) [ rotz(  q( 3 ) ), [ 0; 0;       0 ]; 0,0,0,1 ];  % From 2->3             
            T34 = @( q ) [ roty( -q( 4 ) ), [ 0; 0; -obj.l1 ]; 0,0,0,1 ];  % From 3->4 
            
            % se(3) matrix from origin to lower-limb frame. 
            % In other words, T04 is multiplied by a vector, which is represented in lower-limb frame
            T04 = @( q ) T01( q ) * T12( q ) * T23( q ) * T34( q );
            
            p_EL_func = @( q ) T04( q ) * [ 0; 0;       0; 1 ];
            p_EE_func = @( q ) T04( q ) * [ 0; 0; -obj.l2; 1 ];

            for i = 1 : size( q, 2 )
                tmp = p_EL_func( q( :,i ) ); pEL( :, i ) = tmp( 1:3 );
                tmp = p_EE_func( q( :,i ) ); pEE( :, i ) = tmp( 1:3 );
            end
            
            
        end
    end
end

