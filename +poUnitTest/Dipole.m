classdef Dipole < poUnitTest.TestCaseParamDomain
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

properties(ClassSetupParameter)
    domain = poUnitTest.domainParameterStructure.defaults
end

properties
    entireLocation = 0
    simpleLocation = 0
    annulusLocation = -0.6
    strength = 2
    angle = pi/4
    scale = 2
end

methods(Test)
    function checkFinite(test)
        test.checkValues()
    end
    
    function checkFiniteDz(test)
        test.checkDerivative()
    end
end

methods
    function [loc, m, chi, b] = getParameters(test)
        loc = test.dispatchTestProperty('Location');
        m = test.strength;
        chi = test.angle;
        b = test.scale;
    end
    
    function checkValues(test)
        [loc, m, chi, b] = test.getParameters();
        d = dipole(loc, m, chi, b);
        W = potential(test.domainObject, d);
        ref = test.generateReference(loc, m, chi, b);
        test.checkAtTestPoints(ref, W)        
    end
    
    function checkDerivative(test)
        [loc, m, chi, b] = test.getParameters();
        W = potential(test.domainObject, dipole(loc, m, chi, b));
        dW = diff(W);
        ref = poUnitTest.FiniteDifference(@(z) W(z));
        test.checkAtTestPoints(ref, dW);
    end
    
    function ref = generateReference(test, loc, m, chi, b)
        import poUnitTest.domainType
        switch test.type
            case domainType.Entire
                ref = @(z) m./(z - loc)/2/pi*exp(1i*chi);
                
            case domainType.Simple
                ref = @(z) m*b*(exp(-1i*chi)*(z - loc) ...
                    + exp(1i*chi)./(z - loc));
                
            case domainType.Annulus
                test.assertFail(...
                    'Formula needed. Submitted as issue #62.')
                
            otherwise
                test.assumeFail(...
                    sprintf('Case %s not implemented yet.', label(test.type)))
        end
    end
end

end
