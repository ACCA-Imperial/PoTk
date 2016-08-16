classdef PointVortex < poUnitTest.TestCaseParamDomain
%poUnitTest.PointVortex tests the point vortex potential.

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
    entireVortexLocations = [
        0.42176+0.65574i
        1.8315+0.071423i
        2.3766+2.5474i
        3.838+3.736i]
    
    simpleVortexLocations = [
        0.21341+0.39184i
        -0.52128+0.04898i
        -0.038484-0.41283i
        0.43732-0.19592i]
    
    annulusVortexLocations = [
        -0.25539+0.34985i
        0.37434+0.097959i
        0.28338-0.2309i
        0.17843-0.54577i]
    
    conn3VortexLocations = [
        0.12945+0.66472i
        0.57026-0.041983i
        -0.30437-0.31487i
        -0.066472-0.7137i]
    
    vortexStrengths = [-1, 1, -1, 2];
end

methods(Test)
    function checkNetVortex(test)
        test.checkVortexCirc(@pointVortex)
    end
    
    function checkNoNetVortex(test)
        test.checkVortexCirc(@pointVortexNoNet)
    end
    
    function checkNet(test)
        test.checkPotentialValue(@pointVortex)
    end
    
    function checkNetDz(test)
        test.checkDerivative(@pointVortex)
    end
    
    function checkNoNet(test)
        test.checkPotentialValue(@pointVortexNoNet)
    end
    
    function checkNoNetDz(test)
        test.checkDerivative(@pointVortexNoNet)
    end
end

methods
    function checkPotentialValue(test, pvKind)
        pv = test.kindInstance(pvKind);
        W = potential(test.domainObject, pv);
        ref = test.generateReference(pv);
        test.checkAtTestPoints(ref, W)
    end
    
    function checkDerivative(test, pvKind)
        W = potential(test.domainObject, test.kindInstance(pvKind));
        dW = diff(W);
        ref = poUnitTest.FiniteDifference(@(z) W(z));
        test.checkAtTestPoints(ref, dW);
    end
    
    function checkVortexCirc(test, pvKind)
        pv = test.kindInstance(pvKind);
        dW = diff(potential(test.domainObject, pv));
        
        cv = nan(size(pv.strength));
        for k = 1:numel(cv)
            cv(k) = real(poUnitTest.circleIntegral. ...
                forDifferential(dW, pv.location(k), 1e-6));
        end
        err = pv.strength - cv;
        test.verifyLessThan(max(abs(err)), 1e-10);
    end
    
    function pv = kindInstance(test, pvKind)
        pv = pvKind(test.selectVortexPoints(), test.vortexStrengths);
    end
    
    function av = selectVortexPoints(test)
        label = test.domainTestObject.label;
        av = test.([label, 'VortexLocations']);
    end
    
    function ref = generateReference(test, pv)
        switch test.type
            case poUnitTest.domainType.Entire
                N = numel(pv.location);
                ref = @(z) reshape(sum(cell2mat(...
                    arrayfun(@(k) pv.strength(k)*log(z(:) - pv.location(k)), ...
                    1:N, 'uniform', false)), 2), size(z))/2i/pi;
                
            otherwise
                ref = test.primeFormReferenceFuntion(pv);
        end
    end
    
    function ref = primeFormReferenceFuntion(test, pv)
        pf = test.primeFunctionReferenceForDomain;
        g0 = poUnitTest.PrimeFormGreens(pf, 0, test.domainTestObject);
        av = pv.location;
        sv = pv.strength;
        
        function v = rfun(z)
            v = reshape(sum(cell2mat( ...
                arrayfun(@(k) sv(k)*g0(z(:), av(k)), find(sv(:) ~= 0)', ...
                'uniform', false)), 2), size(z));
            if isa(pv, 'pointVortexNoNet') ...
                    && test.type ~= poUnitTest.domainType.Simple
                v = v - sum(sv)*g0(z, test.domainObject.infImage);
            end
        end
        
        ref = poUnitTest.ReferenceFunction(@rfun);
        ref.tolerance = pf.tolerance;
    end
end

end
