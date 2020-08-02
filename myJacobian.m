function JEE = myJacobian( dx, dq )

    JEE = sym('JEE',[length(dx), length(dq)]);

    for i = 1 : length(dx)                                                 % Iterating along each x,y,z component
        for j = 1 : length(dq)                                             % Iterating along each joint number

            [tmpc,tmpt] = coeffs( dx(i), dq(j) );                          % Extracting all the coefficients and its corresponding terms

            % IF the coefficients (tmpc) corresponding to dq(3) is empty, put zero
            if( isempty( tmpc( tmpt == dq(j) ) ) )
                JEE(i,j) = 0; 
            else    
                JEE(i,j) = tmpc( tmpt == dq(j) );
            end

        end
    end

end

