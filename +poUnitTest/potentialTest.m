classdef potentialTest < matlab.unittest.TestCase
%potentialTest test suite for potential.

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
    dv3 = [-0.2517+0.3129i, 0.2307-0.4667i];
    qv3 = [0.2377, 0.1557];
end

% methods(TestClassSetup)
% end

methods(Test)
    function noPotential(test)
        W = potential(unitDomain(test.dv3, test.qv3));
        test.verifyEqual(W(0.5+0.1i), complex(0))
    end
end

end
