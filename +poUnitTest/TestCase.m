classdef(Abstract) TestCase < matlab.unittest.TestCase
%poUnitTest.TestCase is the abstract base test class for potential tests.

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
    defaultTolerance = 1e-12;

    domainTestObject
    domainObject
    
    diagnosticMessage
end

properties(ClassSetupParameter)
    domain = struct(...
        'entire', poUnitTest.domainEntire())
end

methods(TestClassSetup)
    function setDomainObject(test, domain)
        test.domainTestObject = domain;
        test.domainObject = domain.domainObject;
    end
end

methods(TestMethodSetup)
    function clearDiagnosticMessage(test)
        test.diagnosticMessage = [];
    end
end

methods
    function checkAtTestPoints(test, ref, fun, tol)
        if nargin < 4 || isempty(tol)
            tol = test.defaultTolerance;
        end
        
        zp = test.domainTestObject.testPoints;
        err = ref(zp) - fun(zp);
        
        msg = test.diagnosticMessage;
        if isempty(msg)
            args = {tol};
        else
            args = {tol, msg};
        end
        test.verifyLessThan(max(abs(err(:))), args{:})
    end
    
    function dispatchTestMethod(test, name)
        domainLabel = test.domainTestObject.label;
        name(1) = upper(name(1));
        funcName = [domainLabel, name];
        callThis = @() test.(funcName);
        try
            callThis()
        catch err
            if strcmp(err.identifier, 'MATLAB:noSuchMethodOrField')
                test.verifyFail('Test not implemented yet.')
            else
                rethrow(err)
            end
        end
    end
end

end
