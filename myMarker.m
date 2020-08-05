classdef myMarker < handle
% % =============================================================== %
%   [DESCRIPTION]
%
%       myMarker class for defining a single marker in the plot
%
%
% % =============================================================== %
%   [CREATED BY]  Moses Nah
%   [EMAIL]       mosesnah@mit.edu
%   [AFFILIATION] Massachusetts Institute of Technology (MIT)
%   [MADE AT]     08-June-2020    
% % =============================================================== %
    
    properties ( SetAccess = private )
        % [1] Interal Function to check the size
        isSizeSame = @( x,y,z ) ( ( length( x ) == length( y ) ) && ...
                                    length( x ) == length( z ) );          

    end


    properties ( SetAccess = public )
        name
        xdata
        ydata
        zdata
        N
        color
        size
        style
    end
    
    methods

        function obj = myMarker( xdata, ydata, zdata, varargin )
            % Construct an instance of the marker class
            % [Inputs Arguments]
            %       xdata: The x cartesian position data, 1 x N row vector
            %       ydata: The y cartesian position data, 1 x N row vector
            %       zdata: The z cartesian position data, 1 x N row vector
            
            if ( ~obj.isSizeSame( xdata, ydata, zdata ) )
                error( "Wrong size, x: %d, y: %d, z:%d ", length( xdata ), length( ydata ), length( zdata ) ) 
            end

            obj.xdata = xdata;
            obj.ydata = ydata; 
            obj.zdata = zdata;
            obj.N     = length( xdata );

            % Parsing the arguments
            r = myParser( varargin );                
            obj.name  = r.name;
            obj.size  = r.markerSize;
            obj.style = r.markerStyle;
            obj.color = r.markerColor;
            
        end
        

    end
end
