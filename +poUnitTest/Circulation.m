classdef Circulation < poUnitTest.TestCaseParamDomain
%poUnitTest.Circulation tests the circulation potential.

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
    simpleCirc = -2
    annulusCirc = [-1, 3];
    conn3Circ = [-1, -1, 3];
    
    integralCollocationPoints = 128
end

methods(Test)
    function checkNet(test)
        if test.hasTypeError()
            return
        end
        test.checkPotential(@circulation)
    end
    
    function checkNetDz(test)
        if test.hasTypeError()
            return
        end
        test.checkDerivative(@circulation)
    end
    
    function checkNetInt(test)
        if test.hasTypeError()
            return
        end
        test.checkIntegral(@circulation)
    end
    
    function checkNoNet(test)
        if test.hasTypeError()
            return
        end
        test.checkPotential(@circulationNoNet)
    end
    
    function checkNoNetDz(test)
        if test.hasTypeError()
            return
        end
        test.checkDerivative(@circulationNoNet)
    end
    
    function checkNoNetInt(test)
        if test.hasTypeError()
            return
        end
        test.checkIntegral(@circulationNoNet)
    end
end

methods
    function tf = hasTypeError(test)
        if test.type == poUnitTest.domainType.Entire
            test.entireError()
            tf = true;
            return
        end
        tf = false;
    end
    
    function entireError(test)
        C = circulation(2);
        test.verifyError(...
            @() potential(test.domainObject, C), ...
            PoTk.ErrorIdString.InvalidArgument)
    end
    
    function C = generateCirculation(test, kind)
        sv = test.dispatchTestProperty('Circ');
        if ~isa(kind(), 'circulationNoNet') ...
                && test.type ~= poUnitTest.domainType.Simple
            sv(1) = [];
        end
        C = kind(sv);
    end
    
    function checkPotential(test, kind)
        C = test.generateCirculation(kind);
        W = potential(test.domainObject, C);
        ref = test.primeFormReferenceFunction(C);
        test.perTestTolerance = ref.tolerance;
        test.checkAtTestPoints(@(z) imag(ref(z)), ...
            @(z) imag(W(z)));
    end
    
    function checkDerivative(test, kind)
        W = potential(test.domainObject, test.generateCirculation(kind));
        dW = diff(W);
        ref = poUnitTest.FiniteDifference(@(z) W(z));
        test.checkAtTestPoints(ref, dW);
    end
    
    function checkIntegral(test, kind)
        C = test.generateCirculation(kind);
        dW = diff(potential(test.domainObject, C));
        [dv, qv, m] = domainData(skpDomain(test.domainObject));
        G = zeros(m+2, 1);
        for i = 1:m+1
            if i > 1
                c = dv(i-1);
                r = qv(i-1);
            else
                c = 0;
                r = 1;
            end
            G(i) = (1 - 2*(i == 1))*real(test.integralCirculation(dW, c, r));
        end
        G(end) = real(test.integralCirculation(...
            dW, test.domainObject.infImage, 1e-6));
        
        sv = double(C);
        if test.type == poUnitTest.domainType.Simple ...
                || isa(C, 'circulationNoNet')
            sv = [sv(:); -sum(sv)];
        else
            sv = [-sum(sv); sv(:); 0];
        end
        
        err = sv - G;
        test.verifyLessThan(max(abs(err)), test.defaultTolerance*10);
    end
    
    function I = integralCirculation(test, dW, c, r)
        N = test.integralCollocationPoints;
        dt = 2*pi/N;
        reitn = r*exp(1i*(0:N-1)'*dt);
        I = 1i*dt*sum(dW(c + reitn).*(reitn));
    end
    
    function ref = primeFormReferenceFunction(test, C)
        D = test.domainObject;
        m = D.m;
        beta = D.infImage;
        sv = C.circVector;
        
        pf = test.primeFunctionReferenceForDomain;
        g0 = poUnitTest.PrimeFormGreens(pf, 0, test.domainTestObject);
        if test.type == poUnitTest.domainType.Simple
            ref = poUnitTest.ReferenceFunction(...
                @(z) -sv*g0(z, beta));
            ref.tolerance = pf.tolerance;
            return
        end
        
        g = cell(m, 1);
        for j = 1:m
            g{j} = poUnitTest.PrimeFormGreens(pf, j, test.domainTestObject);
        end
        
        noNet = isa(C, 'circulationNoNet');
        if noNet
            s0 = sv(1);
            sv = sv(2:end);
        end
        
        function v = refeval(z)
            v = arrayfun(@(j) -sv(j)*g{j}(z(:), beta), ...
                1:m, 'uniform', false);
            v = reshape(sum(cell2mat(v), 2), size(z));
            if noNet
                v = v - s0*g0(z, beta);
            else
                v = v + sum(sv)*g0(z, beta);
            end
        end
        
        ref = poUnitTest.ReferenceFunction(@refeval);
        ref.tolerance = pf.tolerance;
    end    
end

end
