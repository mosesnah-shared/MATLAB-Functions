classdef myBarPlot < handle
% % =============================================================== %
%   [DESCRIPTION]
%
%       Drawing 2D Bar plot for showing where the optimal movement parameters reside
%
% Construct an instance of the marker class
% [Inputs Arguments]
%      (1) x,y,z: The 1-by-N row vectors, x, y and z position where the vector is pointing w.r.t. the origin
%         
%      (2) orig: Origin of the vector. 3-by-N, Note that the x, y and z given is w.r.t the origin!
%       
% % =============================================================== %
%   [CREATED BY]  Moses Nah
%   [EMAIL]       mosesnah@mit.edu
%   [AFFILIATION] Massachusetts Institute of Technology (MIT)
%   [MADE AT]     08-June-2020    
% % =============================================================== %
    properties ( SetAccess = private )
   

    end

    properties ( SetAccess = public )
       lb;
       ub;
        p;
    end
    
    methods

        function obj = myBarPlot( p, lb, ub, varargin )
            obj.p  =  p; 
            obj.lb = lb; 
            obj.ub = ub;   
        end
        
        function plot( obj )
            
            
        end

    end
    
end
    