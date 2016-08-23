classdef UniformFlow < poUnitTest.TestCaseParamDomain
%poUnitTest.UniformFlow checks the uniform flow potential.

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
    strength = 2
    angle = pi/4
    scale = 1/2
end

methods
    function [m, chi, b] = getParameters(test)
        m = test.strength;
        chi = test.angle;
        b = test.scale;
    end
    
    function checkValues(test)
        [m, chi, b] = getParameters(test);
        W = potential(test.domainObject, uniformFlow(m, chi, b));
        ref = test.generateReference(m, chi, b);
        test.checkAtTestPoints(ref, W)        
    end
    
    function checkDerivative(test)
        [m, chi, b] = getParameters(test);
        W = potential(test.domainObject, uniformFlow(m, chi, b));
        dW = diff(W);
        ref = poUnitTest.FiniteDifference(@(z) W(z));
        test.checkAtTestPoints(ref, dW)
    end
    
    function ref = generateReference(test, m, chi, b)
        import poUnitTest.domainType
        switch test.type
            case domainType.Entire
                ref = @(z) m*z*exp(-1i*chi);
                
            case domainType.Simple
                ref = @(z) m*b*(exp(1i*chi)*z + exp(-1i*chi)./z);
                
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
