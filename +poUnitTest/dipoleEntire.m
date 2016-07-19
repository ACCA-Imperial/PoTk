classdef dipoleEntire < poUnitTest.entireTests
%poUnitTest.dipoleEntire checks the dipole in the entire plane domain.

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

properties
    location = 0
    strength = 2
    angle = pi/4
end

methods(Test)
    function checkFinite(test)
        loc = test.location;
        m = test.strength;
        chi = test.angle;
        d = dipole(loc, m, chi);
        W = potential(planeDomain, d);
        ref = @(z) m./(z - loc)/2/pi*exp(1i*chi);
        test.checkAtTestPoints(ref, W)
    end
    
    function checkInfinite(test)
        loc = inf;
        m = test.strength;
        chi = test.angle;
        d = dipole(loc, m, chi);
        W = potential(planeDomain, d);
        ref = @(z) m*z/2/pi*exp(-1i*chi);
        test.checkAtTestPoints(ref, W);
    end
end

end
