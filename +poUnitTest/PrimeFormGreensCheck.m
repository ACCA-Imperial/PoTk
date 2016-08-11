classdef PrimeFormGreensCheck < poUnitTest.TestCaseParamDomain
%poUnitTest.PrimeFormGreensCheck verifies the prime form Green's functions
%are proper.

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
    function checkValues(test)
        if test.type == poUnitTest.domainType.Entire
            test.checkEntireError()
            return
        end
        test.checkEachOne()
    end
end

methods
    function checkEntireError(test)
        test.verifyError(...
            @() poUnitTest.PrimeFormGreens([], [], test.domainTestObject), ...
            PoTk.ErrorIdString.UndefinedState)
    end
    
    function checkEachOne(test)
        skpD = skpDomain(test.domainObject);
        beta = test.domainObject.infImage;
        pf = test.primeFunctionReferenceForDomain;
        for j = 1:skpD.m+1
            if j == 1
                ref = greensC0(beta, skpD);
            else
                ref = greensCj(beta, j-1, skpD);
            end
            gj = poUnitTest.PrimeFormGreens(pf, j-1, test.domainTestObject);
            
            test.perTestTolerance = pf.tolerance;
            test.diagnosticMessage = ...
                sprintf('While testing G_%d.', j-1);
            test.checkAtTestPoints(ref, @(z) gj(z, beta))
        end
    end
end

end
