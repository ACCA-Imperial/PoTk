classdef Circulation < poUnitTest.ParameterizedTestCase
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

properties
    simpleCirc = -2
    annulusCirc = [-1, 3];
    conn3Circ = [-1, -1, 3];
end

methods(Test)
    function checkNet(test)
        import poUnitTest.domainType
        switch test.type
            case domainType.Entire
                test.entireError()
                return
            case domainType.Simple
                test.verifyError(...
                    @() potential(test.domainObject, circulation()), ...
                    PoTk.ErrorIdString.InvalidArgument, ...
                    'Bug submitted as issue #53.')
                return
            case {domainType.Annulus, domainType.Conn3}
                test.diagnosticMessage = 'Bug submitted as issue #61.';
        end
        test.checkPotential(@circulation)
    end
    
    function checkNetDz(test)
        if test.type == poUnitTest.domainType.Entire
            test.entireError()
            return
        end
        test.checkDerivative(@circulation);
    end
    
    function checkNoNet(test)
        import poUnitTest.domainType
        switch test.type
            case domainType.Entire
                test.entireError()
                return
            case domainType.Simple
                test.verifyFail('Bug submitted as issue #54.')
                return
            case {domainType.Annulus, domainType.Conn3}
                test.diagnosticMessage = 'Bug submitted as issue #61.';
        end
        test.checkPotential(@circulationNoNet)
    end
    
    function checkNoNetDz(test)
        switch test.type
            case poUnitTest.domainType.Entire
                test.entireError()
                return
            case poUnitTest.domainType.Simple
                test.verifyFail('Bug submitted as issue #54.')
                return
        end
        test.checkDerivative(@circulationNoNet)
    end
end

methods
    function entireError(test)
        C = circulation(2);
        test.verifyError(...
            @() potential(test.domainObject, C), ...
            PoTk.ErrorIdString.InvalidArgument)
    end
    
    function C = generateCirculation(test, kind)
        sv = test.dispatchTestProperty('Circ');
        if ~isa(kind(), 'circulationNoNet')
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
    
    function ref = primeFormReferenceFunction(test, C)
        D = test.domainObject;
        m = D.m;
        beta = D.infImage;
        sv = C.circVector;
        
        pf = test.primeFunctionReferenceForDomain;
        g0 = poUnitTest.PrimeFormGreens(pf, 0, test.domainTestObject);
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
