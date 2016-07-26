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
        D = test.domainObject;
        C = circulation(1, 2);
        test.verifyError(...
            @() potential(D, C), ...
            PoTk.ErrorIdString.InvalidArgument)
    end
    
    function entireNoNet(test)
        D = test.domain;
        C = circulationNoNet(1, 2);
        test.verifyError(...
            @() potential(D, C), ...
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
        
        W = potential(test.domainObject, C);
        ref = test.annulusReference(C);
        
        test.diagnosticMessage = 'Bug submitted as issue #61.';
        test.checkAtTestPoints(ref, W)
    end
    
    function annulusNoNet(test)
        G = [1, -2];
        C = circulationNoNet(G);
        W = potential(test.domainObject, C);
        ref = test.annulusReference(C);
        
        test.diagnosticMessage = 'Bug submitted as issue #61.';
        test.checkAtTestPoints(ref, W);
    end
    
    function ref = annulusReference(test, C)
        noNet = isa(C, 'circulationNoNet');
        
        D = test.domainObject;
        q = D.qv;
        beta = D.infImage;
        th1 = @(z) skpDomain(D).theta(1, z);
        
        P = poUnitTest.PFunction(q);
        
        G = C.circVector;
        g1 = @(z) log(P(z/beta)./P(z/th1(1/conj(beta)))*abs(beta)*q)/2i/pi;
        if noNet
            g0 = @(z) log(P(z/beta)./P(z*conj(beta))*abs(beta))/2i/pi;
        end
        
        function v = refeval(z)
            v = -G(end)*g1(z);
            if noNet
                v = v - sum(G)*g0(z);
            end
        end
        
        ref = @refeval;
    end
end

end
