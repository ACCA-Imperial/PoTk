classdef UniformFlowMC < poUnitTest.UniformFlow
%poUnitTest.UniformFlowMC runs tests for uniform flow in multiply connected
%domains.

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
    domain = poUnitTest.domainParameterStructure.multiplyConnectedSubset
end

properties(MethodSetupParameter)
    beta = poUnitTest.betaParameter.default
end

properties
    betaParam
    betaValue
    farAway = 1e6*[-1; 1] + 10i
end

methods(TestMethodSetup)
    function setupBeta(test, beta)
        try
            betap = test.domainTestObject.beta(beta);
        catch err
            if strcmp(err.identifier, 'MATLAB:noSuchMethodOrField') ...
                    && isa(test.domainTestObject, 'poUnitTest.domainForTesting')
                test.assumeFail('Parameter not implemented for domain.')
            elseif strcmp(err.identifier, 'MATLAB:nonExistentField')
                test.assumeFail(sprintf(...
                    'Parameter ''%s'' not valid for domain.', beta.label))
            else
                rethrow(err)
            end
        end
        
        test.betaValue = betap;
        test.betaParam = beta;
        if beta == poUnitTest.betaParameter.circle0
            test.angle = 0;
        end
        test.domainTestObject.domainObject.beta = test.betaValue;
    end
    
    function assumeFailKnownCases(test, beta)
        if beta == poUnitTest.betaParameter.origin ...
                && test.type ~= poUnitTest.domainType.Annulus
            test.assumeFail('Not implemented. Bug submitted as issue #72.')
        end
    end
end

methods(Test)
    function checkAngle(test)
        [~, U] = test.unboundedFlow();
        err = test.angle - angle(conj(U(test.farAway)));
        test.verifyLessThan(max(abs(err)), test.defaultTolerance)
    end
    
    function checkStrength(test)
        [~, U] = test.unboundedFlow();
        err = abs(test.strength) - abs(U(test.farAway));
        test.verifyLessThan(max(abs(err)), test.defaultTolerance)
    end
end

methods
    function [W, U] = unboundedFlow(test)
        [m, chi] = test.getParameters();
        D = test.domainObject;
        maps = test.domainTestObject.mapsExternal(test.betaParam);
        W = potential(D, uniformFlow(m, chi, maps.residue));
        if nargout > 1
            dW = diff(W);
            U = @(z) dW(maps.zeta(z))./maps.dz(maps.zeta(z));
        end
    end
end

end
