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
    annulusCirc = [-2, 2];
    conn3Circ = [-2, 3, -1];
end

methods(Test)
    function checkNet(test)
        switch test.label
            case 'entire'
                test.entireError()
                return
            case 'simple'
                test.verifyError(...
                    @() potential(test.domainObject, circulation()), ...
                    PoTk.ErrorIdString.InvalidArgument, ...
                    'Bug submitted as issue #53.')
                return
            case {'annulus', 'conn3'}
                test.diagnosticMessage = 'Bug submitted as issue #61.';
        end
        test.checkPotential(@circulation)
    end
    
    function checkNetDz(test)
        if strcmp(test.label, 'entire')
            test.entireError()
            return
        end
        test.checkDerivative(@circulation);
    end
    
    function checkNoNet(test)
        switch test.label
            case 'entire'
                test.entireError()
                return
            case 'simple'
                test.verifyFail('Bug submitted as issue #54.')
                return
            case {'annulus', 'conn3'}
                test.diagnosticMessage = 'Bug submitted as issue #61.';
        end
        test.checkPotential(@circulationNoNet)
    end
    
    function checkNoNetDz(test)
        switch test.label
            case 'entire'
                test.entireError()
                return
            case 'simple'
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
            sv(end) = [];
        end
        C = kind(sv);
    end
    
    function checkCircValues(test, C)
        W = potential(test.domainObject, C);
        ref = test.primeFormReferenceFunction(C);
        test.checkAtTestPoints(ref, W);
    end
    
    function checkPotential(test, kind)
        C = test.generateCirculation(kind);
        W = potential(test.domainObject, C);
        ref = test.primeFormReferenceFunction(C);
        test.checkAtTestPoints(ref, W);
    end
    
    function checkDerivative(test, kind)
        W = potential(test.domainObject, test.generateCirculation(kind));
        dW = diff(W);
        ref = poUnitTest.FiniteDifference(@(z) W(z));
        test.checkAtTestPoints(ref, dW);
    end
    
    function ref = primeFormReferenceFunction(test, C)
        D = test.domainObject;
        dv = D.dv;
        qv = D.qv;
        m = D.m;
        beta = D.infImage;
        sv = C.circVector;
        
        pf = test.primeFunctionReferenceForDomain;
        g = cell(m, 1);
        for j = 1:m
            thj = @(z) skpDomain(D).theta(j, z);
            g{j} = @(z) log(pf(z, beta)./pf(z, thj(1/conj(beta))) ...
                *qv(j)/abs(beta - dv(j)))/2i/pi;
        end
        
        noNet = isa(C, 'circulationNoNet');
        if noNet
            g0 = @(z) log(pf(z, beta)./pf(z, 1/conj(beta)) ...
                /abs(beta))/2i/pi;
            s0 = sv(1);
            sv = sv(2:end);
        end
        
        function v = refeval(z)
            v = arrayfun(@(j) -sv(j)*g{j}(z(:)), 1:m, 'uniform', false);
            v = reshape(sum(cell2mat(v), 2), size(z));
            if noNet
                v = v - (s0 + sum(sv))*g0(z);
            end
        end
        
        ref = poUnitTest.ReferenceFunction(@refeval);
        ref.tolerance = pf.tolerance;
    end    
end

end
