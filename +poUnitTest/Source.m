classdef Source < poUnitTest.ParameterizedTestCase
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
    simpleLocation = 0.15761+0.80028i
    annulusLocation = -0.16443+0.49679i
    
    strength = 2
end

methods(Test)
    function checkPoint(test)
        test.dispatchTestMethod('point')
    end
end

methods
    function entirePoint(test)
        test.checkEval(test.entireLocation);
    end
    
    function simplePoint(test)
        test.diagnosticMessage = 'Bug submitted as issue #58.';
        test.checkEval(test.simpleLocation);
    end
    
    function annulusPoint(test)
        test.checkEval(test.annulusLocation);
    end
    
    function checkEval(test, a)
        m = test.strength;
        S = source(a, m);
        W = potential(test.domainObject, S);
        ref = test.generateEvalReference(a, m);
        test.checkAtTestPoints(ref, W)
    end
    
    function ref = generateEvalReference(test, a, m)
        label = test.domainTestObject.label;
        switch label
            case 'entire'
                ref = @(z) m*log(z - a)/2/pi;
                
            case 'simple'
                pf = @(z,a) z - a;
                o = test.domainObject.infImage;
                ref = test.primeFormReferenceFunction(pf, a, o, m);
                
            case 'annulus'
                pf = test.primeFunctionReferenceForDomain;
                o = test.domainObject.infImage;
                ref = test.primeFormReferenceFunction(pf, a, o, m);
                
            otherwise
                test.assumeFail(...
                    sprintf('Case %s not implemented.', label))
        end
    end
end

methods(Static)
    function ref = primeFormReferenceFunction(pf, a, o, m)
        ref = @(z) m*log(pf(z, a).*pf(z, 1/conj(a)) ...
            ./pf(z, o)./pf(z, 1/conj(o)))/2/pi;
    end
end

end
