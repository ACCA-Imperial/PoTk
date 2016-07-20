classdef Dipole < poUnitTest.TestCase
%poUnitTest.Dipole checks the dipole potential.

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
    entireLocation = 0
    simpleLocation = 0
    strength = 2
    angle = pi/4
    scale = 2
end

methods(Test)
    function checkFinite(test)
        test.dispatchTestMethod('finite')
    end
    
    function checkInfinite(test)
        test.dispatchTestMethod('infinite')
    end
end

methods
    function entireFinite(test)
        loc = test.entireLocation;
        m = test.strength;
        chi = test.angle;
        
        d = dipole(loc, m, chi);
        W = potential(test.domainObject, d);
        ref = @(z) m./(z - loc)/2/pi*exp(1i*chi);
        
        test.checkAtTestPoints(ref, W);
    end
    
    function entireInfinite(test)
        loc = inf;
        m = test.strength;
        chi = test.angle;
        
        d = dipole(loc, m, chi);
        W = potential(test.domainObject, d);
        ref = @(z) m*z/2/pi*exp(-1i*chi);
        
        test.diagnosticMessage = 'Bug submitted as issue #50.';
        test.checkAtTestPoints(ref, W);
    end
    
    function simpleFinite(test)
        loc = test.simpleLocation;
        m = test.strength;
        chi = test.angle;
        b = test.scale;
        
        d = dipole(loc, m, chi, b);
        W = potential(test.domainObject, d);
        ref = @(z) m*b*(exp(-1i*chi)*z + exp(1i*chi)./z);
        
        test.checkAtTestPoints(ref, W);
    end
    
    function simpleInfinite(test)
        d = dipole(inf, 1, 0);
        test.verifyError(...
            @() potential(test.domainObject, d), ...
            PoTk.ErrorIdString.RuntimeError)
    end
end

end
