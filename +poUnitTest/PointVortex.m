classdef PointVortex < poUnitTest.ParameterizedTestCase
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

properties
    entireVortexLocations = [
        0.42176+0.65574i
        1.8315+0.071423i
        2.3766+2.5474i
        3.838+3.736i]
    
    simpleVortexLocations = [
        0.67893+0.52697i
        0.75482+0.081283i
        0.10583+0.23208i
        0.76115+0.45573i]
    
    annulusVortexLocations = [
        -0.25539+0.34985i
        0.37434+0.097959i
        0.28338-0.2309i
        0.17843-0.54577i]
    
    vortexStrengths = [-1, 1, -1, 1];
end

methods(Test)
    function checkNet(test)
        dispatchTestMethod(test, 'net')
    end
    
    function checkNoNet(test)
        dispatchTestMethod(test, 'noNet')
    end
end

methods
    function entireNet(test)
        test.checkEitherPV(@pointVortex)
    end
    
    function entireNoNet(test)
        test.checkEitherPV(@pointVortexNoNet)
    end
    
    function simpleNet(test)
        test.diagnosticMessage = 'Bug submitted as issue #56.';
        test.checkEitherPV(@pointVortex)
    end
    
    function simpleNoNet(test)
        test.verifyFail('Not implemented. Submitted bug as issue #55.')
        
        % FIXME: Reinstate the following line, and delete the one above
        % after fixing #55!
%         test.checkEitherPV(@pointVortexNoNet)
    end
    
    function annulusNet(test)
        test.checkEitherPV(@pointVortex)
    end
    
    function annulusNoNet(test)
        test.checkEitherPV(@pointVortexNoNet)
    end
    
    function checkEitherPV(test, pvKind)
        pv = pvKind(test.selectVortexPoints(), test.vortexStrengths);
        W = potential(test.domainObject, pv);
        ref = test.generateReference(pv);
        test.checkAtTestPoints(ref, W, test.defaultTolerance)
    end
    
    function av = selectVortexPoints(test)
        label = test.domainTestObject.label;
        av = test.([label, 'VortexLocations']);
    end
    
    function ref = generateReference(test, pv)
        label = test.domainTestObject.label;
        switch label
            case 'entire'
                N = numel(pv.location);
                ref = @(z) reshape(sum(cell2mat(...
                    arrayfun(@(k) log(z(:) - pv.location(k)), ...
                    1:N, 'uniform', false)), 2), size(z))/2i/pi;
                
            case 'simple'
                ref = test.simpleReference(pv);
                
            case 'annulus'
                ref = test.arrayReference(pv);
                
            otherwise
                test.assumeFail('Case %s not implemented yet.', label)
        end
    end
    
    function ref = simpleReference(test, pv)
        g0 = @(z,a) poUnitTest.simpleG0(z, a);
        av = pv.location;
        sv = pv.strength;
        
        function v = rfun(z)
            v = reshape(sum(cell2mat( ...
                arrayfun(@(k) sv(k)*g0(z(:), av(k)), find(sv(:) ~= 0)', ...
                'uniform', false)), 2), size(z));
            if isa(pv, 'pointVortexNoNet')
                v = v - sum(sv)*g0(z, test.domainObject.infImage);
            end
        end
        
        ref = @rfun;
    end
    
    function ref = arrayReference(test, pv)
        q = test.domainObject.qv;
        P = poUnitTest.PFunction(q);
        g0 = @(z,a) log(abs(a)*P(z/a)./P(z*conj(a)))/2i/pi;
        av = pv.location;
        sv = pv.strength;
        
        function v = rfun(z)
            v = reshape(sum(cell2mat( ...
                arrayfun(@(k) sv(k)*g0(z(:), av(k)), find(sv(:) ~= 0)', ...
                'uniform', false)), 2), size(z));
            if isa(pv, 'pointVortexNoNet')
                v = v - sum(sv)*g0(z, test.domainObject.infImage);
            end
        end
        
        ref = @rfun;
    end
end

end
