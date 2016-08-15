classdef circleIntegral
%poUnitTest.circleIntegral encapsulates integrating around a circle.

% Everett Kropf, 2016
% 
% This file is part of the Potential Toolkit (PoTk).
% 
% PoTk is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% PoTk is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with PoTk.  If not, see <http://www.gnu.org/licenses/>.

properties(Constant)
    defaultCollocationPoints = 128
end

methods(Static)
    function I = forDifferential(df, c, r, N)
        if nargin < 4
            N = poUnitTest.circleIntegral.defaultCollocationPoints;
        end
        
        dt = 2*pi/N;
        reit = r*exp(1i*(0:N-1)'*dt);
        I = 1i*dt*sum(df(c + reit).*reit);
    end
end

end
