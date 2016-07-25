classdef PFunctionCheck < matlab.unittest.TestCase
%poUnitTest.PFunctionCheck checks the P-function accuracy.

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
    radius = 0.1
    alpha = -0.6
    testPoints = [
        -0.017493+0.4828i
        0.45131+0.2309i
        0.41633-0.4828i
        -0.43732-0.43382i]
    
    tolerance = 1e-15
end

methods(Test)
    function valueVsPrime(test)
        q = test.radius;
        a = test.alpha;
        zp = test.testPoints;
        
        w = skprime(a, 0, q);
        [P, C] = poUnitTest.PFunction(q);
        C = -1/C^2;
        
        error = w(zp) - a*C*P(zp/a);
        test.verifyLessThan(max(abs(error)), 1e-14)
    end
end

end
