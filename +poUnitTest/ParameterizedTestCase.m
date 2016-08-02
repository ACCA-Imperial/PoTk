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
        test.primeFunctionReferenceForDomain = ...
            test.makePrimeFunctionReferenceForDomain();
    end
end

methods(TestMethodSetup)
    function clearDiagnosticMessage(test)
        test.diagnosticMessage = [];
    end
end

properties(Dependent)
    label
    type
end

methods % set/get
    function lstr = get.label(test)
        lstr = test.domainTestObject.label;
    end
    
    function t = get.type(test)
        t = test.domainTestObject.type;
    end
end

methods
    function prop = dispatchTestProperty(test, name)
        name = [test.label, name];
        try
            prop = test.(name);
        catch err
            if strcmp(err.identifier, 'MATLAB:noSuchMethodOrField') ...
                    && strcmp(err.stack(1).name, ...
                    'ParameterizedTestCase.dispatchTestProperty')
                test.assumeFail(sprintf(...
                    'Test property "%s" not defined.', name))
            else
                throwAsCaller(err)
            end
        end
    end
    
    function dispatchTestMethod(test, name)
        try
            test.([test.label, name])()
        catch err
            if strcmp(err.identifier, 'MATLAB:noSuchMethodOrField') ...
                    && strcmp(err.stack(1).name, ...
                    'ParameterizedTestCase.dispatchTestMethod')
                test.assumeFail('Test not implemented yet.')
            else
                rethrow(err)
            end
        end
    end
end

end
