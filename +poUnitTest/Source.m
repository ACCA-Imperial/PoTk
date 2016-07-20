classdef Source < poUnitTest.TestCase
%poUnitTest.Source checks the source point potential.

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
    entireLocation = 0.95751+0.95717i
    
    strength = 2
end

methods(Test)
    function checkPoint(test)
        test.dispatchTestMethod('point')
    end
end

methods
    function entirePoint(test)
        a = test.entireLocation;
        m = test.strength;
        S = source(a, m);
        W = potential(test.domainObject, S);
        
        ref = @(z) m*log(z - a)/2/pi;
        
        test.checkAtTestPoints(ref, W);
    end
end

end
