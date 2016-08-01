classdef UniformFlow < poUnitTest.ParameterizedTestCase
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
    scale = 2
end

methods(Test)
    function checkFlow(test)
        test.dispatchTestMethod('Flow')
    end
end

methods
    function entireFlow(test)
        test.diagnosticMessage = 'Submitted bug as issue #59.';
        test.analyticCheck()
    end
    
    function simpleFlow(test)
        test.analyticCheck()
    end
    
    function annulusFlow(test)
        test.analyticCheck()
    end
    
    function analyticCheck(test)
        m = test.strength;
        chi = test.angle;
        b = test.scale;
        
        uf = uniformFlow(m, chi, b);
        W = potential(test.domainObject, uf);
        ref = test.generateReference(m, chi, b);
        
        test.checkAtTestPoints(ref, W)
    end
    
    function ref = generateReference(test, m, chi, b)
        label = test.domainTestObject.label;
        switch label
            case 'entire'
                ref = @(z) m*b*z*exp(-1i*chi);
                
            case 'simple'
                ref = @(z) m*b*(exp(-1i*chi)*z + exp(1i*chi)./z);
                
            case 'annulus'
                test.assertFail(...
                    'Formula needed. Submitted as issue #62.')
                
            otherwise
                test.assumeFail(...
                    sprintf('Case %s not implemented yet.', label))
        end
    end
end

end
