classdef(Abstract) ParameterizedTestCase < poUnitTest.TestCase
%poUnitTest.ParameterizedTestCase is the abstract base test class for
%parameterized potential tests.

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
    domainTestObject
end

properties(ClassSetupParameter)
    domain = poUnitTest.domainParameterStructure
end

methods(TestClassSetup)
    function setDomainObject(test, domain)
        test.domainTestObject = domain;
    end
end

methods(TestMethodSetup)
    function clearDiagnosticMessage(test)
        test.diagnosticMessage = [];
    end
end

methods
    function dispatchTestMethod(test, name)
        domainLabel = test.domainTestObject.label;
        name(1) = upper(name(1));
        try
            test.([domainLabel, name])()
        catch err
            if strcmp(err.identifier, 'MATLAB:noSuchMethodOrField') ...
                    && strcmp(err.stack(1).name, 'ParameterizedTestCase.dispatchTestMethod')
                test.assumeFail('Test not implemented yet.')
            else
                rethrow(err)
            end
        end
    end

    function pf = primeFunctionFromPFunction(test)
        q = test.domainObject.qv;
        if numel(q) ~= 1
            test.assertFail('Incorrect domain for P-Function use.')
        end
        [P, C] = poUnitTest.PFunction(q);
        pf = @(z,a) a*C*P(z/a);
    end
end

end