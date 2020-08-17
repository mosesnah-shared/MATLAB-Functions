function [flipped_data, tmpx] = myFlipFlop( data, thres )
% FlipFloping the data w.r.t. the data threshold.

%     tmp  = ischange( data, 'mean', 'Threshold', thres );                   % Find the index, tmp
%     pts = findchangepts( data, 'Statistic', 'linear', 'MinThreshold', thres );
     findchangepts( data, 'Statistic', 'linear', 'MinThreshold', thres );
    j    = 1;
    
    tmpx = zeros( 1, length( data ) );
    
    for i = 1 : length( data )

       if any( i == pts )
           j = -j;  % Flip-Flop
       end
       tmpx( i ) = j;         
    end
    
    flipped_data = data .* tmpx;

end

