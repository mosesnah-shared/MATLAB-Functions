classdef mySubmovement < handle
%  mySubmovements class for discrete movement primitives. 
% 
% % =============================================================== %
%   [DESCRIPTION]
%
%
% % =============================================================== %
%   [CREATED BY]  Moses Nah
%   [EMAIL]       mosesnah@mit.edu
%   [AFFILIATION] Massachusetts Institute of Technology (MIT)
%   [MADE AT]     16-October-2020    
% % =============================================================== %
% 
% 
% % =============================================================== %
    properties ( SetAccess = private )
   

    end

    properties ( SetAccess = public )
        pi;        % Initial Posture.
        pf;        % Final   Posture.
        D;         % Duration it took from start to end. 
        func_p;    % Function handle for the position of the submovement
        func_v;    % Function handle for the velocity of the submovement
        
        p_vec; v_vec; t_vec;
    end
    
    methods
        function obj = mySubmovement( mov_pars ) 
            %[CONSTRUCTOR #1] Construct an instance of this class
            %   (1) mov_pars [-]
            %       -  The array of movement parameters of the submovement
            %       -  In order, variables correspond to p_i (1), p_f (2) and D (3)
            %
            % [Quick Sanity Check] Check the size of mov_pars
            if length( mov_pars ) ~= 3
               error( "Wrong size of input, 3 should be given but %d is passed" )
            end
        
            obj.pi = mov_pars( 1 );
            obj.pf = mov_pars( 2 );
            obj.D  = mov_pars( 3 );
            
            % Generating the submovement function w.r.t time (t) as a function handle.
            obj.func_p = @( t )    obj.pi + ( obj.pf - obj.pi ) * ( 10 * ( t / obj.D ).^3 - 15 * ( t / obj.D ).^4 +  6 * ( t / obj.D ).^5  );
            obj.func_v = @( t ) 1 / obj.D * ( obj.pf - obj.pi ) * ( 30 * ( t / obj.D ).^2 - 60 * ( t / obj.D ).^3 + 30 * ( t / obj.D ).^4  );
        end
        
        function [ p_vec, v_vec, t_vec ] = data_arr( obj, dt, toff, T )
            % Generating the position + velocity array, which will be useful for plot
            % ============================================================
            % [INPUT]
            % ============================================================
            %   (1) dt   [sec]
            %       -  Time step of the vector. 
            %   (2) toff [sec]
            %       -  Time offset of the submovement plot. 
            %   (2) T    [sec]
            %       -  The total time of the time array
            % ============================================================            
            % [OUTPUT]            
            % ============================================================
            %   (1) p_vec [pos]
            %       -  Position vector of the submovement
            %   (2) v_vec [pos/s]
            %       -  Velocity vector of the submovement
            %   (3) t_vec [s]
            %       -  Time vector
            if T < toff + obj.D
               error( "The value of 3rd input (T) [%f], should be greater than the sum of the previous two [%f]", T, toff + obj.D );
            end            
            
            obj.t_vec = 0 : dt : T;                                        % Generating the time vector arra
            obj.p_vec = zeros( 1, length( obj.t_vec  ) );
            obj.v_vec = zeros( 1, length( obj.t_vec  ) );
            
            % Defining an array which will fill-up the p_vec and v_vec 
            tmp_p = obj.func_p( 0 : dt : obj.D );
            tmp_v = obj.func_v( 0 : dt : obj.D );
            
            idxS = floor( toff/dt ) + 1;
            idxE = idxS + length( tmp_p ) - 1;
            
            obj.v_vec( idxS : idxE ) = tmp_v; 
            
            obj.p_vec(        1 : idxS-1 ) = obj.pi;
            obj.p_vec(     idxS : idxE   ) =  tmp_p;
            obj.p_vec( idxE + 1 : end    ) = obj.pf;
            
            p_vec = obj.p_vec;
            v_vec = obj.v_vec;
            t_vec = obj.t_vec; 
            
        end
    end
    
end