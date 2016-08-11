classdef Source < poUnitTest.TestCaseParamDomain
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

properties(ClassSetupParameter)
    domain = poUnitTest.domainParameterStructure.defaults
end

properties
    entireLocation = 0.95751+0.95717i
    simpleLocation = 0.15761+0.80028i
    annulusLocation = -0.16443+0.49679i
    conn3Location = 0.31137+0.11195i
    
    strength = 2
end

methods(Test)
    function checkPoint(test)
        switch test.type
            case poUnitTest.domainType.Simple
                test.diagnosticMessage = 'Bug submitted as issue #58.';
        end
        test.checkValues()
    end
    
    function checkPointDz(test)
        if test.type == poUnitTest.domainType.Simple
            test.diagnosticMessage = 'Bug submitted as issue #66.';
        end
        test.checkDerivative()
    end
end

methods
    function [a, m] = getProperties(test)
        a = test.dispatchTestProperty('Location');
        m = test.strength;
    end
    
    function checkValues(test)
        [a, m] = test.getProperties();
        W = potential(test.domainObject, source(a, m));
        ref = test.generateEvalReference(a, m);
        test.checkAtTestPoints(ref, W)
    end
    
    function checkDerivative(test)
        [a, m] = test.getProperties();
        W = potential(test.domainObject, source(a, m));
        dW = diff(W);
        ref = poUnitTest.FiniteDifference(@(z) W(z));
        test.checkAtTestPoints(ref, dW)
    end
    
    function ref = generateEvalReference(test, a, m)
        switch test.type
            case poUnitTest.domainType.Entire
                ref = @(z) m*log(z - a)/2/pi;
                
            otherwise
                pf = test.primeFunctionReferenceForDomain;
                o = test.domainObject.infImage;
                ref = test.primeFormReferenceFunction(pf, a, o, m);
        end
    end
end

methods(Static)
    function ref = primeFormReferenceFunction(pf, a, o, m)
        rfun = @(z) m*log(pf(z, a).*pf(z, 1/conj(a)) ...
            ./pf(z, o)./pf(z, 1/conj(o)))/2/pi;
        ref = poUnitTest.ReferenceFunction(rfun);
        if isa(pf, 'poUnitTest.PrimeFunctionReference')
            ref.tolerance = pf.tolerance;
        end
    end
end

end
