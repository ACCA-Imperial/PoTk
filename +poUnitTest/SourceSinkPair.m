classdef SourceSinkPair < poUnitTest.TestCaseParamDomain
%poUnitTest.SourceSinkPair checks the source/sink pair potential.

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
    conn3Location = 0.59825+0.2379i
    
    strength = 2
end

methods(Test)
    function checkPair(test)
        test.checkValues()
    end
    
    function checkPairDz(test)
        test.checkDerivative()
    end
end

methods
    function [a, o, m] = getProperties(test)
        a = test.dispatchTestProperty('Location');
        o = -a;
        m = test.strength;
    end
    
    function checkValues(test)
        [a, o, m] = getProperties(test);
        W = potential(test.domainObject, sourceSinkPair(a, o, m));
        ref = test.generateEvalReference(a, o, m);
        test.checkAtTestPoints(ref, W)
    end
    
    function checkDerivative(test)
        [a, o, m] = getProperties(test);
        W = potential(test.domainObject, sourceSinkPair(a, o, m));
        dW = diff(W);
        ref = poUnitTest.FiniteDifference(@(z) W(z));
        test.checkAtTestPoints(ref, dW);
    end
    
    function ref = generateEvalReference(test, a, o, m)
        switch test.type
            case poUnitTest.domainType.Entire
                ref = @(z) m*log((z - a)./(z - o))/2/pi;
                
            otherwise
                pf = test.primeFunctionReferenceForDomain;
                ref = test.primeFormReferenceFunction(pf, a, o, m);
        end
    end
end

methods(Static)
    function ref = primeFormReferenceFunction(pf, a, o, m)
        rfun = @(z) m*log(...
                pf(z, a).*pf(z, 1/conj(a)) ...
                ./pf(z, o)./pf(z, 1/conj(o)) ...
            )/2/pi;
        ref = poUnitTest.ReferenceFunction(rfun);
        if isa(pf, 'poUnitTest.PrimeFunctionReference')
            ref.tolerance = pf.tolerance;
        end
    end
end

end
