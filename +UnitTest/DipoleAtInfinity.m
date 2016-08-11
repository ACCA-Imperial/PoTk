classdef DipoleAtInfinity < UnitTest.TestCase
%UnitTest.DipoleAtInfinity tests the dipole at infinity in the entire
%domain case.

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
    domainTestObject = UnitTest.domainEntire()
    strength = 2
    angle = pi/4
end

methods(Test)
    function checkValue(test)
        loc = inf;
        m = test.strength;
        chi = test.angle;
        
        d = dipole(loc, m, chi);
        W = potential(test.domainObject, d);
        ref = @(z) m*z/2/pi*exp(-1i*chi);
        
        test.diagnosticMessage = 'Bug submitted as issue #50.';
        test.checkAtTestPoints(ref, W);
    end
    
    function verifyBoundedError(test)
        d = dipole(inf, 1, 0);
        D = UnitTest.domainSimple().domainObject;
        test.verifyError(@() potential(D, d), ...
            PoTk.ErrorIdString.RuntimeError)
    end
end

end
