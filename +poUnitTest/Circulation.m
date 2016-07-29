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
        C = circulation(1, 2);
        test.verifyError(...
            @() potential(test.domainObject, C), ...
            PoTk.ErrorIdString.InvalidArgument)
    end
    
    function entireNoNet(test)
        D = test.domain;
        C = circulationNoNet(1, 2);
        test.verifyError(...
            @() potential(test.domainObject, C), ...
            PoTk.ErrorIdString.InvalidArgument)
    end
    
    function simpleNet(test)
        C = circulation();
        test.verifyError(...
            @() potential(test.domainObject, C), ...
            PoTk.ErrorIdString.InvalidArgument, ...
            'Bug submitted as issue #53.')
    end
    
    function simpleNoNet(test)
        D = test.domainObject;
        beta = D.infImage;
        G = -2;
        C = circulation(G);

        W = potential(test.domainObject, C);        
        ref = @(z) G*(1./(z - beta) - 1./(z - 1/conj(beta)))/2i/pi;
        
        test.diagnosticMessage = 'Bug submitted as issue #54.';
        test.checkAtTestPoints(ref, W)
    end
    
    function annulusNet(test)
        G = -2;
        C = circulation(G);
        
        test.diagnosticMessage = 'Bug submitted as issue #61.';
        test.checkCircValues(C)
    end
    
    function annulusNoNet(test)
        G = [1, -2];
        C = circulationNoNet(G);
        
        test.diagnosticMessage = 'Bug submitted as issue #61.';
        test.checkCircValues(C)
    end
    
    function conn3Net(test)
        G = [1, -2];
        C = circulation(G);
        
        test.diagnosticMessage = 'Bug submitted as issue #61.';
        test.checkCircValues(C)
    end
    
    function conn3NoNet(test)
        G = [1, -2, 2];
        C = circulationNoNet(G);
        
        test.diagnosticMessage = 'Bug submitted as issue #61.';
        test.checkCircValues(C)
    end
    
    function checkCircValues(test, C)
        W = potential(test.domainObject, C);
        ref = test.primeFormReferenceFunction(C);
        test.checkAtTestPoints(ref, W);
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
